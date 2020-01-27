clc
clear
%% 
instrreset;
% Channel 1: fiber laser piezo
% Channel 2: AOM frequency power
Myfg = Keysight33500('USB0::0x0957::0x2807::MY52402234::INSTR');
% Ocsillascope
OSC = Infiniium('USB0::0x2A8D::0x904E::MY54200105::INSTR');
%% 
Myfg.connect;
OSC.connect;
P_in = 1;
Offset = 1.;
Vpp = 0.5;
Freq  = 100;
points = 2.5e6;
Error_I = 0;
%%
c = input(['Current offset setting: ', num2str(Offset), 'V\nPress [1](Yes) or other numbers to override\n']);
if c ~= 1
    Offset = input(['Please input new offset:']);
end
for m = 1 : 10
    if Vpp/2 > Offset
        disp('Error! Negative voltage on laser piezo!!');
        pause;
    end
    if Offset > 4
        disp('Error! Too large offset!')
        pause;
    end
    Myfg.Freq1 = [Freq Vpp Offset];
    Myfg.Phase1 = 90;
    pause(1);    
    OSC.Write([':TIM:POS ' num2str(1/Freq*3/4)]);
    OSC.Write([':TIM:SCAL ' num2str(1/Freq/20/5)]);
    OSC.Single;
    Myfg.Trigger1;
    pause(1/Freq*1.5);
    pause(1);
    %%
    dip_x = str2num(OSC.Query(':MEAS:TMIN? CHAN3'));
    mid_x = 1/Freq*3/4;
    %
    %
    filename = strcat('C:\Users\Administrator\Documents\APHI_D4_1um_1225\Q_sfter_', num2str(m));
    OSC.write2osc(filename);
%     filename = 'test';
%     OSC.Write([':ACQ:POIN ', points]);
%     [~, Trans] = readtrace(OSC, 3, points);
%     [Time, MZI] = readmultipletrace(OSC, 4, points);
%     figure
%     hold on
%     plot(Time, Trans);
%     plot(Time, MZI);
    %% Feedback on offset
    err = (dip_x - mid_x)/(1/Freq/2);
    Error_I = Error_I*0.7 + err;
    Offset = Offset + 0.02*err + 0.004*Error_I;
    %% Display status 
    disp('===========================================');
    disp(strcat('Scanning number ', num2str(m), 'of 10'));
    disp(strcat('Frequency:', num2str(Freq), 'Hz'));
    disp(strcat('Vpp:', num2str(Vpp*1e3), 'mV'));
    disp(strcat('Offset:', num2str(Offset), 'V'));
    disp(strcat('Voltage on AOM:', num2str(P_in), 'V'));
    disp('===========================================');
end
%%
Myfg.disconnect;
Myfg.disconnect;
OSC.disconnect;