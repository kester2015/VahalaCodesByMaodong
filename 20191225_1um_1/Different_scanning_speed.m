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
P_in = 1;
Offset = 1.0107;
Vpp = 0.1;
c = input(['Current offset setting: ', num2str(Offset), 'V\nPress [1](Yes) or other numbers to override\n']);
if c ~= 1
    Offset = input(['Please input new offset:']);
end
%%
Myfg.connect;
OSC.connect;
Myfg.DC2 = P_in;
Freq = [0.1 0.2	0.3 0.5	0.8	1.0	1.5	2.0	2.5	3.0	4.0	5.0	7.0	8.0 10 13 15 20	...
    30 50 80 100 300 500 800 1000];
Error_I = 0;
for m = 1 : length(Freq)
    for n = 1 : 3
        if Vpp/2 > Offset
            disp('Error! Negative voltage on laser piezo!!');
            pause;
        end
        if Offset > 4
            disp('Error! Too large offset!')
            pause;
        end
        Myfg.Freq1 = [Freq(m) Vpp Offset];
        Myfg.Phase1 = 90;
        pause(1);    
        OSC.Write([':TIM:POS ' num2str(1/Freq(m)*3/4)]);
        OSC.Write([':TIM:SCAL ' num2str(1/Freq(m)/20)]);
        OSC.Single;
        Myfg.Trigger1;
        pause(1/Freq(m)*1.5);
        pause(1);
        %%
        dip_x = str2num(OSC.Query(':MEAS:TMIN? CHAN3'));
        mid_x = 1/Freq(m)*3/4;
        %
        %
        filename = strcat('C:\Users\Administrator\Documents\APHI_D4_1um_1225\D', num2str(m), '_', num2str(n));
%         filename = 'test';
        OSC.write2osc(filename);
        %% Feedback on offset
        err = (dip_x - mid_x)/(1/Freq(m)/2);
        Error_I = Error_I*0.7 + err;
        Offset = Offset + 0.02*err + 0.004*Error_I;
        %% Display status 
        disp('===========================================');
        disp(strcat('Scanning number ', num2str(m), 'of ', num2str(length(Freq))));
        disp(strcat('Sub scanning number ', num2str(n), 'of 6'));
        disp(strcat('Frequency:', num2str(Freq(m)), 'Hz'));
        disp(strcat('Vpp:', num2str(Vpp*1e3), 'mV'));
        disp(strcat('Offset:', num2str(Offset), 'V'));
        disp(strcat('Voltage on AOM:', num2str(P_in), 'V'));
        disp('===========================================');
    end
end
%%
Myfg.disconnect;
Myfg.disconnect;
OSC.disconnect;
