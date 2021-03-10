function [ Error ] = NFTLB6700_SetWavelengthInput(DeviceID, WavelengthInput )
% NFTLB6700_SetWavelengthInput Set wavelength input mode on or off of laser with 
% DeviceID.
% DeviceID: Integer with the ID of the device returned in string Info by the 
%           function NFTLB6700_Open.     
% WavelengthInput: 0 for use the front panel wavelength, 1 for use the 
% voltage in the BNC coneector in the back panel.
% Error: Return 0 if succesfull.
% 20150914 J.A. Jaramillo (Initial release)

Cmd = char([int8('SYSTem:WINPut ') int8(num2str(WavelengthInput)) int8(13) int8(10)]);
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
        display(['Error: Value of WavelengthInput ', num2str(WavelengthInput), ...
            ' is not valid, should be 0 or 1.']);
    else
        display(strcat('Error: Command ', Cmd,' was not succesfull executed'));
    end
end

end

