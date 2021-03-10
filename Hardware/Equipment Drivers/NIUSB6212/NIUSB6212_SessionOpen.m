function [DAQ, DAQInfo] = NIUSB6212_SessionOpen(DeviceName)

DAQ = daq.createSession('ni');
addAnalogOutputChannel(s,DeviceName,1,'Voltage');
DAQInfo.Rate = 250000;

end