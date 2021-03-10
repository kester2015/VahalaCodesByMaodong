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
    [~, CmdAns, S] = calllib('usbdll','newp_usb_get_ascii',DeviceID,blanks(64),64,64);
else
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
end
CmdAns2 = CmdAns(1:strfind(CmdAns,[int8(13) int8(10)])-1);
if strcmp(CmdAns2,'OK')
    Error = 0;
else
    Error = 1;
    if strcmp(CmdAns2,'VALUE OUT OF RANGE')
        display(['Error: Value of lambda track ', num2str(LambdaTrack), ...
            ' is not valid, should be 0 or 1.']);
    else
        display(strcat('Error: Command ', Cmd,' was not succesfull executed'));
    end
end

end

