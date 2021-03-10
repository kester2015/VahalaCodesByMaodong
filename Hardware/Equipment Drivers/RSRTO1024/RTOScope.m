function DataSet = RTOScope(IP_addr, Channel)
%Matlab script to read, and save Rohde & Schwarz RTO Scope data with auto filenaming
%similar to the scheme used with the LabWindows OSA and HP FastScope programs.
%Based on the AndoOSA Matlab function.
%  The current directory is used to save data, and a file is created with
%  the last file number used.
% Example call:  dataset = RTOScope('128.46.208.219',1);  % Reads channel
% 1 on IP address 128.46.208.219
%
%D.E. Leaird, 4-Oct-13
%Updated to include title in plot - 26-May-14

FileNumberFile = '.\RTOScopeFiles.txt';

%See if any files have been saved in this directory (determined by the
%filenumber file being present) / get the last filenumber saved:
FileID=fopen(FileNumberFile,'r');
if (FileID == -1)   %The filenumber file does not exist - create it.
    LastFileNumber = 0;
    FileID = fopen(FileNumberFile,'w');
    fprintf(FileID,'LastFile=%i',LastFileNumber);
else
    %See what the date of file creation was
    temp=GetFileTime(FileNumberFile,'Local');
    temp=temp.Write;
    if (datenum(temp(1:3)) == today)  %This means the file was created today, and the index should be incremented
        LastFileNumber = fscanf(FileID,'LastFile=%i');  %Read the index
    else                %Start over with a new index.
        LastFileNumber = 0;
        FileID = fopen(FileNumberFile,'w');
        fprintf(FileID,'LastFile=%i',LastFileNumber);
    end
end
fclose(FileID);

%Format the filename to be used (RDmmddyy.xxx):
LastFileNumber = LastFileNumber +1;
Today=date;
FileName=['RD' datestr(Today,'mm') datestr(Today,'dd') datestr(Today,'yy') '.' sprintf('%03i',LastFileNumber)];

%Get the data
RTOID = OpenRTOScope(IP_addr);
DataSet = ReadRTOScope(RTOID, Channel);
fclose(RTOID);
delete(RTOID);
clear RTOID

plot(DataSet(:,1),DataSet(:,2))
xlabel('Time (s)')
ylabel('Amplitude (V)')
title(FileName)
%Check to make sure there were not mutiple values in DataSet
[~,elm]=size(DataSet(:,2:end));
if (elm > 1)                    %Peak Detect mode was used
    hold on
    plot(DataSet(:,1),DataSet(:,3),'r')
end

save(FileName,'DataSet','-ascii','-tabs','-double');
fprintf(1,'File saved as: %s\n',FileName);

%Save the file number
FileID = fopen(FileNumberFile,'w');
fprintf(FileID,'LastFile=%i',LastFileNumber);
fclose(FileID);
return




%%%%%%%%%%%%%%%%
%Sub-functions
function deviceobject = OpenRTOScope(deviceaddress)
% Prepare and open a VISA object for the RTO Scope
% Returns DEVICEOBJECT that is used in subsequent calls.
% Remember to close the instrument when finished with fclose(DEVICEOBJECT)
%  Example call:  DEVOBJ = OpenRTOScope('128.46.208.219');  128.46.208.219 =
%                                        IP address of the scope
% D.E. Leaird, 4-Oct-13;
combined = strcat('TCPIP0::',deviceaddress,'::inst0::INSTR');
deviceobject = instrfind('Type', 'visa-tcpip', 'RsrcName', combined, 'Tag', '');
deviceobject = visa('NI', combined,'InputBufferSize',10000);
fopen(deviceobject)
fprintf(deviceobject,'*CLS');                     %Clear any previous device errors
return



function CombinedMatrix = ReadRTOScope(DevObj,Channel)
% Read the RTO scope on the specified channel, and return voltage as a function of time.
% Remember to close the instrument when finished with fclose(DEVICEOBJECT)
%  Example call:  data = ReadRTOScope(ScopeObj,1);
%  Possible channels include:  1,2,3,4
% D.E. Leaird, 4-Oct-13


%Make sure Channel is valid...
if ((Channel < 1) || (Channel > 4))
    fprintf(1,'Error!  Channel must be in the range [1..4]; exiting.\n');
    return
end

fprintf(DevObj,'FORM:DATA REAL,32');            %Set the data format to Real

Cmd = strcat('CHAN',num2str(Channel,'%1i'),':WAV1:DATA:HEAD?'); %Get the Waveform Header
temp = query(DevObj, Cmd);
header = sscanf(temp,'%e,%e,%e,%e');
XStart = header(1);                             % Start time
XStop = header(2);                              % Stop time
NumSamples = header(3);                         % Number of Samples
SamplesPerInterval = header(4);                 % Samples per interval
clear header temp Cmd

voltagebuffer = zeros(NumSamples*SamplesPerInterval,1);                  %Preallocate
Cmd = strcat('CHAN',num2str(Channel,'%1i'),':WAV1:DATA:VAL?');
fprintf(DevObj, Cmd);                           %Get the data values
test1 = fread(DevObj,1,'char');                 %  Returned in a Binary Block...first is #
test2 = fread(DevObj,1,'char');                 %     Second is number (non-zero) that indicates the number of elements that follow
test3 = fread(DevObj,eval(char(test2)),'char'); %     Third is the number of bytes that follow..after getting rid of these 'header bytes' the binary block can be read
NumBuffers = ceil(NumSamples * SamplesPerInterval ./ floor(DevObj.InputBufferSize/4));       %Due to the finite InputBufferSize, the entire record MAY not be able to be read at once
NumBuffers = NumBuffers * SamplesPerInterval;
for k=1:NumBuffers
    [buffer,cnt,~]= fread(DevObj,floor(DevObj.InputBufferSize/4),'float32');       %Read one buffer's worth
    if (cnt < floor(DevObj.InputBufferSize/4))
        voltagebuffer((k-1)*cnt+1:k*cnt) = buffer;
    else
        voltagebuffer((k-1)*floor(DevObj.InputBufferSize/4)+1:k*floor(DevObj.InputBufferSize/4)) = buffer;
    end
end

fprintf(DevObj,'*CLS');                         %Clear any device error due to an incomplete buffer

if (SamplesPerInterval > 1)
    voltage = zeros(NumSamples,2);              %Pre-allocate
    voltage(1:NumSamples,1) = voltagebuffer(1:2:end);   %'High' samples
    voltage(1:NumSamples,2) = voltagebuffer(2:2:end);   %'Low' samples
else
    voltage = voltagebuffer;
end

time=(XStart:(XStop-XStart)/NumSamples:XStop-(XStop-XStart)/NumSamples);

CombinedMatrix = [time' voltage];
return
