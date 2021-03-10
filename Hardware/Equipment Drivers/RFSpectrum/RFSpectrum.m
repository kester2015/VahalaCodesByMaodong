function DataSet = RFSpectrum(varargin)
%Matlab script to read, and save RF spectrum data with auto filenaming
%similar to the scheme used with the LabWindows OSA and FastScope programs.
%  The current directory is used to save data, and a file is created with
%  the last file number used.
% Example call:  data = RFSpectrum(18);   %where 18 is the GPIB address  OR
%                data = RFSpectrum(0,18); %where 0 is the GPIB board
%
%D.E. Leaird, 6-Aug-08, modified 4-Feb-09
% Modified 29-Apr-10 to make sure the file-count file is only looked for in
% the local directory; include the possibility to write multiple dates
% files in the same directory starting back at file 1; modify the function
% to include the gpib address as a parameter like all the other functions
% of this nature.
% Updated to allow for optional GPIB_Board; default is zero,
%  include tile in plot - 26-May-14

if ((nargin < 1) || (nargin > 2))
    fprintf(1,'Error, The number of parameters must be either 1 or 2!  Exiting.\n');
    return
end
if nargin == 1
    GPIB_Board = 0;
    RF_addr = varargin{1};
else
    GPIB_Board = varargin{1};
    RF_addr = varargin{2};
end
FileNumberFile = '.\RFSpecFiles.txt';

%See if any files have been saved in this directory (determined by the
%filenumber file being present) / get the last filenumber saved:
%FileID=fopen(FileNumberFile,'r');
%if (FileID == -1)   %The filenumber file does not exist - create it.
%    LastFileNumber = 0;
%    FileID = fopen(FileNumberFile,'w');
%    fprintf(FileID,'LastFile=%i',LastFileNumber);
%else
%    %See what the date of file creation was
%    temp=GetFileTime(FileNumberFile,'Local');
%    temp=temp.Write;
%    if (datenum(temp(1:3)) == today)  %This means the file was created today, and the index should be incremented
%        LastFileNumber = fscanf(FileID,'LastFile=%i');  %Read the index
%    else                %Start over with a new index.
%        LastFileNumber = 0;
%        FileID = fopen(FileNumberFile,'w');
%        fprintf(FileID,'LastFile=%i',LastFileNumber);
%    end
%end
%fclose(FileID);

%Format the filename to be used (RFmmddyy.xxx):
LastFileNumber = LastFileNumber +1;
Today=date;
%FileName=['RF' datestr(Today,'mm') datestr(Today,'dd') datestr(Today,'yy') '.' sprintf('%03i',LastFileNumber)];
FileName=[sprintf('%03i',LastFileNumber) '.' 'txt'];
%Get the data
RFID = OpenHP8563(GPIB_Board,RF_addr);
DataSet = ReadHP8563_V2(RFID);
fclose(RFID);
delete(RFID);
clear RFID

plot(DataSet(:,1)./1e9,DataSet(:,2))
xlabel('Frequency (GHz)')
ylabel('Power (dBm)')
title(FileName)

save(FileName,'DataSet','-ascii','-tabs','-double');
fprintf(1,'File saved as: %s\n',FileName);

%Save the file number
FileID = fopen(FileNumberFile,'w');
fprintf(FileID,'LastFile=%i',LastFileNumber);
fclose(FileID);
return




%%%%%%%%%%%%%%%%
%Sub-functions

function deviceobject = OpenHP8563(gpibboardindex, deviceaddress)
% Prepare and open a GPIB object for the HP RF Spectrum Analyzer.
% Use board GPIBBOARDINDEX, and electronics at address DEVICEADDRESS
% Returns DEVICEOBJECT that is used in subsequent calls.
% Remember to close the instrument when finished with fclose(DEVICEOBJECT)
%  Example call:  DEVOBJ = OpenHP8563(0,18);  0-> GPIB Board, 18-> HP Address
% D.E. Leaird, 27-Sep-04
deviceobject = gpib('ni',gpibboardindex, deviceaddress, 'InputBufferSize', 500000, 'EOIMode', 'on', 'EOSCharCode', 'LF', 'EOSMode', 'none', 'Timeout', 30.0);
fopen(deviceobject);
return


function CombinedMatrix = ReadHP8563_V2(DevObj)
% Read the HP Spectrum Analyzer (trace A), and return power as a function of frequency.
% Remember to close the instrument when finished with fclose(DEVICEOBJECT)
%  Example call:  [result] = ReadHP8563(ScopeObj);
% D.E. Leaird, 27-Sep-04; Modified 6-Aug-08

%Set Trace Data Format to Parameter Units
CmdToHP = ['TDF P;' char(10)];
fprintf(DevObj,CmdToHP);

%Get Trace Parameters - Start and Stop Freq.
CmdToHP = ['FA?;' char(10)];
fprintf(DevObj,CmdToHP);
Temp = fscanf(DevObj);                  %Buffer to hold return values
StartFreq = sscanf(Temp,'%e');            %Individual elements from the buffer

CmdToHP = ['FB?;' char(10)];
fprintf(DevObj,CmdToHP);
Temp = fscanf(DevObj);                  %Buffer to hold return values
StopFreq = sscanf(Temp,'%e');            %Individual elements from the buffer

freq  = StartFreq:(StopFreq-StartFreq)./600:StopFreq;       %601 data points
power = zeros(601,1);

%Acquire Trace
CmdToHP = ['TRA?;' char(10)];
fprintf(DevObj,CmdToHP);

Temp = fscanf(DevObj);                    %Buffer to hold return value
Result = sscanf(Temp,'%e,');              %Individual elements from the buffer
power = Result;

freq=freq';
CombinedMatrix = [freq power];
return
