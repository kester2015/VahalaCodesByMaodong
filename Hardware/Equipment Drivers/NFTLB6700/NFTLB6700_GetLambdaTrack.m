function [ LambdaTrack ] = NFTLB6700_GetLambdaTrack(DeviceID)
% NFTLB6700_GetLambdaTrack Return the current of lambda track. 
% with DeviceID.
% DeviceID: Integer with the ID of the device returned in string Info by the 
%           function NFTLB6700_Open.     
% LmabdaTrack: 0 or 1.
% 20150914 J.A. Jaramillo (Initial release)

Cmd = char([int8('OUTPut:TRACk?') int8(13) int8(10)]);
[~, CmdAck] = calllib('usbdll','newp_usb_send_ascii',DeviceID,Cmd,length(Cmd));
if strcmp(Cmd,CmdAck(1:length(Cmd)))
    [~, CmdAns, ~] = calllib('usbdll','newp_usb_get_ascii',DeviceID,blanks(64),64,64);
else
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
end
CmdAns2 = CmdAns(1:strfind(CmdAns,[int8(13) int8(10)])-1);
LambdaTrack = str2double(CmdAns2);

end

