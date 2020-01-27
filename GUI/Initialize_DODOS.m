clear all;
global Config Device;
load('config.mat')
% Set configuration for GUI
% Config.Directory = 'D:\BShen\20180327\LOWD2.26\New2\';
% Config.Condition = 'Taper2_pol2_f36_00';
Config.Wavelength = '1550';
Config.MZI_FSR = '5.9792';
Config.Scan_start = '1520';
Config.Scan_end = '1630';
Config.ReverseScan = 0;
Config.Disk_FSR = '15230';
Config.D1 = '187.5424';
Config.D2 = '9.907e-7';
Config.D3 = '-7.8130e-14';
Config.Scan = '1540:5:1575';
Config.Q.Srate = '4e6';
Config.Q.Scale = '0.005';
Config.D.Srate = '1e6';
Config.D.Scale = '1.2';
Config.Delay = '0.2';

% hidden property
Config.trans_ch = 1;
Config.mzi_ch = 2;
Config.mzi2_ch = 4;
Config.slewrate = 10;   %[nm/s]
Config.Scan_time = 25;  %[s]
Config.final = 1520;  %[nm]
Config.Current = 72;

% Device
Device.laser1 = NF6300();
Device.laser2 = TopticaDLC();
Device.osc = Infiniium('USB0::0x2A8D::0x9049::MY55510176::0::INSTR');
Device.osc.trigger_ch = 'CHAN3';
save ('config.mat', 'Config', 'Device');