function [ Error ] = NFTLB6700_SetOutputEnable(DeviceID, OutputEnable )
% NFTLB6700_SetOutputEnable Set enable the output of laser with DeviceID.
% DeviceID: Integer with the ID of the device returned in string Info by the 
%           function NFTLB6700_Open.     
% OutputMode: 0 to disable the laser output, 
%             1 to enable the laser output.
% Error: Return 0 if succesfull.
% 20140409 J.A. Jaramillo (Initial release)

Cmd = char([int8('OUTPut:STATe ') int8(num2str(OutputEnable)) int8(13) int8(10)]);
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
        display(['Error: Value of output mode ', num2str(OutputEnable), ...
            ' is not valid, it should be 0 to disable output or 1 to enable output.']);
    else
        display(strcat('Error: Command ', Cmd,' was not succesfull executed'));
    end
end

end

