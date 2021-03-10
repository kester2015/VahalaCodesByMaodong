function [DAQ, DAQInfo] = NIUSB6212_Open(DeviceName)

DAQ(1) = analogoutput('nidaq', DeviceName);
addchannel(DAQ(1), 0);
DAQ(2) = analogoutput('nidaq', DeviceName);
addchannel(DAQ(2), 1);
% DAQ(3) = analogoutput('nidaq', 'Dev2');
% addchannel(DAQ(3), 0);
% DAQ(4) = analogoutput('nidaq', 'Dev2');
% addchannel(DAQ(4), 1);
DAQInfo.NumCh = 2;

end