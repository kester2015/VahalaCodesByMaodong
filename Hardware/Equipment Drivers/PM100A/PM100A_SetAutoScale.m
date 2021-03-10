function ASAns = PM100A_SetAutoScale(PM, AS)

fprintf(PM,['POWer:RANGe:AUTO ' num2str(AS)]); 
fprintf(PM,'POWer:RANGe:AUTO?'); 
ASAns = fscanf(PM);

end