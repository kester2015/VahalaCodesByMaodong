clear all;
global Config Device;
% Set configuration for GUI
Config.Directory = 'C:\VisibleSoliton\data\201710_Oct\100317\';
Config.Condition = 'con1_pol1_f35_50mm';
Config.Wavelength = '778.65';
Config.MZI_FSR = '40.2346';
Config.Scan_start = '765';
Config.Scan_end = '785';
Config.ReverseScan = 1;
Config.Disk_FSR = '20000';
Config.D1 = '40.2346';
Config.D2 = '-8.5701e-8';
Config.D3 = '-1.0404e-14';
Config.Q.Srate = '4e6';
Config.Q.Scale = '0.005';
Config.D.Srate = '4e6';
Config.D.Scale = '0.3';
Config.Delay = '-2';

% hidden property
Config.trans_ch = 1;
Config.mzi_ch = 2;
Config.Current = 160;
Config.slewrate = 8;   %[nm/s]
Config.Scan_time = 5;  %[s]
Config.final = 778.65;  %[nm]

% Device
Device.laser1 = 'TLB6700';
Device.laser2 = 'TLB6700';
Device.osc = Infiniium('USB0::0x2A8D::0x9049::MY55510176::0::INSTR');
Device.osc.trigger_ch = 'CHAN3';
save('config.mat', 'Config', 'Device');