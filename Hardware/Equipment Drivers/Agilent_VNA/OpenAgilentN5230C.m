function deviceobject = OpenAgilentN5230C(gpibboardindex, deviceaddress)
% Prepare and open a GPIB object for the Agilent VNA.
% Use board GPIBBOARDINDEX, and electronics at address DEVICEADDRESS
% Returns DEVICEOBJECT that is used in subsequent calls.
% Remember to close the instrument when finished with fclose(DEVICEOBJECT)
%  Example call:  DEVOBJ = OpenAgilentN5230C(0,16);  0-> GPIB Board, 16-> VNA Address
% D.E. Leaird, 3-Nov-11
deviceobject = gpib('ni',gpibboardindex, deviceaddress, 'InputBufferSize', 500000, 'EOIMode', 'on', 'EOSCharCode', 'LF', 'EOSMode', 'none', 'Timeout', 30.0);
fopen(deviceobject)
