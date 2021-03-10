%% Initialize sesion
s = daq.createSession('ni');
s.addAnalogInputChannel('Dev1', 'ai0', 'Voltage');
s.addAnalogOutputChannel('Dev1', 'ao0', 'Voltage');

%% Generate data and acquire
outpuData=sin(linspace(0, 2*pi, 2500)');
s.queueOutputData (outpuData);
acquiredData = s.startForeground();
plot(acquiredData)