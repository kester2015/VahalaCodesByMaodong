function [Power, Wavelength] = OSAAQ6317_GetSpectrum(OSA)
% Read the Ando OSA, trace A, and return power as a function of wavelength.
% Remember to close the instrument when finished with fclose(DEVICEOBJECT)
% D.E. Leaird, 03-Jun-04

%Get vertical data
CmdToOSA = ['LDATA' char(13)];
fprintf(OSA,CmdToOSA);
temp = fscanf(OSA);
array = sscanf(temp,'%e,');
numpoints1 = array(1);
Power = array(2:length(array));

%Get horizontal data
CmdToOSA = ['WDATA' char(13)];
fprintf(OSA,CmdToOSA);
temp = fscanf(OSA);
array = sscanf(temp,'%e,');
numpoints2 = array(1);
Wavelength = array(2:length(array));

%Make sure both lengths agree)
if (numpoints1 == numpoints2)
   return
else
   Wavelength = 0;
   Power = 0;
   return
end