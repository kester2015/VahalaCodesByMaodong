function DataSet = AgilentVNA(VNA_Addr)
%Matlab script to read, and save VNA data with auto filenaming
%similar to the scheme used with the OSA and FastScope programs.
%  The current directory is used to save data, and a file is created with
%  the last file number used.
% Example call:  data = AgilentVNA(16);  where 16 is the GPIB address.
%
%D.E. Leaird, 4-Nov-11
GPIB_Board = 0;
FileNumberFile = '.\VNAFiles.txt';

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

%Format the filename to be used (ADmmddyy.xxx):
LastFileNumber = LastFileNumber +1;
Today=date;
FileName=['VN' datestr(Today,'mm') datestr(Today,'dd') datestr(Today,'yy') '.' sprintf('%03i',LastFileNumber)];

%Get the data
VNAID = OpenAgilentN5230C(GPIB_Board,VNA_Addr);
DataSet = ReadAgilentN5230C(VNAID);
fclose(VNAID);
delete(VNAID);
clear VNAID

plot(DataSet(:,1)./1e9,DataSet(:,2))            %Plot the Magnitude
xlabel('Frequency (GHz)')
ylabel('S21 (dB)')

save(FileName,'DataSet','-ascii','-tabs','-double');
fprintf(1,'File saved as: %s\n',FileName);

%Save the file number
FileID = fopen(FileNumberFile,'w');
fprintf(FileID,'LastFile=%i',LastFileNumber);
fclose(FileID);
return