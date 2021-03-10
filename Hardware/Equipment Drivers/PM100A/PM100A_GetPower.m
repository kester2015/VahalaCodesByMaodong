function Power = PM100A_GetPower(PM)

fprintf(PM,'READ?'); 
Power = str2double(fscanf(PM));

end