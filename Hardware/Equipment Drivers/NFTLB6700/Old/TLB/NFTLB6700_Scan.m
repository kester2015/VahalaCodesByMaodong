function [ Error ] = NFTLB6700_Scan(DeviceID, ScanParams )
% NFTLB6700_Scan Perform a scan in the laser with with DeviceID with the
% parameters given in the input structure Scan with the following
% definition:
% ScanParams.StartWavelength: Start wavelength.
% ScanParams.StopWavelength: Stop Wavelength.
% ScanParams.ForwardSpeed: Forward speed of the scan (From start to stop).
% ScanParams.ReturnSpeed: Return speed of the scan (From stop to start).
% ScanParams.NumScans: Number of desired scans.
% ScanParams.ReduceReturnPower: Configuration of the power in the return 
%                               segment, 1 to reduce the power, 0 to keep the 
%                               power the same as forward segment.
% Error: Return 0 if succesfull.
% 20140409 J.A. Jaramillo (Initial release)

NFTLB6700_SetScanStartWavelength(DeviceID, ScanParams.StartWavelength);
NFTLB6700_SetScanStopWavelength(DeviceID, ScanParams.StopWavelength);
NFTLB6700_SetScanForwardSpeed(DeviceID, ScanParams.ForwardSpeed);
NFTLB6700_SetScanReturnSpeed(DeviceID, ScanParams.ReturnSpeed);
NFTLB6700_SetScanNumScans(DeviceID, ScanParams.NumScans);
NFTLB6700_SetScanReduceReturnPower(DeviceID, ScanParams.ReduceReturnPower);

Cmd = char([int8('OUTPut:SCAN:START') int8(13) int8(10)]);
[~, CmdAck] = calllib('usbdll','newp_usb_send_ascii',DeviceID,Cmd,length(Cmd));
if strcmp(Cmd,CmdAck)
    [~, CmdAns, S] = calllib('usbdll','newp_usb_get_ascii',DeviceID,blanks(64),64,64);
else
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
end
CmdAns2 = CmdAns(1:strfind(CmdAns,[int8(13) int8(10)])-1);
if strcmp(CmdAns2,'OK')
    Error = 0;
else
    Error = 1;
    display(['Error: Command ', Cmd,' was not succesfull executed']);
end

   
end

