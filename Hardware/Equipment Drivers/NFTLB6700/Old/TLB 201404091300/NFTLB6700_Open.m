function [ Info ] = NFTLB6700_Open()
% NFTLB6700_Open Load the Newport library for New Focus Tunable Laser TLB6700 
% and open all the Newport devices connected to any USB port. 
% Info: String with the information of all devices with the format 
% <DevID1>,<DevDescription1>;<DevID2>,<DevDescription2>;...
%
% Room SB005 TLB6728 SN 1087 1520nm - 1570nm
% Room SB010 TLB6712 SN 1094  765nm -  781nm
% 20140409 J.A. Jaramillo (Initial release)

if ~libisloaded('usbdll')
    loadlibrary('usbdll.dll',@NFTLB6700);
    [~] = calllib('usbdll','newp_usb_init_system');
    [~, Info] = calllib('usbdll','newp_usb_get_device_info',blanks(1024));
end

end