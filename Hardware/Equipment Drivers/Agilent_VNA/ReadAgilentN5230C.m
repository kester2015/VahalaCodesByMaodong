function [CombinedMatrix] = ReadAgilentN5230C(DevObj)
% Read the Agilent VNA, and return power and phase as a function of frequency.
% Remember to close the instrument when finished with fclose(DEVICEOBJECT)
%  Example call:  result = ReadAgilentN5230C(ScopeObj);
% D.E. Leaird, 4-Nov-11


%Get Trace Parameters - # Points, Start Freq. and Span
Cmd = ['SENS:SWE:POIN?' char(10)];                  %Get the number of points
fprintf(DevObj,Cmd);
NumPoints = fscanf(DevObj,'%e');

Cmd = ['SENS:FREQ:STAR?' char(10)];                  %Get Start Frequency
fprintf(DevObj,Cmd);
Startf = fscanf(DevObj,'%e');

Cmd = ['SENS:FREQ:SPAN?' char(10)];                  %Get Delta-Frequency
fprintf(DevObj,Cmd);
Spanf = fscanf(DevObj,'%e');

Freq = Startf + (0:NumPoints-1)'.*Spanf./(NumPoints-1);    %Generate Frequency axis

% Binary reads are causing errors for commands FOLLOWING the binary block
% read...
% Cmd = ['FORM:BORD SWAP' char(10)];                  %Swap the byte order for PC's (for block read)
% fprintf(DevObj,Cmd);
% Cmd = ['FORM:DATA REAL,64' char(10)];               %Set the format to 64bit real
% fprintf(DevObj,Cmd);

Cmd = ['FORM:DATA ASCII,0' char(10)];               %Set the format to ASCII
fprintf(DevObj,Cmd);

Cmd = ['CALC:PAR:SELECT CH1_S11_1' char(10)];       %Get the S21 Measurement
fprintf(DevObj,Cmd);

% Cmd = ['CALC:DATA? FDATA' char(10)];
% fprintf(DevObj,Cmd);
% Mag = binblockread(DevObj,'float64');

Cmd = ['CALC:FORM PHAS' char(10)];                  %Get the Phase
fprintf(DevObj,Cmd);

Cmd = ['CALC:DATA? FDATA' char(10)];
fprintf(DevObj,Cmd);
temp = fscanf(DevObj);                              %a string block is returned
Phase = sscanf(temp,'%e,');                         % extract to a numeric vector
clear temp

Cmd = ['CALC:FORM MLOG' char(10)];                  %Get the Magnitude
fprintf(DevObj,Cmd);

Cmd = ['CALC:DATA? FDATA' char(10)];
fprintf(DevObj,Cmd);
temp = fscanf(DevObj);                              %a string block is returned
Mag = sscanf(temp,'%e,');                           % extract to a numeric vector
clear temp

CombinedMatrix = [Freq Mag Phase];
return
