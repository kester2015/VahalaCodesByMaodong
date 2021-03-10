function [ Error ] = NFTLB6700_SetLambdaTrack(DeviceID, LambdaTrack )
% NFTLB6700_SetLambdaTrack Set lambda track mode on or off of laser with 
% DeviceID.
% DeviceID: Integer with the ID of the device returned in string Info by the 
%           function NFTLB6700_Open.     
% LambdaTrack: 0 for turning off the lambda track controller, 1 for turning on.
% Error: Return 0 if succesfull.
% 20140409 J.A. Jaramillo (Initial release)

Cmd = char([int8('OUTPut:TRACk ') int8(num2str(LambdaTrack)) int8(13) int8(10)]); 
[~, CmdAck] = calllib('usbdll','newp_usb_send_ascii',DeviceID,Cmd,length(Cmd));
if strcmp(Cmd,CmdAck)
    Error = 0;
else 
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
    Error = 1;
end

end

