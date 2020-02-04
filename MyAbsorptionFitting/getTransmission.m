
function trans = getTransmission(filename)
    % filename = strcat(filedir, '\', matfiles(ii).name);
    load(filename,'Ch2');
    minCh2 = min(Ch2);
    maxCh2 = max(Ch2);
    trans = minCh2/maxCh2;
end