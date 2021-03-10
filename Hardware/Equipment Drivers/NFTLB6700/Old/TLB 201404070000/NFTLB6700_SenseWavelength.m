function [ Wavelength ] = NFTLB6700_SenseWavelength( )

Cmd = char([int8('SENSe:WAVElength') int8(13) int8(10)]);
[~, CmdAck] = calllib('usbdll','newp_usb_send_ascii',1,Cmd,length(Cmd));
if strcmp(Cmd,CmdAck)
    [~, CmdAns, ~] = calllib('usbdll','newp_usb_get_ascii',1,blanks(10),10,10);
else
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
end
CmdAns = CmdAns(1:strfind(CmdAns,[int8(13) int8(10)])-1);
Wavelength = str2double(CmdAns);  
end

