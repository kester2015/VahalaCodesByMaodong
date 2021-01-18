clear
close all
clc
c = 299792458;
%%
Q0 = 1.886; % M
Qe = 4.085; % M
lambda = 1550.4; % nm
Qt = Q0*Qe/(Q0+Qe);
kappa = (2*pi*c/(lambda*1e-9))/(Qt*1e6); % SI unit

FSR = 17924.02 * 1e6; % SI unit
disp_D2 = -10.1 * 1e3; % SI unit
disp_D3 = -130; % SI unit
disp_D4 = -322*1e-3; % SI unit


%% load experiment results
load('D:\Measurement\pulse pumping\20201123\OSA_Cavity15_PumpPower0.833_Dispersion7.8_RepRate17.91964GHz-1430-1700nm.mat');
% load('D:\Measurement\pulse pumping\20201123\OSA_Cavity15_PumpPower0.833_Dispersion7.8_RepRate17.91695GHz-1430-1700nm.mat');

combPower=envelope(OSAPower,20,'peak'); % baseline estimate, using slow-varying envelope
NoiseLevel = -100;
FSR_nm = lambda - 1/(1/lambda + FSR/1e9/c);
[PKS,LOCS] = findpeaks(OSAPower,OSAWavelength*1e9,'MinPeakHeight',NoiseLevel,'MinPeakDistance',FSR_nm * 0.9);
    % disgard datapoints around pump
    % [~,idx] = min(abs(LOCS - lambda));
    % LOCS(idx-1:idx+1) = [];
    % PKS(idx-1:idx+1) = [];
    inputWidthnm = 6.5; % input EO comb spectrum width
    idx = abs(LOCS - lambda)<inputWidthnm/2;
    LOCS(idx) = [];
    PKS(idx) = [];


figure
plot(OSAWavelength*1e9,OSAPower);
hold on
scatter(LOCS,PKS);
hold off
pause(1);


    %% Begin simulation
    filedir = "D:\Measurement\pulse pumping\Simulation_20210114_check_para\";
    nstep = 10e4;
    nt = 2048;        % set the point number to be 2048
    tauR = 1/FSR; %46e-12; % in s, round-trip time % for the ring is 224 GHz.
    dt = tauR/nt;     % set the point number to be 2048
    w = 2*pi*[(0:round(nt/2)-1),(-floor(nt/2):-1)]'/(dt*nt);  % frequency window, relative to center angular frequency, with fftshift applied
    %%
        D1 = (5*1e6/kappa)*[2]*2.6;
        D2 = (disp_D2/kappa)*[1]*4.8;%[1:0.1:2 0.9:-0.1:0.5];
        D3 = (disp_D3/kappa)*3.1;%[1.8];%[1:0.1:2 0.9:-0.1:0.5];
        D4 = (disp_D4/kappa)*[1];
        pulse_width = [0.05]/2;
        pump_power = [1];
        detuning = -0;%[0:1:5];
        
        EO_disp = [ 2 ];
        
         figure('Units','normalized','position',[0.1 0.1 0.8 0.5])
         plot(-200:200,arrayfun(@(x)D2*x^2/2+D3*x^3/6+D4*x^4/24,-200:200) )
         hold on
         
%         arbi_D3 = +0.03*D3*kappa;
%         arbi_D5 = +3*1e-4;
%         arbiDisp = @(mu)((arbi_D5/kappa)*mu^5 + (arbi_D3/kappa)*mu^3);
%         % figure
%         plot(-200:200,arrayfun(@(x)D2*x^2/2+D3*x^3/6+D4*x^4/24+arbiDisp(x),-200:200) )
%         hold off
%         pause(1)
        arbiDisp = @(x)0;
    %%
    save_flag = datestr(now,'yymmdd-HHMMSS');
    EOPhase = 1.9/17*1e3*(-21.6e-27).*w.^2/2 * EO_disp;

    x0 = nt/2;
        % pulse_width = 0.05
    dx = pulse_width*nt;
    lorentian = @(x,x0,dx)dx^2./((x-x0).^2+dx^2);
    gaussian = @(x,x0,dx)exp(-(x-x0)^2/2/dx^2);
    pulse_train = @(x)sum(gaussian(x,x0,dx));
    pulsePower = arrayfun(@(x)50*pulse_train(x), 1:nt);
    pulsePower = pulsePower.*exp(1i*EOPhase');

        
        % load(strcat( "D:\Measurement\pulse pumping\Simulation_20210114_para_sweep\","210117-023720-slover.mat"))
        % f1.dispProgress = 1;
        
        
    f2 = LLESolver('D1',D1,'D2',D2,'D3',D3,'pumpPower',pump_power,'detuning',detuning,'NStep',nstep,'timeStep',5e-4/5,'pulsePump',pulsePower,...
        'initState','random','solver','SSFT','modeNumber',nt,'saveStep',500,'dispProgress',1,'arbiDisp',arbiDisp);
    save(strcat(filedir,save_flag,'-slover.mat'),'f2');
    
    
    f2.solve;
    % close all
    f2.plotAll_pulsed(strcat(filedir,save_flag,sprintf('-EOdisp-%.2f',EO_disp),'-'));
    pause(1)

    w0 = 2*pi*c/(lambda*1e-9);
    lambda_sweep = ifftshift(2*pi*c./(w+w0))*1e9;
    spec_simu = @(lambda)interp1(lambda_sweep,f2.getSpectrumDB,lambda); 

    %% fitting to experiment result
        idx = ~(LOCS>min(lambda_sweep) & LOCS<max(lambda_sweep) & LOCS<1670& LOCS>1445);
        LOCS(idx) = [];
        PKS(idx) = [];

    fminfun = @(offset)sum(abs(spec_simu(LOCS)-offset-PKS));
    [offset, residue] = fminsearch(fminfun,-max(PKS)+max(f2.getSpectrumDB) );

    figure('Units','normalized','position',[0.1 0.1 0.8 0.5])
    plot(OSAWavelength*1e9,OSAPower,'displayname','Raw data');
    hold on
    scatter(LOCS,PKS,'displayname','Experiment');
    scatter(LOCS,spec_simu(LOCS)-offset,'displayname','Simulation')
    ylim([-90 -10])
    legend('location','best')
    xlabel('Wavelength / nm')
    ylabel('db / arbi. unit.')
    hold off
    pause(1);
    saveas(gcf,strcat(filedir,save_flag,'-spectrumFit.jpg'))










