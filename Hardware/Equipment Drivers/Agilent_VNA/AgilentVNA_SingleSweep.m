function DataSet = AgilentVNA_SingleSweep(VNA_Addr, Power, FrequencyStart, FrequencyEnd, IFBandwidth, NumofPoints, DwellTime)
% IFBandwidth choose from 10, 30, 100, 300, 1000, 3000, 3700, 6000
% cannot set dwell time
%Matlab script to read, and save VNA data with auto filenaming
%similar to the scheme used with the OSA and FastScope programs.
%  The current directory is used to save data, and a file is created with
%  the last file number used.
% Example call:  data = AgilentVNA(16);  where 16 is the GPIB address.
%
%D.E. Leaird, 4-Nov-11
GPIB_Board = 0;

%Get the data
VNAID = OpenAgilentN5230C(GPIB_Board,VNA_Addr);

%Set frequency start
Cmd = 'INIT:CONT OFF;*OPC?';               %Set the format to ASCII
fprintf(VNAID,Cmd);
fscanf(VNAID,Cmd);

Cmd = ['SOUR:POW1 ' sprintf('%d',Power) ';'];
fprintf(VNAID,Cmd);

%Set frequency start
Cmd = ['SENS:FREQ:STAR ' sprintf('%d',FrequencyStart) ';'];               %Set the format to ASCII
fprintf(VNAID,Cmd);

%Set frequency end
Cmd = ['SENS:FREQ:STOP' sprintf('%d',FrequencyEnd) ';'];               %Set the format to ASCII
fprintf(VNAID,Cmd);

%Set IF bandwidth
Cmd = ['SENS:BWID ' sprintf('%d',IFBandwidth) 'HZ;'];               %Set the format to ASCII
fprintf(VNAID,Cmd);

% 'number of points'

%Set Number of points
Cmd = ['SENS:SWE:POIN ' sprintf('%d',NumofPoints) ';'];               %Set the format to ASCII
fprintf(VNAID,Cmd);

% 'seting step mode'

%Set step mode
Cmd = ['SENS:SWE:GEN STEP' ';'];               %Set the format to ASCII
fprintf(VNAID,Cmd);

%Set dwell time
Cmd = ['SENS:SWE:DWEL ' sprintf('%f',DwellTime) ';'];               %Set the format to ASCII
fprintf(VNAID,Cmd);

% 'dwell time done'

Cmd = 'INIT;*OPC?';               %Set the format to ASCII
fprintf(VNAID,Cmd);
fscanf(VNAID,Cmd);

% 'reading data!!'
DataSet = ReadAgilentN5230C(VNAID);

Cmd = 'INIT:CONT ON;';               %Set the format to ASCII
fprintf(VNAID,Cmd);

Cmd = 'SENS:SWE:MODE CONT;';               %Set the format to ASCII
fprintf(VNAID,Cmd);

fclose(VNAID);
delete(VNAID);
clear VNAID

return

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
