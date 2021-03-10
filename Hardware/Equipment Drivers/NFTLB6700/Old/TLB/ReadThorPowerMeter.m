function power = ReadThorPowerMeter(pwrmtr)
% Read the Thor power meter
% D.E. Leaird 9-Sep-12

fprintf(pwrmtr,'READ?');
power = eval(fscanf(pwrmtr));
return