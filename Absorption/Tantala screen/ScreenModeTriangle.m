


%!!!!!!!!!!!! Set lambda !!!!!!!!!!!

% lambda = 1553.4;
lambda = input('operation wavelength:')

global Config Device;

instrreset;
% Myfg1 = Keysight33500('USB0::0x0957::0x2C07::MY52814912::INSTR'); % lower
Myfg2 = Keysight33500('USB0::0x0957::0x2607::MY52202388::INSTR'); % upper
% OSC = Infiniium('USB0::0x2A8D::0x9049::MY55510176::INSTR',2);%1G
OSC = Infiniium('USB0::0x2A8D::0x904E::MY54200105::INSTR',2);%2.5G
% if ~Myfg1.isconnected
%     Myfg1.connect;
% end
if ~Myfg2.isconnected
    Myfg2.connect;
end
if ~OSC.isconnected
    OSC.connect;
end
%%

filedirGlob = 'Z:\Qifan\Tantala\20200906-Screen-Modes';
if ~isfolder(filedirGlob)
    mkdir(filedirGlob)
end

Q_measure_volt = 2.0; % FunctionGenerator voltage when measure Q
Tri_measure_volt = 0.3;
Q_measure_scale = [-0.1 0.7]; % OSC scale when measure Q
Tri_measure_scale = [-0.05 3.4];

% Piezo related settings
% sweep_Freq = 20;
% sweep_Vpp = 3.5;
% sweep_Offset = 0;

% Myfg1.Freq1 =[sweep_Freq Vpp Offset];
% OSC.Write([':TIM:POS ' num2str(1/sweep_Freq)]);
% OSC.Write([':TIM:SCAL ' num2str(1/sweep_Freq/20)]);

            % OSC related settings
            srate = 4e6; %(Sa/S)
            scale = 0.005; %(s/div)
            point = srate * 10 * scale;
            pd_offset = 3e-3; % PD noninput voltage

%             % Laser related settings
%             lambda = 1543.5; % nm
%             Device.laser1.Move2Wavelength(lambda);
            
            
% --2. Measure Tri at high power
OSC.SetVertScale(Config.trans_ch, Tri_measure_scale);
Myfg2.DC2 = Tri_measure_volt;
tridata_filename = strcat(filedirGlob,'\Tri-measure-maxvpp-',num2str(lambda),'nm');
                if isfile(strcat(tridata_filename,'.mat'))
                    backup_filename = strcat(tridata_filename,'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.mat');
                    movefile(strcat(tridata_filename,'.mat'),backup_filename);
                    warning('Old file was renamed!')
                end
                

pause(0.1);
input('please adjust attenuator:');
ReadTrace(tridata_filename,OSC,point,Config.trans_ch,Config.mzi_ch,0,pd_offset);
OSC.Run;
OSC.HighRes;


% -- 1. Measure Q factor at low power
Myfg2.DC2 = Q_measure_volt;
qdata_filename = strcat(filedirGlob,'\Q-measure-maxvpp-',num2str(lambda),'nm');

                if isfile(strcat(qdata_filename,'.mat'))
                    backup_filename = strcat(qdata_filename,'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.mat');
                    movefile(strcat(qdata_filename,'.mat'),backup_filename);
                    warning('Old file was renamed!')
                end


OSC.SetVertScale(Config.trans_ch, Q_measure_scale);
pause(0.1);
input('please adjust attenuator:');
ReadTrace(qdata_filename,OSC,point,Config.trans_ch,Config.mzi_ch,0,pd_offset);
OSC.Run;
OSC.HighRes;
%% Finally disconnect FG and OSC
Myfg2.disconnect;
OSC.disconnect;

%% Data processing
close all
qdata_filename = strcat(qdata_filename,'.mat');
tridata_filename = strcat(tridata_filename,'.mat');
%%
[mode_Q0,mode_Qe,~,~] = getQwithFP(qdata_filename,lambda,1);
trifit_result = fitTriwithFP(tridata_filename, mode_Q0,mode_Qe,lambda,1);


