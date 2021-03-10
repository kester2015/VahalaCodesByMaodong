function [PM PMInfo] = PM100A_Open(SN)

PM = visa('ni',strcat('USB0::0x1313::0x8079::',SN,'::INSTR'));
fopen(PM);
fprintf(PM,'*IDN?'); 
PMInfo = fscanf(PM);

end