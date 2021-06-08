close all
clear
clc

h=6.626068e-34;                % Planck's constant (m^2*kg/s)
c=299792458;                     % speed of light in vacuum (m/s)
%% Resonator parameters
wavelength = 1549.8e-9; % carrier wavelength
w_carrier=2*pi*c/wavelength;    % carrier angular frequency 

n2 = 1616e-20;  % nonlinear index for AlGaAs, unit m^2/W
FSR = 17.48e9; % FSR, GHz.
ng = 3.3; % group velocity index %c/(2*pi*R*FSR)
tauR = 1/FSR; % round trip time in s
R = c/FSR/2/pi/ng; %Ring radius. 1438e-6/2;

%------ Q factors ------%
Qfactor0 = 1.129e6; % intrinsic Q
Qfactore = 2.1587e+6; % external Q
Qfactor = 1/(1/Qfactore+1/Qfactor0); % loaded Q

decayrate = w_carrier/Qfactor; % total loss rate kappa in Hz
decayrate0 = w_carrier/Qfactor0; % intrinsic loss rate

%------ mode parameters ------%
Aeff_p = 2.63e-13;
gamma0_p = 2*pi/wavelength*n2/Aeff_p;  % nonlinear coefficient
D1p = 2*pi*FSR;
D2p = 2*pi*54.4e3; % Dispersion coefficient
beta2p = -ng*D2p/D1p^2/c;

%% Simulation parameters
%------ frequency domain / fast time domain------%
nt = 4096;
dt = tauR/nt;
w = 2*pi*[(0:round(nt/2)-1),(-floor(nt/2):-1)]'/(dt*nt);  % frequency window, relative to center angular frequency, with fftshift applied
w = gpuArray(w);
lower_freq  = c/wavelength + min(w)/2/pi; % the lower limit of frequency 
upper_freq = c/wavelength + max(w)/2/pi; % the upper limit of frequency 
f0 = (lower_freq+upper_freq)/2; % center frequence in the frequency window 
w0 = 2*pi*f0;
lambda0 = c/f0; % center wavelength in m

time_start = 0;                  % the beginning of time
time_end = round(tauR/dt)*dt;    % the end of time
time = (time_start:dt:(time_end-dt))';   % time window
time = gpuArray(time);
%------ time domain / slow time domain ------%
dz = 1*tauR;
nz = 2e4; % number of steps

%% Input parameters
randn('state',sum(98*clock))
xw=randn(size(time));
xw = gpuArray(xw);
randn('state',sum(99*clock))
yw=randn(size(time));
yw = gpuArray(yw);
noise=sqrt(h*(w+w0)/4/pi).*(xw+1i*yw);
Ain=1e0.*ifft(noise)*length(noise); % in unit sqrt(W)
Atemp = Ain;

%%
PComb=0.13*4096*1e-3; % 3 mW per comb line
PComb=100*1e-3;
NComb=16;   % half number of the comb line
EOComb=zeros(length(w),1);
EOComb = gpuArray(EOComb);
EOComb(1:NComb+1)=sqrt(PComb);
EOComb(length(w)-NComb+1:length(w))=sqrt(PComb);
EOPhase=1/17*1e3*(-21.6e-27).*w.^2/2;

EOPhase=0.25/17*1e3*(-21.6e-27).*w.^2/2;

Ein_pulse = fftshift( fft( EOComb.*exp(1i*EOPhase) )/sqrt(length(w)) );
% Ein_pulse = ifft( EOComb.*exp(1i*EOPhase) );
Sin_pulse=fft(Ein_pulse);
figure
plot(time*1e12,abs(Ein_pulse).^2);

%%
gamma=(2*pi*R/tauR)*gamma0_p;   % nonlinear coefficient in 1/W/m
alpharing = decayrate0*tauR; % loss in percent unit per roundtrip for intrinsic
kappae = (decayrate-decayrate0)*tauR; % loss in percent unit per roundtrip for coupling
kappaall = alpharing + kappae;

