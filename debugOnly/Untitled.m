clc
clear
%%
instrreset;
% Channel 1: fiber laser piezo
% Channel 2: AOM frequency powe
OSC = Infiniium('USB0::0x2A8D::0x904E::MY54200105::INSTR');
%%
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

filedirToSave = "C:\Users\Administrator\Documents\Maodong\20200226\test2";
% OSC.Write(":DISK:MDIR ""C:\Users\Administrator\Documents\Maodong\20200226""")
OSC.makeDirOnOSC(filedirToSave);
% OSC.Write(strcat(":DISK:MDIR ",filedirToSave))