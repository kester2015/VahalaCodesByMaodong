
%% Open
[DAQ, DAQInfo] = NIUSB6212_Open('Dev3');

%% Write Value in Ch AO0
% Value = 0.45;
% tic;
% for i=1:10000
%     NIUSB6212_WriteSample(DAQ(1),Value);
% end
% toc

%% Write Value in Ch AO1
Value = 0.0;
for ii=1:DAQInfo.NumCh
    NIUSB6212_WriteSample(DAQ(ii),Value);
end

%% Close
NIUSB6212_Close(DAQ,DAQInfo);
clear DAQ DAQInfo


