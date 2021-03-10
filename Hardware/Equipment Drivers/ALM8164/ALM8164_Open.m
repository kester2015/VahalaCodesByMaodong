function [ALM, ALMInfo] = ALM8164_Open(GPIBAddress, DeviceAddress)
% Agilent Ligthwave Multimeter 
LaserSource = 0;      
DetectorSource = 1;
DetectorChannel = 1;

ALMInfo.LaserSource = LaserSource;      
ALMInfo.DetectorSource = DetectorSource;
ALMInfo.DetectorChannel = DetectorChannel;

ALM = gpib('ni',GPIBAddress, DeviceAddress, 'InputBufferSize', 500000, 'EOIMode', 'on', 'EOSCharCode', 'LF', 'EOSMode', 'none', 'Timeout', 30.0);
fopen(ALM);
fprintf(ALM,'*IDN?'); 
ALMInfo.Info = fscanf(ALM);

%Check Min start wavelength
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAVE:SWE:STAR? MIN' char(10)];
fwrite(ALM,Command)
ALMInfo.MinWavelength = eval(fscanf(ALM));

%Check Max stop wavelength
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAVE:SWE:STAR? MAX' char(10)];
fwrite(ALM,Command)
ALMInfo.MaxWavelength = eval(fscanf(ALM));

%Check Min step size
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAVE:SWE:STEP:WIDT? MIN' char(10)];
fwrite(ALM,Command)
ALMInfo.MinStep = eval(fscanf(ALM));

%Check Max step size
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAVE:SWE:STEP:WIDT? MAX' char(10)];
fwrite(ALM,Command)
ALMInfo.MaxStep = eval(fscanf(ALM));


