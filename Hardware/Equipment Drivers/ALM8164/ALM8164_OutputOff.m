function ALM8164_OutputOff(ALM,ALMInfo)
% Status should be 1 or 0

Command = ['SOURCE' num2str(ALMInfo.LaserSource,'%1i') ':POW:STATE 0' char(10)];
fwrite(ALM,Command)

return