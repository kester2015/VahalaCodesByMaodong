
% close all
clear
clc

datadir = "Z:\Maodong\Projects\1380 absorption\20210306-2\RUN1\sweep";

datadir = "Z:\Maodong\Projects\1380 absorption\20210306-2\RUN3-1370\sweep";
sapoint = 1e5;

% allSubfolders = dir(datadir);


% filedir = strcat(datadir,'\',allSubfolders(kk).name);
%%
% filedir = "C:\Users\Lab\Documents\Maodong\20200203\test-1550nm";

% for kk = 1:length(allSubfolders)
    
%             filedir = strcat(datadir,'\',allSubfolders(kk).name);
            
            
            fileToSaveDir = strcat(datadir,'-mat');
            
%             if isfolder(fileToSaveDir)
%                 continue;
%             end
            
%             if ~isfolder(fileToSaveDir)
%                 mkdir(fileToSaveDir);
%             endgit 

            binfiles = dir( strcat(datadir,'\*.bin') );
            %%
%             for ii = 1:length(binfiles)
            while ~(isempty(binfiles))
                if ~isfolder(fileToSaveDir)
                    mkdir(fileToSaveDir);
                end
                
                binfiles = dir( strcat(datadir,'\*.bin') );
                [~,idx] = sort([binfiles.datenum]);
                binfiles = binfiles(idx);
                
                filename = strcat(datadir, '\', binfiles(1).name);
                tt = char(binfiles(1).name);
                filenameTosave = strcat(fileToSaveDir ,"\" ,tt(1:end-4),'.mat');
                while isfile(filenameTosave)  % if the first one is converted
                    binfiles(1) = []; % delete first one
                    if ~(isempty(binfiles))
                        filename = strcat(datadir, '\', binfiles(1).name); % check the next one
                        tt = char(binfiles(1).name);
                        filenameTosave = strcat(fileToSaveDir ,"\" ,tt(1:end-4),'.mat');
                    end
                end
                

                [timeAxis, Ch1] = importAgilentBin(filename, 1);
                [~, Ch2] = importAgilentBin(filename, 2);
                [~, Ch3] = importAgilentBin(filename, 3);
                [~, Ch4] = importAgilentBin(filename, 4);
                
                
            %     data1 = data1(1:100:end);
            %     data2 = data2(1:100:end);
            %     data5 = data5(1:100:end);
            
           
                if length(timeAxis) > sapoint
                        timeAxis = timeAxis(1:round(length(timeAxis)/sapoint):end);
                        Ch3= Ch3(1:round(length(Ch3)/sapoint):end);
                        Ch2 = Ch2(1:round(length(Ch2)/sapoint):end);
                        Ch4= Ch4(1:round(length(Ch4)/sapoint):end);
                        Ch1 = Ch1(1:round(length(Ch1)/sapoint):end);
                end
                
                save(filenameTosave, 'timeAxis', 'Ch1', 'Ch2', 'Ch3', 'Ch4');
                
                fprintf('%.0f files left to convert \n',length(binfiles));
                
            end

% end
%% -----------same codes again-------------

% close all
% clear
% clc
% 
% filedir = "D:\Measurement Data\ThermalBroadening_20200126\20200126-outofRange";
% fileToSaveDir = "D:\Measurement Data\ThermalBroadening_20200126\20200126-outRangeMat";
% 
% binfiles = dir(strcat(filedir,'\*.bin') );
% 
% for ii = 1:length(binfiles)
%     filename = strcat(filedir, '\', binfiles(ii).name);
%      
%     [timeAxis, Ch1] = importAgilentBin(filename, 1);
%     [~, Ch2] = importAgilentBin(filename, 2);
%     [~, Ch3] = importAgilentBin(filename, 3);
%     [~, Ch4] = importAgilentBin(filename, 4);
% %     data1 = data1(1:100:end);
% %     data2 = data2(1:100:end);
% %     data5 = data5(1:100:end);
%     tt = char(binfiles(ii).name);
%     filenameTosave = strcat(fileToSaveDir ,"\" ,tt(1:end-4),'.mat');
%     save(filenameTosave, 'timeAxis', 'Ch1', 'Ch2', 'Ch3', 'Ch4');
% end