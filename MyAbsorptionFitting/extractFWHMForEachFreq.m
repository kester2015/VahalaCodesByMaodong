close all
clear
clc
%%

filedir = "C:\Users\Lab\Documents\Maodong\20200127-broadeningFromOSC\1555nm-04-mat";
matfiles = dir(strcat(filedir,'\*.mat') );
extractFreq = 50; % Hz
FWHMList1 = zeros(length(matfiles),2);
jj = 1;
for ii = 1:length(matfiles)
    filename = strcat(filedir, '\', matfiles(ii).name);
    [sweepFreq, EOMPowerinput] = extractFreqAndPower(filename);
    if sweepFreq == extractFreq
        [~,FWHM] = getFWHM(filename);
        
        load(filename,'Ch1','Ch4');
        Ch1 = max(Ch1);
        Ch4 = max(Ch4);
        
        EOMPower = sqrt(Ch1*Ch4)*sqrt(5.731*0.5143)/sqrt(2.2779*2.3894) ;
        
        FWHMList1(jj,:) = [EOMPower FWHM];
        
        jj = jj + 1;
    end
end
FWHMList1 = sortrows(FWHMList1,1);


%%
% extractFreq = 30; % Hz
% FWHMList2 = zeros(6,2);
% jj = 1;
% for ii = 1:length(matfiles)
%     filename = strcat(filedir, '\', matfiles(ii).name);
%     [sweepFreq, EOMPower] = extractFreqAndPower(filename);
%     if sweepFreq == extractFreq
%         [~,FWHM] = getFWHM(filename);
%         FWHMList2(jj,:) = [EOMPower FWHM];
%         jj = jj + 1;
%     end
% end
% FWHMList2 = sortrows(FWHMList2,1);
% 
% %%
% extractFreq = 50; % Hz
% FWHMList3 = zeros(6,2);
% jj = 1;
% for ii = 1:length(matfiles)
%     filename = strcat(filedir, '\', matfiles(ii).name);
%     [sweepFreq, EOMPower] = extractFreqAndPower(filename);
%     if sweepFreq == extractFreq
%         [~,FWHM] = getFWHM(filename);
%         FWHMList3(jj,:) = [EOMPower FWHM];
%         jj = jj + 1;
%     end
% end
% FWHMList3 = sortrows(FWHMList3,1);


%%
hh = figure;
plot(FWHMList1(:,1),FWHMList1(:,2),'LineWidth',2.0);
% hold on
% plot(FWHMList2(:,1),FWHMList2(:,2),'LineWidth',2.0);
% hold on
% plot(FWHMList3(:,1),FWHMList3(:,2),'LineWidth',2.0);
% hold on
% legend({'10Hz','30Hz','50Hz'});
legend({'10Hz'});
xlabel('waveguide Power/mW');
ylabel('FWHM');

resultdataFileName1 = strcat(filedir,'\','FWHM.fig');
resultdataFileName2 = strcat(filedir,'\','FWHM.png');
savefig(hh,resultdataFileName1);
saveas(hh,resultdataFileName2);
