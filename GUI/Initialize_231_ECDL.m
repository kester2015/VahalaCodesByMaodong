clear all;
global Config Device;
load('config.mat')
% Set configuration for GUI
Config.Directory = 'C:\Users\Lab\Documents\Qingxin\20191211\D56_11_C3\';
Config.Condition = 'pol1';
Config.Wavelength = '1556';
Config.MZI_FSR = '39.9553';
Config.Scan_start = '1520';
Config.Scan_end = '1570';
Config.ReverseScan = 0;
Config.Disk_FSR = '15230';
Config.D1 = '39.9553';
Config.D2 = '4.4967e-8';
Config.D3 = '-7.8130e-14';
Config.Q.Srate = '4e6';
Config.Q.Scale = '0.005';
Config.D.Srate = '2e6';
Config.D.Scale = '0.7';
Config.Delay = '0';

% hidden property
Config.trans_ch = 2;
Config.mzi_ch = 3;
Config.mzi2_ch = 3;
Config.slewrate = 8;   %[nm/s]
Config.Scan_time = 20;  %[s]
Config.final = 1556;  %[nm]
Config.Current = 100;
% Device
Device.laser1 = 'TLB6700';
Device.laser2 = 'TLB6700';
% Device.osc = Infiniium('GPIB1::7::INSTR',1);
Device.osc = Infiniium('USB0::0x2A8D::0x904E::MY54200105::INSTR');
% Device.fg = Keysight33500('USB0::0x0957::0x2807::MY52402234::INSTR');
save ('config.mat', 'Config', 'Device'); 
