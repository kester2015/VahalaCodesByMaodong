%%
[OSA OSAInfo] = OSAAQ6317_Open(0, 1);

%%
%OSAAQ6317_Sweep(OSA);
[OSAPower, OSAWavelength] = OSAAQ6317_GetSpectrum(OSA);
figure
plot(OSAWavelength,OSAP);
%save('Lambda_1538p6815_best.mat','OSAPower','OSAWavelength');
%%
OSAAQ6317_Close(OSA);
clear OSA OSAInfo;