beta1 = -0.1e-13*2*pi*w;
disp2 = beta2p*w.^2/2 ;

save_n = 100;
Asave1 = zeros( nt,ceil(nz*5/save_n) );
Asave1 = gpuArray(Asave1);

% ------------------ %

% for kz = 1:nz*5
%     delta0 = (10*kz/nz)*(kappaall/2);
%     
%     Dis = (-kappaall/2 + 1i*delta0 + 1i*beta1*2*pi*R - 1i*disp2*2*pi*R); % Linear loss is treated as part of dispersion.
%     
%     Atemp = ifft(exp(Dis*dz/tauR).*fft(Atemp)) ; % Not related to energy. No need to normalize.
%     
%     A2 = abs(Atemp).*abs(Atemp);
%     
%     Atemp_lp = Atemp + sqrt(kappae)*Ein_pulse*(dz/tauR);
%     
%     Atemp = Atemp_lp.*exp(-1i*dz*gamma*A2);
%     
%     if (kz/save_n)==round(kz/save_n)
%         Asave1(:,round(kz/save_n))=Atemp;
%         fprintf("%.0f of %.0f\n",kz, nz)
%     end
% end

% ----------------- %
nz = 1e5 ;
scan_time = 1e5*tauR /1; %50e-3;
dz = scan_time/nz;  %100*tauR;
start_detuning = -25 /2;
stop_detuning = 25 /2;

tic
for kz = 1:nz
    delta0 = ( start_detuning+(stop_detuning-start_detuning)*kz/nz )*(kappaall);
    
    Dis = (-kappaall/2 + 1i*delta0 + 1i*beta1*2*pi*R - 1i*disp2*2*pi*R); % Linear loss is treated as part of dispersion.
    
    Atemp = ifft(exp(Dis*dz/tauR).*fft(Atemp)) ; % Not related to energy. No need to normalize.
    
    A2 = abs(Atemp).*abs(Atemp);
    
    Atemp_lp = Atemp + sqrt(kappae)*Ein_pulse*(dz/tauR);
    
    Atemp = Atemp_lp.*exp(-1i*dz*gamma*A2);
    
    if (kz/save_n)==round(kz/save_n)
        Asave1(:,round(kz/save_n))=Atemp;
        fprintf("%.0f of %.0f\n",kz, nz)
    end
end
toc
% ---------------- %

time = gather(time);
Asave1 = gather(Asave1);
Ein_pulse = gather(Ein_pulse);

%%
ploty_pos = 0.62
figure
hold on
% plot(time*1e12,abs(Asave1(:,ploty_pos*end)).^2 / max(abs(Asave1(:,ploty_pos*end)).^2) ,'DisplayName','Intracavity power');
% plot(time*1e12,abs(Ein_pulse).^2 / max(abs(Ein_pulse).^2),'DisplayName','Pulse input' );
plot(time*1e12,abs(Asave1(:,ploty_pos*end)).^2  ,'DisplayName','Intracavity power');
plot(time*1e12,abs(Ein_pulse).^2 ,'DisplayName','Pulse input' );
legend('location','best')
xlabel('Fast time (ps)');
ylabel('Power (arbi. unit.)')

%%
asave_size = size(Asave1);

figure
hold on
% pcolor(time*1e12,1:asave_size(2),abs(Asave1).^2');
pcolor(time*1e12,linspace(start_detuning,stop_detuning,asave_size(2)),abs(Asave1).^2');
xline(max(time*1e12)/2,'r');
xlabel('Fast time (ps)');
ylabel('Detuning (\kappa)');
xlim([0 max(time*1e12)]);
shading interp;


Asave1_freq = fft(Asave1,[],1)/sqrt(asave_size(1));
Asave1_freq(1:NComb+1) = 0;
Asave1_freq(end-NComb+1:end) = 0;
Comb_power = sum(abs(Asave1_freq).^2,1);
figure
plot(linspace(start_detuning,stop_detuning,asave_size(2)), Comb_power)
xlabel('Detuning (\kappa)');
ylabel('Comb Power (arbi.unit)')






