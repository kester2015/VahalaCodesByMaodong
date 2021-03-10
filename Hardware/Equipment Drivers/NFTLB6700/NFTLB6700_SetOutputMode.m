function [ Error ] = NFTLB6700_SetOutputMode(DeviceID, OutputMode )
% NFTLB6700_SetOutputMode Set the operation mode of laser to constant diode
% current or constant power.
% DeviceID.
% DeviceID: Integer with the ID of the device returned in string Info by the 
%           function NFTLB6700_Open.     
% OutputMode: 0 for the constant current output mode, 
%             1 for the constant power output mode.
% Error: Return 0 if succesfull.
% 20140710 J.A. Jaramillo (Initial release)

Cmd = char([int8('SOURce:CPOWer ') int8(num2str(OutputMode)) int8(13) int8(10)]);
[~, CmdAck] = calllib('usbdll','newp_usb_send_ascii',DeviceID,Cmd,length(Cmd));
if strcmp(Cmd,CmdAck)
    [~, CmdAns, S] = calllib('usbdll','newp_usb_get_ascii',DeviceID,blanks(64),64,64);
else
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
end
CmdAns2 = CmdAns(1:strfind(CmdAns,[int8(13) int8(10)])-1);
if (strcmp(CmdAns2,'OK')||strcmp(CmdAns2,'OUTPUT DISABLED DUE TO MODE CHANGE'))
    Error = 0;
else
    Error = 1;
    if strcmp(CmdAns2,'VALUE OUT OF RANGE')
        display(['Error: Value of output mode ', num2str(OutputMode), ...
            ' is not valid, it should be 0 for constant current or 1 for constant power.']);
    else
        display(strcat('Error: Command ', Cmd,' was not succesfull executed'));
    end
end

end

