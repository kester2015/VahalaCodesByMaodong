function [AWG, AWGInfo] = AWG7122C_Open(GPIBAddress, DeviceAddress)
% Open Tektronics Arbitrary Waveform Generator AWG7122C
% GPIBAddress = 0;
% DeviceAddress = 26;
% Returns device handler AWG and device info AWGInfo 

AWG = gpib('ni',GPIBAddress, DeviceAddress, 'InputBufferSize', 1000000, 'OutputBufferSize', 1000000, 'EOIMode', 'on', 'EOSCharCode', 'LF', 'EOSMode', 'none', 'Timeout', 5.0);
fopen(AWG);
fprintf(AWG,'*IDN?'); 
AWGInfo = fscanf(AWG);
