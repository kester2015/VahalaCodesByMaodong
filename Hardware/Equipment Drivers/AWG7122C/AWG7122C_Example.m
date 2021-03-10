%%
% Open AWG in GPIBAddress 0 and DeviceAddress 26   
[AWG, AWGInfo] = AWG7122C_Open(0, 26);

%% Display Info
AWGInfo

%% Write a sin waveform
% N = 100000;
% t = (0:N-1)/(N-1);
% Waveform = 0.5*sin(2*pi*t)+0.5;
% plot(Waveform);
% Marker1 = zeros(1,N);
% Marker2 = zeros(1,N);
% WaveformName = 'SinJJ';
% AWG7122C_WriteWaveform(AWG, Waveform, Marker1, Marker2, WaveformName);

%% Write a DC waveform
N = 100000;
Waveform = 0.6*ones(1,N);
Marker1 = zeros(1,N);
Marker2 = zeros(1,N);
WaveformName = 'Switch_Command';
AWG7122C_WriteWaveform(AWG, Waveform, Marker1, Marker2, WaveformName);

%%
AWG7122C_Close(AWG);
clear AWG AWGInfo;
