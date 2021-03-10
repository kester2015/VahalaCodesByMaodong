function [RTO, RTOInfo] = RSRTO1024_Open(DeviceIP)
% '192.168.209.219'
NameString = strcat('TCPIP0::', DeviceIP, '::inst0::INSTR');
RTO = instrfind('Type', 'visa-tcpip', 'RsrcName', NameString, 'Tag', '');
RTO = visa('NI', NameString,'InputBufferSize',10000);
fopen(RTO);
fprintf(RTO,'*CLS');
fprintf(RTO,'*IDN?'); 
RTOInfo = fscanf(RTO);