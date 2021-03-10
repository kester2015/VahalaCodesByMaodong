function [ESA ESAInfo] = RDSA815_Open()

ESA = visa('ni','USB0::0x1AB1::0x0960::DSA8B141700163::INSTR','InputBufferSize',50000);
fopen(ESA);
fprintf(ESA,'*IDN?'); 
ESAInfo = fscanf(ESA);

return