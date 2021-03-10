function ReturnVal = ReadEGG5110LockinMAG(DevObj)
% Read the lockin magnitude.
% Remember to close the instrument when finished with fclose(DEVICEOBJECT)
% D.E. Leaird, 27-Aug-03
% ReturnVal is a real number
CmdToLockin = ['MAG' char(13)];
fprintf(DevObj,CmdToLockin);
ReturnVal = str2num(fscanf(DevObj));
return