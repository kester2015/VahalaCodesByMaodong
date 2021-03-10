function [Voltage, Time] = RSRTO1024_ReadChannel(RTO,Channel)
% Read the RTO scope on the specified channel, and return voltage as a function of time.
% Remember to close the instrument when finished with fclose(RTO)
%  Example call:  data = ReadRTOScope(RTO,1);
%  Possible channels include:  1,2,3,4
% D.E. Leaird, 4-Oct-13
% Jose Jaramillo, 5-Oct-15 Standarized Names


%Make sure Channel is valid...
if ((Channel < 1) || (Channel > 4))
    fprintf(1,'Error!  Channel must be in the range [1..4]; exiting.\n');
    return
end

fprintf(RTO,'FORM:DATA REAL,32');            %Set the data format to Real

Cmd = strcat('CHAN',num2str(Channel,'%1i'),':WAV1:DATA:HEAD?'); %Get the Waveform Header
temp = query(RTO, Cmd); 
header = sscanf(temp,'%e,%e,%e,%e');
XStart = header(1);                             % Start time
XStop = header(2);                              % Stop time
NumSamples = header(3);                         % Number of Samples
SamplesPerInterval = header(4);                 % Samples per interval
clear header temp Cmd

VoltageBuffer = zeros(NumSamples*SamplesPerInterval,1);                  %Preallocate
Cmd = strcat('CHAN',num2str(Channel,'%1i'),':WAV1:DATA:VAL?');
fprintf(RTO, Cmd);                           %Get the data values
test1 = fread(RTO,1,'char');                 %  Returned in a Binary Block...first is #
test2 = fread(RTO,1,'char');                 %     Second is number (non-zero) that indicates the number of elements that follow
test3 = fread(RTO,eval(char(test2)),'char'); %     Third is the number of bytes that follow..after getting rid of these 'header bytes' the binary block can be read
NumBuffers = ceil(NumSamples * SamplesPerInterval ./ floor(RTO.InputBufferSize/4));       %Due to the finite InputBufferSize, the entire record MAY not be able to be read at once
NumBuffers = NumBuffers * SamplesPerInterval;
for k=1:NumBuffers
    [buffer,cnt,~]= fread(RTO,floor(RTO.InputBufferSize/4),'float32');       %Read one buffer's worth
    if (cnt < floor(RTO.InputBufferSize/4))
        VoltageBuffer((k-1)*cnt+1:k*cnt) = buffer;
    else
        VoltageBuffer((k-1)*floor(RTO.InputBufferSize/4)+1:k*floor(RTO.InputBufferSize/4)) = buffer;
    end
end

fprintf(RTO,'*CLS');                         %Clear any device error due to an incomplete buffer

if (SamplesPerInterval > 1)
    Voltage = zeros(NumSamples,2);              %Pre-allocate
    Voltage(1:NumSamples,1) = VoltageBuffer(1:2:end);   %'High' samples
    Voltage(1:NumSamples,2) = VoltageBuffer(2:2:end);   %'Low' samples
else
    Voltage = VoltageBuffer;
end

Time=(XStart:(XStop-XStart)/NumSamples:XStop-(XStop-XStart)/NumSamples);
Time = Time';

