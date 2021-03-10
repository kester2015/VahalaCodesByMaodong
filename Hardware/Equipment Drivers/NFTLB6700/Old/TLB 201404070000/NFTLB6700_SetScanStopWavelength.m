function [ Error ] = NFTLB6700_SetScanStopWavelength( StopWavelength )

Cmd = char([int8('SOURce:WAVE:STOP ') int8(num2str(StopWavelength)) int8(13) int8(10)]);
[~, CmdAck] = calllib('usbdll','newp_usb_send_ascii',1,Cmd,length(Cmd));
if strcmp(Cmd,CmdAck)
    [~, CmdAns, ~] = calllib('usbdll','newp_usb_get_ascii',1,blanks(10),10,10);
else
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
end
CmdAns = CmdAns(1:strfind(CmdAns,[int8(13) int8(10)])-1);
if strcmp(CmdAns,'OK')
    Error = 0;
else
    display(strcat('Error: The scan stop wavelength is not in the operation range'));
    Error = 1;
end
    
end
