close all
clear
clc
%% get resonance shift over temperature
filedirGlob1 = 'Z:\Qifan\Tantala\20200821\Dev21\dndT';
filedirGlob2 = 'Z:\Qifan\AlGaAs\20200916\dndTat1551';
filedirGlob3 = 'Z:\Qifan\SiN\20201004\dndTat1550.2';

% filedirGlob = filedirGlob2;
% material = 'SiN';
for thisfiledirGlob = {filedirGlob1, filedirGlob2, filedirGlob3}
filedirGlob = thisfiledirGlob{1};
matfiles = dir(strcat(filedirGlob,'\*.mat') );
matfilesName = {matfiles.name};

MZI_FSR = 39.9553; % MHz
ref_relative_pos = 0.5; % take the MZI at half position as reference 

temperatureList = zeros(1,length(matfilesName));
resonanceList = zeros(1,length(matfilesName));
for ii = 1:length(matfilesName)
     
    fileName = strcat(filedirGlob, '\', matfiles(ii).name);
    temperatureList(ii) = getTemperature(fileName);
    load(fileName,'X','Y');
    Trans_raw = Y(:,2);
    MZI_raw = Y(:,3);
    ref_pos = round( ref_relative_pos * length(MZI_raw) );
    
    MZIphase = MZI2Phase(MZI_raw);
    [~,dip_pos] = min(Trans_raw);
    phase_diff = MZIphase(ref_pos) - MZIphase(dip_pos);
    
    resonanceList(ii) = phase_diff/2/pi * MZI_FSR;%MHz
%         figure;
%         plot(MZI_raw);
%         hold on
%         plot(MZIphase);
end

coeff = polyfit(temperatureList,resonanceList,1);
fit_result = coeff(1)*temperatureList+coeff(2);
% figure
scatter(temperatureList,resonanceList);
hold on
plot(temperatureList,fit_result,'--','Linewidth',2);
xlabel('Temperature/C');
ylabel('Resonance pos/MHz');

resonance_shift = coeff(1);%MHz/C

% save(strcat('Z:\Qifan\absorption Q summary\dndT summary data\',material,'.mat'),'temperatureList','resonanceList','fit_result','coeff');


end
legend({'Tantala','','AlGaAs','','SiN',''});

%%
n0 = 1.8889;
% n0 = input("give neff of this material");
c = 299792458;
lambda = 1550.2e-9;
f = c/lambda;
nT = -n0/f*resonance_shift*1e6
%%
fprintf("resonance shift %f MHz/C \n",coeff(1));
fprintf("dn/dT is %f \n",nT);




function Temperature = getTemperature(filename)
    filename = char(filename);
    tt = strsplit(filename,'\');
    tt = tt{end};
    pp = strsplit(tt,'C');
    pp = pp{1};
%     tt = strsplit(tt,'-');
    Temperature = str2double( pp );
end

function phase = MZI2Phase(trace_MZI)
    trace_length = length(trace_MZI);
    trace_MZI_tofit = trace_MZI;
    % trace_MZI_tofit = sgolayfilt(trace_MZI, 1, 11);
    Base = (max(trace_MZI_tofit) + min(trace_MZI_tofit))/2;
    trace_MZI_phasor = hilbert(trace_MZI_tofit - Base); % use phasor for non-parametric fit

    trace_MZI_phase = [0; cumsum(mod(diff(angle(trace_MZI_phasor))+pi, 2*pi) - pi)] + angle(trace_MZI_phasor(1));
    % trace_MZI_phase = sgolayfilt(trace_MZI_phase, 1, 11);
    
    % phase = sgolayfilt(trace_MZI_phase, 2, round(trace_length/40)*2 + 1);
    phase = trace_MZI_phase;
end

function trans_FP = getFP(trans_raw)
    dim_temp =  size(trans_raw);
    if dim_temp(1)>dim_temp(2)
        trans_raw = trans_raw';
    end
    
    trans_phasor = hilbert(trans_raw);
    trans_length = length(trans_raw);
    trans_fp_phase = [0, cumsum(mod(diff(angle(trans_phasor))+pi, 2*pi) - pi)] + angle(trans_phasor(1));
    trans_phasor_imag = imag(trans_phasor);
    % [~,dip_pos] = max(abs(trans_phasor_imag));
    [~,dip_pos] = min(trans_raw);
    
    trans_amp_calculate_temp = trans_phasor_imag(1:max(1,dip_pos-trans_length/10));
    trans_amp_calculate_temp = [trans_amp_calculate_temp, trans_phasor_imag(min(dip_pos+trans_length/10,trans_length):end)];
    
    trans_base_calculate_temp = trans_raw(1:max(1,dip_pos-trans_length/10));
    trans_base_calculate_temp = [trans_base_calculate_temp, trans_raw(min(dip_pos+trans_length/10,trans_length):end)];
    
    FP_amp = (max(trans_amp_calculate_temp) - min(trans_amp_calculate_temp))/2;
    FP_base = mean(trans_base_calculate_temp);
    
    trans_FP = FP_base + FP_amp * cos(trans_fp_phase);
end







