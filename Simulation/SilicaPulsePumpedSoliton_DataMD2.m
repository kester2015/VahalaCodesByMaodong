%%%% The basic Phase-Frame of this code is based on exp(iwt);

clear all
h=6.626068e-34;                % Planck's constant (m^2*kg/s)
c=2.998e8;                     % speed of light in vacuum (m/s)

%%%%%%%%%%%
tauR=46e-12; % in s, round-trip time % for the ring is 224 GHz.
scale=1;
scanning=[
 10e-6, 160, 3.0;
 10e-6, 160, 10.0;
 10e-6, 160, 20.0;
 10e-6, 160, 24.0;
 10e-6, 160, 40.0;
 %10e-6, 160, 50.0;
 ]; % Length, X, Delta
%%%%%%%%%%%

wavelength=1.5498e-6;             % carrier wavelength
wavelength_s=1.610e-6;             % carrier wavelength for Stokes soliton
w_carrier=2*pi*c/wavelength;    % carrier angular frequency 
w_carrier_s=2*pi*c/wavelength_s;    % carrier angular frequency for Stokes soliton
n2=2.2e-20;  % nonlinear index for silica, unit m^2/W

R=1.5e-3; % Radius of the resonator, typical for diameter 3 mm microdisk
FSR=22e9; % FSR of a typical 3 mm microdisk is 22 GHz
ng=c/(2*pi*R*FSR); % calculated group velocity index, for this cavity

Qfactor=25e6;  % loaded Q
Qfactor0=95e6;  % intrinsic Q
decayrate=w_carrier/Qfactor; % total loss rate
decayrate0 = w_carrier/Qfactor0; % intrinsic loss rate


%eta=0.5;  % the relationship kappa/alpharing, 1 for critical coupling, >1 over, <1 under
alpharing=decayrate0*tauR;  % loss in percent unit per roundtrip for intrinsic
kappa=(decayrate-decayrate0)*tauR;   % loss in percent unit per roundtrip for coupling
cavity_loss_dB=alpharing/(2*pi*R*1e2)*4.343; % loss in dB;
finesse=2*pi*FSR/decayrate;

Aeff_p=40e-12; % effective mode area for the primary soliton, unit m^2
Aeff_s=70e-12; % effective mode area for the Stokes soliton, unit m^2
Aeff_ps=120e-12; % effective mode area for crossing term

gamma0_p=2*pi/wavelength*n2/Aeff_p;  % nonlinear coefficient
gamma0_s=2*pi/wavelength*n2/Aeff_s;
gamma0_ps=2*pi/wavelength*n2/Aeff_ps;



Length=scanning(1,1)/scale; %10e-9; % in s, window length of slow time
%Pin=scanning(1,2)/(gamma_array(1,posi)*2*pi*R*kappa*8/(alpharing+kappa)^3);%0.133; % in W, with X=10
delta0=scanning(1,3)*(alpharing+kappa)/2;%1.0*decayrate*2*pi*tauR; %tauR*(w_m-w_carrier); % in rad, phase detuning, with Delta=3

%%%%%%%%%%%

% Waveguide parameters
D2p=2*pi*11e3;                        % Dispersion coefficient in the unit like ps/nm/km
D1p=2*pi*FSR;
beta2s=-ng*D2p/D1p^2/c;                 % Dispersion coefficient in the unit like ps^2/km

%D2s=2*pi*22e3;                        % Dispersion coefficient in the unit like ps/nm/km
%deltaFSR=0;
%FSR_s=FSR+deltaFSR;                          % Difference in FSR of two modes
%ng_s=c/(2*pi*R*FSR_s);    % calculated group velocity index, for this cavity; Stokes mode
%D1s=2*pi*FSR_s;
%beta2s=-22e-27*0.3;                 % Dispersion coefficient in the unit like ps^2/km
%beta1=(ng-ng_s)/c;                        % Delta beta1, for the group velocity difference


alpha0=scale*alpharing; %scale*1*100/4.343;            % loss in 1/m, and alpha_dB (in dB/m) = 4.343*alpha


xie=1;                         % polarization dependent Kerr, =1; % for TM mode, =1.14; % for TE mode, % refer to Q. Lin, OE, p.16604, 2007

