%%
[OSA OSAInfo] = OSAAQ6370C_Open(0, 1);

%%
%OSAAQ6317_Sweep(OSA);
[OSAPower, OSAWavelength] = OSAAQ6370C_GetSpectrum(OSA,'G');  % 'G' for the trace to be saved
figure
plot(OSAWavelength*1e6,OSAPower); ylim([-80 -20]);
save('Chip_2_soliton4_52mW.mat','OSAPower','OSAWavelength');
%%
OSAAQ6370C_Close(OSA);
clear OSA OSAInfo;
