clear all;
global Config Device;
load('config.mat')
% Set configuration for GUI
% Config.Directory = 'D:\BShen\20180327\LOWD2.25\New4\';
% Config.Condition = 'Taper1_pol2';
Config.Wavelength = '1548.4';
Config.MZI_FSR = '5.9792';
Config.Scan_start = '1520';
Config.Scan_end = '1570';
Config.ReverseScan = 0;
Config.Disk_FSR = '15230';
Config.D1 = '187.5424';
Config.D2 = '9.907e-7';
Config.D3 = '-7.8130e-14';
Config.Scan = '1530:5:1565';
Config.Q.Srate = '4e6';
Config.Q.Scale = '0.005';
Config.D.Srate = '2e6';
Config.D.Scale = '0.7';
Config.Delay = '0.2';

% hidden property
Config.trans_ch = 1;
Config.mzi_ch = 2;
Config.mzi2_ch = 4;
Config.slewrate = 8;   %[nm/s]
Config.Scan_time = 10;  %[s]
Config.final = 1548.4;  %[nm]
Config.Current = 72;

% Device
Device.laser1 = NF6300();
Device.laser2 = NF6300();
Device.osc = Infiniium('USB0::0x2A8D::0x9049::MY55510176::0::INSTR');
Device.fg = Keysight33500('USB0::0x0957::0x2807::MY52402393::INSTR');
save ('config.mat', 'Config', 'Device');