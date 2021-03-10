function [ Wavelength ] = NFTLB6700_SenseWavelength(DeviceID)
% NFTLB6700_SenseWavelength Return the current output wavelength of the laser 
% with DeviceID.
% DeviceID: Integer with the ID of the device returned in string Info by the 
%           function NFTLB6700_Open.     
% Wavelength: Output wavelength in nanometers.
% 20140409 J.A. Jaramillo (Initial release)

Cmd = char([int8('SENSe:WAVElength') int8(13) int8(10)]);
[~, CmdAck] = calllib('usbdll','newp_usb_send_ascii',DeviceID,Cmd,length(Cmd));
if strcmp(Cmd,CmdAck)
    [~, CmdAns, ~] = calllib('usbdll','newp_usb_get_ascii',DeviceID,blanks(10),10,10);
else
    display(strcat('Error: Command ', Cmd,' was not succesfull sent'));
end
CmdAns = CmdAns(1:strfind(CmdAns,[int8(13) int8(10)])-1);
Wavelength = str2double(CmdAns);  
end

