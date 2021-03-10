% NFTLB6700_Close Close all the Newport devices opened by NFTLB6700_Open
% and unload the USB Newport library.
% 20140409 J.A. Jaramillo (Initial release)

if libisloaded('usbdll')
    [~] = calllib('usbdll','newp_usb_uninit_system');
    unloadlibrary('usbdll');
end