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

%% Confirmation of offset settings


VEOM = 2.2;
% sweepFreq = 10:20:50;
sweepFreq = 50;

Vpp = 1.920;
Offset = -0.637;
% calibrate how is the coupling drifting
% Ch1 is input power, Ch4 is transmitted power.
filedir = 'C:\Users\Administrator\Documents\Maodong\20200127\drift';



for ii = 1:90
    filename = strcat(filedir, '\', num2str(ii), '.bin' );
    disp('===========================================');
    disp(strcat('Scanning number ', num2str(ii), ' of ', num2str(30) ) );
    
    
    Freq0 = sweepFreq(1);
    Myfg1.Freq1 =[Freq0 Vpp Offset];
    Myfg1.Phase1 = 90;
%         Myfg1.TriggerExt1;
    Myfg2.DC2 = VEOM(1);
    
    
    OSC.Write([':TIM:POS ' num2str(1/Freq0*3/4)]);
    OSC.Write([':TIM:SCAL ' num2str(1/Freq0/20)]);
    OSC.Single;
    pause(1);   
    Myfg1.Trigger1;
    pause(2);  
    
    OSC.write2osc(filename);
    disp(strcat('Scanning number ', num2str(ii), ' of ', num2str(30) ,' finished! ') );
    disp('===========================================');
    
    pause(60)
end




