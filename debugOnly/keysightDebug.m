clc
clear
%%
instrreset;

Myfg = Keysight33500('USB0::0x0957::0x2807::MY52401300::INSTR');
Myfg.connect;
Myfg.DC1 = 0.1;
Myfg.CH1(0);