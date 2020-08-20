laser1 = TLB6700();
fg1 = Keysight33500('USB0::0x0957::0x2C07::MY52814912::0::INSTR');
fg1.connect;
laser1.connect;


wlList = [];
for wl = 1545:0.25:1555
    fg1.CH1(0);
    laser1.Move2Wavelength(wl);
    fg1.CH1(1);
    screen = -1;
    while ~(screen==0||screen==1)
        screen = input(['Do you see mode at ' num2str(wl) 'nm?(0:no, 1:yes):']);
    end
    switch screen
        case 0
            continue
        case 1
            wlList = [wlList wl];
            disp(['wavelength: ' num2str(wlList) 'nm is valid.'])
            continue
    end
end
fg1.disconnect;
laser1.disconnect;