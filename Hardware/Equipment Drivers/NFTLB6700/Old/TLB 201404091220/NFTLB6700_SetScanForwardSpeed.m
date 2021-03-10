function [ Error ] = NFTLB6700_SetScanForwardSpeed(DeviceID, ForwardSpeed )
% NFTLB6700_SetScanForwardSpeed Set forward speed for the scaning mode of the 
% laser with DeviceID.
% DeviceID: Integer with the ID of the device returned in string Info by the 
%           function NFTLB6700_Open.     
% ForwardSpeed: Sacaning forward speed in nanometers per second.
% Error: Return 0 if succesfull.
% 20140409 J.A. Jaramillo (Initial release)

Cmd = char([int8('SOURce:WAVE:SLEW:FORWard ') int8(num2str(ForwardSpeed)) int8(13) int8(10)]);
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
    display(strcat('Error: The scan forward speed is not in the operation range'));
    Error = 1;
end
    
end

