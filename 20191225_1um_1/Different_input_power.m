clc
clear

instrreset;
% Channel 1: fiber laser piezo
% Channel 2: AOM frequency power

Myfg1 = Keysight33500('USB0::0x0957::0x2C07::MY52814912::INSTR'); % lower
Myfg2 = Keysight33500('USB0::0x0957::0x2607::MY52202388::INSTR'); % upper
% Ocsillascope
% OSC = Infiniium('USB0::0x2A8D::0x904E::MY54200105::INSTR');
% OSC = Infiniium('USB0::0x2A8D::0x9049::MY55510176::INSTR',2);
OSC = Infiniium('USB0::0x2A8D::0x904E::MY54200105::INSTR',2); 


% OSC = Infiniium('GPIB1::7::INSTR',1); % = Device.osc;

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


% filedirToSave = ['\\131.215.238.124\Vahala Group\Qifan\Tantala\' datestr(now,'yyyymmdd') '-thermal-rawdata\1548nm-02'];
filedirToSave = ['Z:\Qifan\SiN\' datestr(now,'yyyymmdd') '-thermal-rawdata\No14\1555nm-02'];


% VAOM = 0.01:0.005:1;
% VAOM = [2.3:-0.1:2, 2:-0.01:0.7, 0.7:-0.1:0.3]; % new device: Optical attenuator
VAOM = [2.0:-0.1:0];

% Myfg2.DC1 = 0;

sweepFreq = [0.5];
Freq0=sweepFreq;
Vpp = 1.7;%3.5;%7.000; %2.000;%1.920;
Offset = +0.9;%3.5/2;%0.000; %1.523;%2.263;








if ~isfolder(filedirToSave)
    mkdir(filedirToSave);
end
% OSC.Write(":DISK:MDIR  ""C:\Users\Administrator\Documents20\Maodong\20200223\1570nm-02""")
% OSC.makeDirOnOSC(filedirToSave);
% OSC.makeDirOnOSC(filedirToSave);

%         OSC.Write([':TIM:POS ' num2str(1/50*3/4)]);
%         OSC.Write([':TIM:SCAL ' num2str(1/50/20)]);
%%
tic;

% OSC.Write([':TIM:POS ' num2str(1/Freq0*0.75)]);
% OSC.Write([':TIM:SCAL ' num2str(1/Freq0/2/10)]);
for n = 1 : length(sweepFreq)
    for m = 1 : length(VAOM)
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
        
        vacant_time = 1.1;
        
        Myfg1.Freq1 =[Freq0 Vpp Offset];
        Myfg1.Phase1 = 90;
        Myfg1.Write(['BURS:INT:PER ' num2str(1/Freq0 * vacant_time)]);
%         Myfg1.Phase1 = 90;
%         Myfg1.TriggerExt1;
        Myfg2.DC2 = VAOM(m);       
        
        
        OSC.Write([':TIM:POS ' num2str(1/Freq0*0.75)]);
        OSC.Write([':TIM:SCAL ' num2str(1/Freq0/2/10)]);
        
        OSC.Write(':ACQ:SRAT:ANAL 2E+6');
        OSC.Write(':ACQ:POIN:ANAL AUTO');
        OSC.HighRes;
        pause(0.2);


%         OSC.Write([':TIM:POS ' num2str(1/Freq0*1/2)]);
%         OSC.Write([':TIM:SCAL ' num2str(1/Freq0/10)]);
        OSC.Single;
        pause(1); 
        
%         Myfg1.Phase1 = 90;
        pause(0.2);
        Myfg1.Trigger1;
        
%         Myfg2.Trigger1;
%         pause(1.5*20/Freq0);
        pause(1 + 1/Freq0 * vacant_time);  
        %%
%         dip_x = str2num(OSC.Query(':MEAS:TMIN? CHAN3'));
%         mid_x = 1/Freq0*3/4;
        %
        filename = strcat(filedirToSave, '\Sweep_', num2str(Freq0), 'Hz_Power_', num2str(VAOM(m)),'V.bin');
%          filename = 'test';

        OSC.write2osc(filename);

%         [Xdata Ydata] = OSC.readmultipletrace([1 2 3],1e5)
        
%         %% Control of frequency offset
%         err = (dip_x - mid_x)/(1/Freq0/2);
%         Error_I = Error_I*0.9 + err;
%         Offset = Offset + 0.05*err + 0.001*Error_I;
        %% Display status 
        disp('===========================================');
        disp(strcat('Scanning number :', num2str(m), ' of ', num2str(length(VAOM))));
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

Myfg2.DC2 = 1.0;
Myfg1.Freq1 =[Freq0 Vpp Offset];
OSC.Run;

OSC.Write([':TIM:POS ' num2str(1/Freq0*0.75)]);
OSC.Write([':TIM:SCAL ' num2str(1/Freq0/2/10)]);
% sound(sin(2*pi*25*(1:4000)/100));
tts('Measurement Completed');
Myfg1.disconnect;
Myfg2.disconnect;
OSC.disconnect;