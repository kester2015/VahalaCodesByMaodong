function [OSA OSAInfo] = OSAAQ6370C_Open(GPIBAddress, DeviceAddress)

OSA = gpib('ni',GPIBAddress, DeviceAddress, 'InputBufferSize', 5000000, 'EOIMode', 'on', 'EOSCharCode', 'LF', 'EOSMode', 'none', 'Timeout', 30.0);
fopen(OSA);
fprintf(OSA,'*IDN?'); 
OSAInfo = fscanf(OSA);

end