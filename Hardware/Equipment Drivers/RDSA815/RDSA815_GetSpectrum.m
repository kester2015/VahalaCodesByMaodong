function [Power Freq] = RDSA815_GetSpectrum(ESA,Trace)
% Read the Rigol RF Spectrum Analyzer; trace must be in the range 1..4
%  Example Call:  CombinedMatrix = ReadRigolDSA815(ESA,1);
% D.E. Leaird 9-Sep-12

if ((Trace < 1) || (Trace > 4))
    fprintf(1,'Trace must be in the range 1..4!  Exiting...\n');
    return
end

%Set the data format to REAL
fprintf(ESA,':FORMAT:TRACE:DATA REAL\n');

%Query the Trace data (for the specific Trace set by the user)
Cmd = [':TRACE:DATA? TRACE' num2str(Trace,'%1i') '\n'];
fprintf(ESA,Cmd);
Power = binblockread(ESA,'float32');

%Get the Start Frequency
fprintf(ESA,':SENSE:FREQUENCY:START?\n');
StartFreq = eval(fscanf(ESA));

%Get the Stop Frequency
fprintf(ESA,':SENSE:FREQUENCY:STOP?\n');
StopFreq = eval(fscanf(ESA));

Freq  = (StartFreq:(StopFreq-StartFreq)/600:StopFreq)';       %601 data points

return