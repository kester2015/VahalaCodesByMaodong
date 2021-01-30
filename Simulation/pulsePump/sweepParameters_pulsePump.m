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
disp_D2 = -10.2 * 1e3; % SI unit
disp_D3 = -87; % SI unit
%% load experiment results
load('D:\Measurement\pulse pumping\20201123\OSA_Cavity15_PumpPower0.833_Dispersion7.8_RepRate17.91964GHz-1430-1700nm.mat');
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

%%
ii = 0;
D1_List = (5*1e6/kappa)*[0 1 2 -1 -2];
D2_List = (disp_D2/kappa)*[0.5 1 2 3];%[1:0.1:2 0.9:-0.1:0.5];
D3_List = (disp_D3/kappa)*[0.5 1 2 3];%[1:0.1:2 0.9:-0.1:0.5];
pulse_width_List = [0.02 0.05 0.08]/2;
pump_power_List = [1,5,10];
detuning_List = [-5 0 5];%[0:1:5];
EO_disp_list = [-1 -0.5 0 0.2 0.8 2];
totalNum = length(D1_List)*length(D2_List)*length(D3_List)*length(pulse_width_List)*length(pump_power_List)*length(detuning_List)*length(EO_disp_list);

for pulse_width = pulse_width_List
for D1 = D1_List
for D2 = D2_List
for D3 = D3_List
    for EO_disp = EO_disp_list
        for pump_power = pump_power_List
        for detuning = detuning_List
            ii = ii + 1 ;
            close all
            tic;
            sweep_overnight(pulse_width,D1, D2, D3, pump_power, detuning, EO_disp , LOCS,PKS,OSAWavelength,OSAPower);
            t = toc;
            printPredictTime(t*(totalNum-ii));
            fprintf("--------Finished %.0f of Total %.0f Calculations--------\n",ii,totalNum)
            fprintf("--------D1=%.f, D2=%.f, D3=%.f, pulseWd=%.2f, pulsePw=%.2f, detun=%.f, EO_disp=%.1f*--------\n",...
                D1,D2,D3,pulse_width,pump_power,detuning,EO_disp)
        end
        end
    end
end
end
end
end


%%
function sweep_overnight(pulse_width, D1, D2, D3, pump_power, detuning,EO_disp,LOCS,PKS,OSAWavelength,OSAPower)
    c = 299792458;
    lambda = 1550.4; % nm
    FSR = 17924.02 * 1e6; % SI unit
    %% Begin simulation
    filedir = "D:\Measurement\pulse pumping\Simulation_20210114_para_sweep\";
    nstep = 10e4;
    nt = 2048;        % set the point number to be 2048
    tauR = 1/FSR; %46e-12; % in s, round-trip time % for the ring is 224 GHz.
    dt = tauR/nt;     % set the point number to be 2048
    w = 2*pi*[(0:round(nt/2)-1),(-floor(nt/2):-1)]'/(dt*nt);  % frequency window, relative to center angular frequency, with fftshift applied
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
    
        % D1 = 0;
        % D2 = -0.2;
        % D3 = 0;
        % pump_power = 10;
        % detuning = 10;
    
    f1 = LLESolver('D1',D1,'D2',D2,'D3',D3,'pumpPower',pump_power,'detuning',detuning,'NStep',nstep,'timeStep',5e-4/5,'pulsePump',pulsePower,...
        'initState','random','solver','SSFT','modeNumber',nt,'saveStep',500,'dispProgress',0);
    save(strcat(filedir,save_flag,'-slover.mat'),'f1');
    f1.solve;
    close all
    f1.plotAll_pulsed(strcat(filedir,save_flag,sprintf('-EOdisp-%.2f',EO_disp),'-'));
    pause(1)

    w0 = 2*pi*c/(lambda*1e-9);
    lambda_sweep = ifftshift(2*pi*c./(w+w0))*1e9;
    spec_simu = @(lambda)interp1(lambda_sweep,f1.getSpectrumDB,lambda); 

    %% fitting to experiment result
        idx = ~(LOCS>min(lambda_sweep) & LOCS<max(lambda_sweep) & LOCS<1670);
        LOCS(idx) = [];
        PKS(idx) = [];

    fminfun = @(offset)sum(abs(spec_simu(LOCS)-offset-PKS));
    [offset, residue] = fminsearch(fminfun,-max(PKS)+max(f1.getSpectrumDB) );

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
    
    good_flag = {};
    if residue/length(PKS) < 8 % if average residue small than 2 db
        if isfile(strcat(filedir,'good_flag.mat')) 
            load(strcat(filedir,'good_flag.mat'))
        end
        good_flag{end+1}=save_flag;
        save(strcat(filedir,'good_flag.mat'),'good_flag')
    end
end

