function [ Error ] = NFTLB6700_SetScanReduceReturnPower(DeviceID, ReduceReturnPower )
% NFTLB6700_SetScanReduceReturnPower Set the configuration of the power in the
% return segment of the scaning (when the scaning is going back form the stop 
% wavelength to the start wavelengthmode) of the laser with DeviceID.
% DeviceID: Integer with the ID of the device returned in string Info by the 
%           function NFTLB6700_Open.     
% ReduceReturnPower: 1 to reduce the output power, 0 to keep the power the same
%                    as forward segment.
% Error: Return 0 if succesfull.
% 20140409 J.A. Jaramillo (Initial release)

Cmd = char([int8('SOURce:WAVE:SCANCFG ') int8(num2str(ReduceReturnPower)) int8(13) int8(10)]);
[~, CmdAck] = calllib('usbdll','newp_usb_send_ascii',DeviceID,Cmd,length(Cmd));
if strcmp(Cmd,CmdAck(1:length(Cmd)))
    [~, CmdAns, ~] = calllib('usbdll','newp_usb_get_ascii',DeviceID,blanks(64),64,64);
else
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
end
CmdAns2 = CmdAns(1:strfind(CmdAns,[int8(13) int8(10)])-1);
if strcmp(CmdAns2,'OK')
    Error = 0;
else
    Error = 1;
    if strcmp(CmdAns2,'VALUE OUT OF RANGE')
        display(['Error: Configuration value of reduce return power ', num2str(ReduceReturnPower),...
            ' is not valid, should be 0 or 1.']);
    else
        display(strcat('Error: Command ', Cmd,' was not succesfull executed'));
    end
end

    
end

