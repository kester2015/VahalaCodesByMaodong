function ResetMM3000(gpibboardindex, deviceaddress)
% Used to reset the (slow) velocity that the MM3000 has after an Average2
% failure (typically due to an incorrect number of points).
% Example call:  ResetMM3000(0,9);
% D.E. Leaird, 4-Aug-2016

Stage = OpenMM3000(gpibboardindex, deviceaddress);
Cmd = ['SD1' char(13)];
fprintf(Stage, Cmd);
pause(0.1)

fclose(Stage);
delete(Stage);
clear Stage
return

function deviceobject = OpenMM3000(gpibboardindex, deviceaddress)
% Prepare and open a GPIB object for the Newport MM4006 driver.
% Use board GPIBBOARDINDEX, and electronics at address DEVICEADDRESS
% Returns DEVICEOBJECT that is used in subsequent calls.
% Remember to close the instrument when finished with fclose(DEVICEOBJECT)
% Example call: MMID = OpenMM3000(0,9);
% D.E. Leaird, 17-Aug-08
deviceobject = gpib('ni',gpibboardindex, deviceaddress, 'EOIMode', 'off', 'EOSCharCode', 'LF', 'EOSMode', 'none', 'Timeout', 10.0);
fopen(deviceobject)
pause(1);

Cmd = ['FI00' char(13)];
fprintf(deviceobject, Cmd);
pause(0.1);
return
