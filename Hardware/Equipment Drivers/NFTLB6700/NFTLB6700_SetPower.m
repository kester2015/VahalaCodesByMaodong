function [ Error ] = NFTLB6700_SetPower(DeviceID, Power )
% NFTLB6700_SetPower Set the output power of the laser with DeviceID. 
% DeviceID: Integer with the ID of the device returned in string Info by the 
%           function NFTLB6700_Open.  
% Power: Output power in mW.
% Error: Return 0 if succesfull.
% 20140710 J.A. Jaramillo (Initial release)

Cmd = char([int8('SOURce:POWer:DIODe ') int8(num2str(Power)) int8(13) int8(10)]);
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
        display(['Error: Value of power ', num2str(Power), ' is out of range']);
    else
        display(strcat('Error: Command ', Cmd,' was not succesfull executed'));
    end
end

    
end

