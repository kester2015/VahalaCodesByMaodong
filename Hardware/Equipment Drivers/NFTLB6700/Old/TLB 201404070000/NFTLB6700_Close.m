if libisloaded('usbdll')
    [~] = calllib('usbdll','newp_usb_uninit_system');
    unloadlibrary('usbdll');
end