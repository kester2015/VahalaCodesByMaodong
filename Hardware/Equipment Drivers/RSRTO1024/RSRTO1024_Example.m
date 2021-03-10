%% Open
DeviceIP = '192.168.208.109';
[RTO, RTOInfo] = RSRTO1024_Open(DeviceIP);
display(RTOInfo);

%% Get channel data

%RSRTO1024_RunN(RTO,2);
[Voltage, Time] = RSRTO1024_ReadChannel(RTO,1);

h1 = figure;
plot(Time,Voltage)
xlim([min(Time) max(Time)]);
xlabel('Time');
ylabel('Voltage');

TimeStamp = datestr(now,'yyyymmddHHMMSS');
FileName = ['Comb_rest_11' TimeStamp];
save([FileName '.mat']);
%print(h, '-deps', [FileName '.eps']);
%print(h, '-dpng', [FileName '.png']);
%saveas(h, [FileName '.fig']);


[Voltage, Time] = RSRTO1024_ReadChannel(RTO,2);

h2 = figure;
plot(Time,Voltage)
xlim([min(Time) max(Time)]);
xlabel('Time');
ylabel('Voltage');

TimeStamp = datestr(now,'yyyymmddHHMMSS');
FileName = ['Reference_11' TimeStamp];
save([FileName '.mat']);

%% Get channel data
% M = 10;
% RSRTO1024_RunN(RTO,1);
% [Voltage, Time] = RSRTO1024_ReadChannel(RTO,2);
% N = size(Time);
% 
% Voltage = zeros(M,N);
% Time = zeros(M,N);
% for jj=1:M
%     RSRTO1024_RunN(RTO,1);
%     pause(3);
%     [Voltage(jj,:) Time(jj,:)] = RSRTO1024_ReadChannel(RTO,2);
% end
% 
% TimeStamp = datestr(now,'yyyymmddHHMMSS');
% FileName = [OutFolder ExperimentName '_' TimeStamp];
% save([FileName '.mat'],'Time','Voltage','Notes',...
%     'ExperimentName');
% 
% %%
% ii = 5;
% plot(Time(ii,:),Voltage(ii,:));

%% Close
RSRTO1024_Close(RTO);
clear RTO RTOInfo
