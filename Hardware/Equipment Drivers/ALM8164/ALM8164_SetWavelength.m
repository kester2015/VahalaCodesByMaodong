function [Error] = ALM8164_SetWavelength(ALM,ALMInfo,Wavelength)
    
Command = ['SOURCE' num2str(ALMInfo.LaserSource,'%1i') ':WAVE  ' num2str(Wavelength*1e-9,'%0.7e') char(10)];
fwrite(ALM,Command);

    