% Simulation parameters
nt=2048;        % set the point number to be 2048
dt=tauR/nt;     % set the point number to be 2048
w=2*pi*[(0:round(nt/2)-1),(-floor(nt/2):-1)]'/(dt*nt);  % frequency window, relative to center angular frequency, with fftshift applied
lower_freq=c/wavelength+min(w)/2/pi;% the lower limit of frequency 
upper_freq=c/wavelength+max(w)/2/pi;% the upper limit of frequency 
f0=(lower_freq+upper_freq)/2;  % center frequence in the frequency window 
w0=2*pi*f0;
lambda0=c/f0;                  % center wavelength in m
%dt=1/(upper_freq-lower_freq);  % time step in s
time_start=0;                  % the beginning of time
%%%%%%%%%%%%%%%
time_end=round(tauR/dt)*dt;    % the end of time
%nt=round((time_end-time_start)/dt); 
%%%%%%%%%%%%%%%
time=(time_start:dt:(time_end-dt))';   % time window
dz=tauR*10; %0.001/decayrate; % step of slow time, associated with photon lifetime %c/neff*dt;                  % spatial step in m
nz=2e4;           % the number of spatial steps

% Input parameters
%%%%%%%%%%%%%%%%%%%%
randn('state',sum(98*clock))
xw=randn(size(time));
randn('state',sum(99*clock))
yw=randn(size(time));
noise=sqrt(h*(w+w0)/4/pi/1).*(xw+j*yw);
Ain=1e0.*ifft(noise);%j*sqrt(peak_power)*sech((time-peak_time)/T0).*exp(j*(w_carrier-w0)*time);     % in sqrt(W) 
%%%%%%%%%%%%%%%%%%%%
%figure; 
%subplot(6,1,1); 
%plot(1e9*c./((w+w0)/2/pi),10*log10(abs(fft(Ain+sqrt(Pin))).^2)); xlim([600,3500]); ylim([max(10*log10(abs(fft(Ain+sqrt(Pin))).^2))-200,max(10*log10(abs(fft(Ain+sqrt(Pin))).^2))+10]);
%title(['A=',num2str(wavelength*1e9),'nm, L=',num2str(Length*scale*1e2),'cm, alpha=',num2str(0.04343*alpha0/scale),'dB/cm, beta2=',num2str(betav(3)*1e27),'ps^2/km, beta3=',num2str(betav(4)*1e39),'ps^3/km, beta4=',num2str(betav(5)*1e51),'ps^4/km, P0=',num2str(Pin),'W']);
Atmp=Ain;


[sn,temp]=size(scanning);

% Data storage
save_step=10e-9/scale; %10e-6/scale;% in m
save_n=round(save_step/dz);
Asave=zeros(sn,nt,floor(Length/save_step));

tic;

Pin=250e-3;  % Input power of 250 mW.
X=Pin*(gamma0_p*2*pi*R*kappa*8/(alpharing+kappa)^3);
Pin=X/(gamma0_p*2*pi*R*kappa*8/(alpharing+kappa)^3);

gamma=(2*pi*R/tauR)*scale*gamma0_p;   % nonlinear coefficient in 1/W/m
%%
%Atmp=Atmp0;
PComb=25/15*1e-3; % 3 mW per comb line
NComb=7;   % half number of the comb line
EOComb=zeros(length(w),1);
EOComb(1:NComb+1)=sqrt(PComb);
EOComb(length(w)-NComb+1:length(w))=sqrt(PComb);
EOPhase=1.9/17*1e3*(-21.6e-27).*w.^2/2;
Ein_pulse = fftshift(fft(EOComb.*exp(i*EOPhase)));
Sin_pulse=fft(Ein_pulse);
figure
plot(time*1e12,abs(Ein_pulse).^2);

%figure
%plot(fftshift(w),fftshift(abs(Sin_pulse).^2)/nt/nt);
%%%

dz=4*tauR;
save_n=40;

dw=abs(w(2)-w(1));
disp=(beta2s*w.^2/2);

omega_center=zeros(20,10000);
Asave1=zeros(nt,5000);

tic;
%DFF=h*w0/tauR*alpha0/2/pi; % Noise coefficient from time domain;
%xiR=0.6;
Pin_pulse=abs(Ein_pulse).^2;
Pave = sum(Pin_pulse)*dt/tauR;

%%
%clear Asave1;
tic;
beta1=26e-7*tauR/(2*pi*R)/2;

FilterFunc=ones(length(w),1);
FilterFunc(1:NComb+1)=0;
FilterFunc(length(w)-NComb+1:length(w))=0;

