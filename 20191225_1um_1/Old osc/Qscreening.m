clc
clear
%%
instrreset;
% Channel 1: fiber laser piezo
% Channel 2: AOM frequency power

Myfg1 = Keysight33500('USB0::0x0957::0x2C07::MY52814912::INSTR'); % lower
Myfg2 = Keysight33500('USB0::0x0957::0x2607::MY52202388::INSTR'); % upper
% Ocsillascope
% OSC = Infiniium('USB0::0x2A8D::0x904E::MY54200105::INSTR');
OSC = Infiniium('GPIB1::7::INSTR',1); % = Device.osc;
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

VAOM = 0.05:0.01:1;

sweepFreq = 10;
Freq0=sweepFreq;
Vpp = 2.000;%1.920;
Offset = 1.523;%2.263;


Myfg2.DC1 = 2.19;

filedirToSave = "C:\Users\Administrator\Documents\Maodong\20200303\1560nm-2";


% OSC.Write(":DISK:MDIR  ""C:\Users\Administrator\Documents20\Maodong\20200223\1570nm-02""")
% OSC.makeDirOnOSC(filedirToSave);

%         OSC.Write([':TIM:POS ' num2str(1/50*3/4)]);
%         OSC.Write([':TIM:SCAL ' num2str(1/50/20)]);
%%
tic;
for m = 1 : length(VAOM)
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
%         Freq0 = sweepFreq(n);
%         Myfg1.Freq1 =[Freq0 Vpp Offset];
%         Myfg1.Phase1 = 90;
%         Myfg1.TriggerExt1;
        Myfg2.DC2 = VAOM(m);       
        
         
        OSC.Write([':TIM:POS ' num2str(1/Freq0*3/4)]);
        OSC.Write([':TIM:SCAL ' num2str(1/Freq0/20)]);
%         OSC.Write([':TIM:POS ' num2str(1/Freq0*1/2)]);
%         OSC.Write([':TIM:SCAL ' num2str(1/Freq0/10)]);
        OSC.Single;
        pause(2);   
        Myfg1.Trigger1;
%         Myfg2.Trigger1;
%         pause(1.5*20/Freq0);
                pause(4);  
%%
%         dip_x = str2num(OSC.Query(':MEAS:TMIN? CHAN3'));
%         mid_x = 1/Freq0*3/4;

%         filename = strcat(filedirToSave, '\Sweep_', num2str(Freq0), 'Hz_Power_', num2str(VAOM(m)),'V.bin');
%         OSC.write2osc(filename);

        [Xdata,Ydata] = OSC.readmultipletrace([1 2 3 4],1e5);
        
        
        
        
%         %% Control of frequency offset
%         err = (dip_x - mid_x)/(1/Freq0/2);
%         Error_I = Error_I*0.9 + err;
%         Offset = Offset + 0.05*err + 0.001*Error_I;
        %% Display status 
        disp('===========================================');
        disp(strcat('Scanning number ', num2str(m), ' of ', num2str(length(VAOM))));
        disp(strcat('Sub scanning number ', num2str(n), ' of 3'));
        disp(strcat('Sweep Frequency:', num2str(Freq0), 'Hz'));
        disp(strcat('Vpp:', num2str(Vpp*1e3), 'mV'));
        disp(strcat('Offset:', num2str(Offset), 'V'));
        disp(strcat('Voltage on EOM:', num2str(VAOM(m)), 'V'));
        disp('===========================================');
    end
end

t = toc;
disp(strcat("Finished in ", num2str(t/60), 'min'));
sound(sin(2*pi*25*(1:4000)/100));
% Myfg1.disconnect;
% Myfg2.disconnect;
% OSC.disconnect;