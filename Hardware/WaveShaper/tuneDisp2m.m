close all
center = 193.37;
bandpass = 0.2
disp2 = -5.9;
disp3 = 0;
ws.inverseAtten(OSAWavelength, OSAPower,-12,[center-bandpass/2, center+bandpass/2])
ws.thirdDispersion(disp2, disp3, center)

ws.plot_status

pause(0.1)
state = ws.write2WS;

if state == 0
    sound(sin(0.25*1:1500))
end