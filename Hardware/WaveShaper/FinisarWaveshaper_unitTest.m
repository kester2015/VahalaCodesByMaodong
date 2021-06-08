
device_ws = FinisarWaveshaper('WS4');
device_ws.connect;
%%
close all
FiberL = -10;

fc =  193.353; % center freq, THz
bd = 0.56; % bandwidth, THz
fmin = fc - bd/2;
fmax = fc + bd/2;

device_ws.fiberDispersion(FiberL);
% device_ws.bandPass(fmin, fmax, 60, 'THz');
device_ws.bandStop(fmin, fmax, 60, 'THz');
device_ws.plot_status;
device_ws.plot_status('nm');

device_ws.write2WS;
%%
device_ws.disconnect;