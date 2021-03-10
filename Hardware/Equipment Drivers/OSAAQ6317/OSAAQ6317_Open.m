function [OSA OSAInfo] = OSAAQ6317_Open(GPIBAddress, DeviceAddress)

OSA = gpib('ni',GPIBAddress, DeviceAddress, 'InputBufferSize', 500000, 'EOIMode', 'on', 'EOSCharCode', 'LF', 'EOSMode', 'none', 'Timeout', 30.0);
fopen(OSA);
fprintf(OSA,'*IDN?'); 
OSAInfo = fscanf(OSA);

end