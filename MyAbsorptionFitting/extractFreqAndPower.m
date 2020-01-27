function [sweepFreq, EOMPower] = extractFreqAndPower(filename)
    filename = char(filename);
    tt = strsplit(filename,'_');
    sweepFreq = str2double( tt{end-2}(1:end-2) );
    EOMPower = str2double( tt{end}(1:end-5) );
end