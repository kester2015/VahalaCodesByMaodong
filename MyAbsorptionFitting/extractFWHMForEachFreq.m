close all
clear
clc
%%

filedir = "D:\Measurement Data\ThermalBroadening_20200126\20200126-inRangeMat";

matfiles = dir(strcat(filedir,'\*.mat') );
%%
extractFreq = 10; % Hz
FWHMList1 = zeros(6,2);
jj = 1;
for ii = 1:length(matfiles)
    filename = strcat(filedir, '\', matfiles(ii).name);
    [sweepFreq, EOMPower] = extractFreqAndPower(filename);
    if sweepFreq == extractFreq
        [~,FWHM] = getFWHM(filename);
        FWHMList1(jj,:) = [EOMPower FWHM];
        jj = jj + 1;
    end
end
FWHMList1 = sortrows(FWHMList1,1);

%%
extractFreq = 30; % Hz
FWHMList2 = zeros(6,2);
jj = 1;
for ii = 1:length(matfiles)
    filename = strcat(filedir, '\', matfiles(ii).name);
    [sweepFreq, EOMPower] = extractFreqAndPower(filename);
    if sweepFreq == extractFreq
        [~,FWHM] = getFWHM(filename);
        FWHMList2(jj,:) = [EOMPower FWHM];
        jj = jj + 1;
    end
end
FWHMList2 = sortrows(FWHMList2,1);

%%
extractFreq = 50; % Hz
FWHMList3 = zeros(6,2);
jj = 1;
for ii = 1:length(matfiles)
    filename = strcat(filedir, '\', matfiles(ii).name);
    [sweepFreq, EOMPower] = extractFreqAndPower(filename);
    if sweepFreq == extractFreq
        [~,FWHM] = getFWHM(filename);
        FWHMList3(jj,:) = [EOMPower FWHM];
        jj = jj + 1;
    end
end
FWHMList3 = sortrows(FWHMList3,1);


%%
figure;
plot(FWHMList1(:,1),FWHMList1(:,2),'LineWidth',2.0);
hold on
plot(FWHMList2(:,1),FWHMList2(:,2),'LineWidth',2.0);
hold on
plot(FWHMList3(:,1),FWHMList3(:,2),'LineWidth',2.0);
hold on
legend({'10Hz','30Hz','50Hz'});
xlabel('EOM Power/V');
ylabel('FWHM');
