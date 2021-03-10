function deviceobject = OpenEGG5110Lockin(gpibboardindex, deviceaddress)
% Prepare and open a GPIB object for the EG&G Lockin amplifer.
% Use board GPIBBOARDINDEX, and electronics at address DEVICEADDRESS
% Returns DEVICEOBJECT that is used in subsequent calls.
% Remember to close the instrument when finished with fclose(DEVICEOBJECT)
% D.E. Leaird, 27-Aug-03
deviceobject = gpib('ni',gpibboardindex, deviceaddress, 'EOIMode', 'off', 'EOSCharCode', 'CR', 'EOSMode', 'none', 'Timeout', 0.1);
fopen(deviceobject)