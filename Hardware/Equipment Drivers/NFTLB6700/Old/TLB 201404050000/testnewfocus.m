%% Open
loadlibrary('usbdll.dll',@newfocustlb67000);
[~] = calllib('usbdll','newp_usb_init_system');

%%
[~, info] = calllib('usbdll','newp_usb_get_device_info',blanks(1024))


cmd = char([int8('*IDN?') int8(13) int8(10)]); 
[~, info2] = calllib('usbdll','newp_usb_send_ascii',1,cmd,length(cmd))
[~, info3, s] = calllib('usbdll','newp_usb_get_ascii',1,blanks(256),256,256)

cmd = char([int8('BEEP 2') int8(13) int8(10)]); 
[~, info2] = calllib('usbdll','newp_usb_send_ascii',1,cmd,length(cmd))
[~, info3, s] = calllib('usbdll','newp_usb_get_ascii',1,blanks(256),256,256)



%% Close
[~] = calllib('usbdll','newp_usb_uninit_system');
unloadlibrary('usbdll');