Qfactor=25e6;  % loaded Q
Qfactor0=100e6;  % intrinsic Q
decayrate=w_carrier/Qfactor; % total loss rate
decayrate0 = w_carrier/Qfactor0; % intrinsic loss rate
alpharing=decayrate0*tauR;  % loss in percent unit per roundtrip for intrinsic
kappa=(decayrate-decayrate0)*tauR;   % loss in percent unit per roundtrip for coupling

for KLoop=1:1
    %Qex=5e6+(KLoop-1)*2.5e6;
    Qex=30e6;
    Qfactor0=100e6;  % intrinsic Q
    %decayrate=w_carrier/Qfactor; % total loss rate
    decayrate0 = w_carrier/Qfactor0; % intrinsic loss rate
    alpharing = decayrate0*tauR;  % loss in percent unit per roundtrip for intrinsic
    kappa = w_carrier/Qex*tauR;   % loss in percent unit per roundtrip for coupling
    
for Kloop=1:1
    for sm=sn:sn  
        Length=scanning(sm,1)/scale; %10e-9; % in s, window length of slow time
        delta0=(50+5*KLoop)*(alpharing+kappa)/2;%1.0*decayrate*2*pi*tauR; %tauR*(w_m-w_carrier); % in rad, phase detuning, with Delta=3
        %Pin=scanning(sm,2)/(gamma0_p*2*pi*R*kappa*8/(alpharing+kappa)^3);
        Dis=(-alpha0/2-scale*kappa/2+j*scale*delta0-j*scale*2*pi*R*disp)/tauR; % Linear loss is treated as part of dispersion.
        %Dis0=Dis;
        %Dis0=(-alpha0/2-scale*kappa/2+j*scale*delta0-j*scale*2*pi*R*((w+w0).*neff_shift/c-betav(1)-betav(2)*w)-99*j*scale*2*pi*R*(0.5*betav(3)*w.^2))/tauR; % increase beta2 by 99 times
        Dis=exp(Dis*dz);  % Deal with dispersion in frequency domain        
        %fig_num=2;
        for kz=1:nz*10            
            delta0=(0.5*75*kz/nz/50)*(alpharing+kappa)/2;
            %delta0= (4.5+0.125*(KLoop-1))*(alpharing+kappa)/2;
            %delta0= (7.375+0.125*(KLoop-24)/2)*(alpharing+kappa)/2;
            %Pin=scanning(sm,2)/(gamma0_p*2*pi*R*kappa*8/(alpharing+kappa)^3);
            Dis=(-alpha0/2-scale*kappa/2+j*scale*delta0+j*beta1*w*2*pi*R-j*scale*2*pi*R*disp)/tauR; % Linear loss is treated as part of dispersion.
            %Dis0=Dis;
            %Dis0=(-alpha0/2-scale*kappa/2+j*scale*delta0-j*scale*2*pi*R*((w+w0).*neff_shift/c-betav(1)-betav(2)*w)-99*j*scale*2*pi*R*(0.5*betav(3)*w.^2))/tauR; % increase beta2 by 99 times
            Dis=exp(Dis*dz);
            Atmp=ifft(Dis.*fft(Atmp));
            % Nonlinearity in time domain
            A2=abs(Atmp).*abs(Atmp);
            
            NLTerm=gamma*xie*A2;
            Atmp_1p=Atmp+dz*sqrt(kappa)*Ein_pulse/tauR;
            %Atmp_1p=Atmp+dz*(sqrt(kappa*Pin_pulse))*scale/tauR;
            %%%%%%%%%%%%%%
            %fAtmp=-NLTerm+j*gamma*xie*tau_shocke*ifft(j*w.*fft(A2))+j*gammaR*xiR*tau_shockR*ifft(j*w.*HR.*fft(A2));
            fAtmp=-NLTerm;
            Atmp=Atmp_1p.*exp(j*dz*fAtmp);
            
            if (kz/save_n)==round(kz/save_n)
                Asave1(:,round(kz/save_n))=Atmp;
            end
            Sout=fft(Atmp).*FilterFunc;
            Aout=ifft(Sout);            
            Pout(KLoop,kz)=sum(abs(Aout).^2)*dt/tauR;
        end
    end
    toc
    
end
As(:,KLoop)=Atmp;
figure(100)
hold on
plot(time*1e12,abs(Atmp).^2);

end
%figure
%plot(time*1e12,abs(Atmp).^2);

spect=10*log10(abs(fftshift(fft(Atmp))).^2);
wave=2*pi*c./fftshift((w+w0))*1e9;
%figure
%plot(wave,spect);

figure
pcolor(time*1e12,1:0.5e4,abs(Asave1).^2');
shading interp;