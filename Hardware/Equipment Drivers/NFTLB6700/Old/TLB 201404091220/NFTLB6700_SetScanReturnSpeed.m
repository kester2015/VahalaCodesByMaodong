function [ Error ] = NFTLB6700_SetScanReturnSpeed(DeviceID, ReturnSpeed )
% NFTLB6700_SetScanReturnSpeed Set return speed for the scaning mode of the 
% laser with DeviceID.
% DeviceID: Integer with the ID of the device returned in string Info by the 
%           function NFTLB6700_Open.     
% ReturnSpeed: Scaning return speed in nanometers per second.
% Error: Return 0 if succesfull.
% 20140409 J.A. Jaramillo (Initial release)

Cmd = char([int8('SOURce:WAVE:SLEW:RETurn ') int8(num2str(ReturnSpeed)) int8(13) int8(10)]);
[~, CmdAck] = calllib('usbdll','newp_usb_send_ascii',DeviceID,Cmd,length(Cmd));
if strcmp(Cmd,CmdAck)
    [~, CmdAns, ~] = calllib('usbdll','newp_usb_get_ascii',DeviceID,blanks(10),10,10);
else
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
end
CmdAns = CmdAns(1:strfind(CmdAns,[int8(13) int8(10)])-1);
if strcmp(CmdAns,'OK')
    Error = 0;
else
    display(strcat('Error: The scan return speed is not in the operation range'));
    Error = 1;
end
    
end

