clc
clear
%%
instrreset;
% Channel 1: fiber laser piezo
% Channel 2: AOM frequency power

Myfg1 = Keysight33500('USB0::0x0957::0x2C07::MY52814912::INSTR'); % lower
Myfg2 = Keysight33500('USB0::0x0957::0x2607::MY52202388::INSTR'); % upper
% Ocsillascope
OSC = Infiniium('USB0::0x2A8D::0x904E::MY54200105::INSTR');
%%
Myfg1.connect;
Myfg2.connect;
OSC.connect;
% P_in = [0.6:0.05:1.1]; 
% Offset = 1.0014;
% Vpp = 0.1;
% Freq0 = 0.1;
% Error_I = 0;
%% Confirmation of offset settings
% c = input(['Current offset setting: ', num2str(Offset), 'V\nPress [1](Yes) or other numbers to override\n']);
% if c ~= 1
%     Offset = input(['Please input new offset:']);
% end

VEOM = -1.1:0.1:2.2;

% sweepFreq = 10:20:50;
sweepFreq = 50;


Vpp = 1.920;
Offset = 2.263;

%         OSC.Write([':TIM:POS ' num2str(1/50*3/4)]);
%         OSC.Write([':TIM:SCAL ' num2str(1/50/20)]);
%%
for m = 1 : length(VEOM)
    for n = 1 : length(sweepFreq)
%         if Vpp/2 > Offset
%             disp('Error! Negative voltage on laser piezo!!');
%             pause;
%         end
%         if Offset > 4
%             disp('Error! Too large offset!')
%             pause;
%         end
%%
%         m=1;n=1;%for debug only
%%
        Freq0 = sweepFreq(n);
        Myfg1.Freq1 =[Freq0 Vpp Offset];
        Myfg1.Phase1 = 90;
%         Myfg1.TriggerExt1;
        Myfg2.DC2 = VEOM(m);       
        
        
        OSC.Write([':TIM:POS ' num2str(1/Freq0*3/4)]);
        OSC.Write([':TIM:SCAL ' num2str(1/Freq0/20)]);
        OSC.Single;
        pause(1);   
        Myfg1.Trigger1;
%         Myfg2.Trigger1;
%         pause(1.5*20/Freq0);
                pause(2);  
        %%
%         dip_x = str2num(OSC.Query(':MEAS:TMIN? CHAN3'));
%         mid_x = 1/Freq0*3/4;
        %
        filename = strcat('C:\Users\Administrator\Documents\Maodong\20200127\1555nm-04\Sweep_', num2str(Freq0), 'Hz_Power_', num2str(VEOM(m)),'V.bin');
%          filename = 'test';
        OSC.write2osc(filename);
%         %% Control of frequency offset
%         err = (dip_x - mid_x)/(1/Freq0/2);
%         Error_I = Error_I*0.9 + err;
%         Offset = Offset + 0.05*err + 0.001*Error_I;
        %% Display status 
        disp('===========================================');
        disp(strcat('Scanning number ', num2str(m), ' of ', num2str(length(VEOM))));
        disp(strcat('Sub scanning number ', num2str(n), ' of 3'));
        disp(strcat('Sweep Frequency:', num2str(Freq0), 'Hz'));
        disp(strcat('Vpp:', num2str(Vpp*1e3), 'mV'));
        disp(strcat('Offset:', num2str(Offset), 'V'));
        disp(strcat('Voltage on EOM:', num2str(VEOM(m)), 'V'));
        disp('===========================================');
    end
end
% Myfg1.disconnect;
% Myfg2.disconnect;
% OSC.disconnect;