function [VOA VOAInfo] = VOADD600MC_Open()

VOA = serial('COM1','Baudrate',9600,'Terminator','CR');
fopen(VOA);

fprintf(VOA,'RST');
VOAInfo.Echo = fscanf(VOA);
if strcmp(VOAInfo.Echo,char([82 83 84 13]))
    VOAInfo.Echo = fscanf(VOA);
end
VOAInfo.Model = fscanf(VOA);
VOAInfo.Version = fscanf(VOA);
VOAInfo.Serial = fscanf(VOA);
VOAInfo.MaxAtten = fscanf(VOA);
VOAInfo.Overshoot = fscanf(VOA);
VOAInfo.Calib = fscanf(VOA);
VOAInfo.GearRatio = fscanf(VOA);
VOAInfo.MotorVoltage = fscanf(VOA);
VOAInfo.MinInterval = fscanf(VOA);
VOAInfo.InsertionLoss = fscanf(VOA);
VOAInfo.Wavelength = fscanf(VOA);
VOAInfo.I2CAddress = fscanf(VOA);
VOAInfo.WO = fscanf(VOA);

fprintf(VOA,'E0');
VOAInfo.Echo = fscanf(VOA);
if strcmp(VOAInfo.Echo,char([10 69 48 13]))
    VOAInfo.Echo = fscanf(VOA);
end
VOAInfo.Echo = fscanf(VOA);

end
