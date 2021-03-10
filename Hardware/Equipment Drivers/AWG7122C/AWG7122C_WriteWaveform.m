function AWG7122C_WriteWaveform(AWG, Waveform, Marker1, Marker2, WaveformName)
%Write the Waveform, and marker data to the AWG - based on Tek AWG MATLAB
%ICT Send Waveform 3; 10-9-2009.
% awg is the instrumentID returned from the Open statement; remember to
% fclose(awg), and delete(awg) when all wavefroms have been written.
%  Requires typecast function (which is compiled from C).
% Modified by: D.E. Leaird 30-Mar-10; 26-May-10 update to delete previous
% versions of waveforms with same name.
%
% Example call:
% WriteTekAWG_Real(awg_id,Waveform,Marker1,Marker2,'WaveformName')
%
%% Notes
%{
% Waveform is not a voltage, but a scaling factor.  Maximum
% value is 1 while minimum value is -1. The resulting output voltage can be
% calculated by the following formula: my_real_wfm(sample) *
% (amplitude_setting/2) + offset_setting = output_voltage
%
% The real waveform type uses 5 bytes per sample while the integer type
% uses 2 bytes.
%
% The integer type allows for the most efficient and precise control of an
% AWG
%
% The real type allows for dynamic scaling of waveform data at run-time.
% This allows for math operations or changing bits of precision (i.e. AWG5k
% (14-bit) to/from AWG7k (8-bit), AWG7k 8-bit mode to/from AWG7k 10-bit
% mode) minimal degradation of waveform data.
%}

y = Waveform;
samples = length(y);
m1=Marker1;
m2=Marker2;

if ((min(y)<-1) || (max(y)>1))
    fprintf('1','Error, Waveform data is not scaled correctly, must be in the range -1:1.\n');
    return;
end
if ((min(m1)<0) || (max(m1)>1))
    fprintf('1','Error, Marker1 data is not scaled correctly, must be in the range 0:1.\n');
    return;
end
if ((min(m2)<0) || (max(m2)>1))
    fprintf('1','Error, Marker2 data is not scaled correctly, must be in the range 0:1.\n');
    return;
end
if (length(m1) ~= length(m2))
    fprintf(1,'Error, Marker1, and Marke21 must have the same length!\n');
    return;
end

 
% encode marker 1 bits to bit 6
m1 = bitshift(uint8(logical(m1)),6); %check dec2bin(m1(2),8)
% encode marker 2 bits to bit 7
m2 = bitshift(uint8(logical(m2)),7); %check dec2bin(m2(2),8)

% merge markers
m = m1 + m2; %check dec2bin(m(2),8)
clear m1 m2;
 
% stitch wave data with marker data as per progammer manual
binblock = zeros(1,samples*5,'uint8'); % real uses 5 bytes per sample...(single is four bytes)
for k=1:samples
    binblock((k-1)*5+1:(k-1)*5+5) = [typecast(single(y(k)),'uint8') m(k)];
end
clear y m;
 
% build binblock header
bytes = num2str(length(binblock));
header = ['#' num2str(length(bytes)) bytes];

% delete previous versions of the waveform
fwrite(AWG,[':wlist:waveform:delete "' WaveformName '"']);

% create waveform destination
fwrite(AWG,[':wlist:waveform:new "' WaveformName '",' num2str(samples) ',real;']);
 
% write waveform data
cmd = [':wlist:waveform:data "' WaveformName '",' header binblock ';'];
 
bytes = length(cmd);
if (samples >= bytes)
    %cmd
    fwrite(AWG,cmd)
else
    AWG.EOIMode = 'off';
    for i = 1:samples:bytes-samples
        %length(cmd(i:i+samples-1))
        fwrite(AWG,cmd(i:i+samples-1))
    end
    AWG.EOIMode = 'on';
    i=i+samples;
    %length(cmd(i:end))
    fwrite(AWG,cmd(i:end))
end
return