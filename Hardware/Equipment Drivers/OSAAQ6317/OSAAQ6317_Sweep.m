function OSAAQ6317_Sweep(OSA)
% Execute one single sweep of the Ando OSA, and wait unit it is done.
% Remember to close the instrument when finished with fclose(DEVICEOBJECT)
% D.E. Leaird, 27-Feb-05
% D.E. Leaird, 15-Nov-06...Added wait until sweep is complete

%Execute a single sweep
CmdToOSA = ['SGL' char(13)];
fprintf(OSA,CmdToOSA);

scanning = 1;
while (scanning ~= 0)
    pause(0.1);
    CmdToOSA = ['Sweep?' char(13)];
    fprintf(OSA,CmdToOSA);
    scanning = eval(fscanf(OSA));
end

end
