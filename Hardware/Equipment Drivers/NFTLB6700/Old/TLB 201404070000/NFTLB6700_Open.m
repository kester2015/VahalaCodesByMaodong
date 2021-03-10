function [ Info ] = NFTLB6700_Open()
% SN 1087 Room SB005 
% SN 1094 Room SB010

if ~libisloaded('usbdll')
    loadlibrary('usbdll.dll',@NFTLB6700);
    [~] = calllib('usbdll','newp_usb_init_system');
    [~, Info] = calllib('usbdll','newp_usb_get_device_info',blanks(1024));
end

end