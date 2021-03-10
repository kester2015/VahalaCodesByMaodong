function [ Error ] = NFTLB6700_SoftReset(DeviceID)
% NFTLB6700_SoftReset Perform asoft reset of the laser with DeviceID. 
% DeviceID: Integer with the ID of the device returned in string Info by the 
%           function NFTLB6700_Open.  
% Error: Return 0 if succesfull.
% 20140409 J.A. Jaramillo (Initial release)

Cmd = char([int8('*RST') int8(13) int8(10)]);
[~, CmdAck] = calllib('usbdll','newp_usb_send_ascii',DeviceID,Cmd,length(Cmd));
if strcmp(Cmd,CmdAck)
    Error = 0;
else
    Error = 1;
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
end

    
end

