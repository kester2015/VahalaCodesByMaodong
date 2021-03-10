function [Power, Wavelength] = OSAAQ6370C_GetSpectrum(OSA,Trace)
% Read the Ando OSA, trace A, and return power as a function of wavelength.
% Remember to close the instrument when finished with fclose(DEVICEOBJECT)
% D.E. Leaird, 03-Jun-04

%Get vertical data
CmdToOSA = [':TRACe:Y? TR' Trace];   % Trace is a string for trace number, 'A'
fprintf(OSA,CmdToOSA);
temp = fscanf(OSA);
array = sscanf(temp,'%e,');
numpoints1 = length(array);
Power = array(1:length(array));

%Get horizontal data
CmdToOSA = [':TRACe:X? TR' Trace]; 
fprintf(OSA,CmdToOSA);
temp = fscanf(OSA);
array = sscanf(temp,'%e,');
numpoints2 = length(array);
Wavelength = array(1:length(array));

%Make sure both lengths agree)
if (numpoints1 == numpoints2)
   return
else
   Wavelength = 0;
   Power = 0;
   return
end