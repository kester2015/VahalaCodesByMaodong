
close all
clear
clc
%%
filedir = "C:\Users\Lab\Documents\Maodong\20200127-broadeningFromOSC\1555nm-04";
fileToSaveDir = "C:\Users\Lab\Documents\Maodong\20200127-broadeningFromOSC\1555nm-04-mat";

binfiles = dir(strcat(filedir,'\*.bin') );
%%
for ii = 1:length(binfiles)
    filename = strcat(filedir, '\', binfiles(ii).name);
     
    [timeAxis, Ch1] = importAgilentBin(filename, 1);
    [~, Ch2] = importAgilentBin(filename, 2);
    [~, Ch3] = importAgilentBin(filename, 3);
    [~, Ch4] = importAgilentBin(filename, 4);
%     data1 = data1(1:100:end);
%     data2 = data2(1:100:end);
%     data5 = data5(1:100:end);
    tt = char(binfiles(ii).name);
    filenameTosave = strcat(fileToSaveDir ,"\" ,tt(1:end-4),'.mat');
    save(filenameTosave, 'timeAxis', 'Ch1', 'Ch2', 'Ch3', 'Ch4');
end


%% -----------same codes again-------------

close all
clear
clc

filedir = "D:\Measurement Data\ThermalBroadening_20200126\20200126-outofRange";
fileToSaveDir = "D:\Measurement Data\ThermalBroadening_20200126\20200126-outRangeMat";

binfiles = dir(strcat(filedir,'\*.bin') );

for ii = 1:length(binfiles)
    filename = strcat(filedir, '\', binfiles(ii).name);
     
    [timeAxis, Ch1] = importAgilentBin(filename, 1);
    [~, Ch2] = importAgilentBin(filename, 2);
    [~, Ch3] = importAgilentBin(filename, 3);
    [~, Ch4] = importAgilentBin(filename, 4);
%     data1 = data1(1:100:end);
%     data2 = data2(1:100:end);
%     data5 = data5(1:100:end);
    tt = char(binfiles(ii).name);
    filenameTosave = strcat(fileToSaveDir ,"\" ,tt(1:end-4),'.mat');
    save(filenameTosave, 'timeAxis', 'Ch1', 'Ch2', 'Ch3', 'Ch4');
end