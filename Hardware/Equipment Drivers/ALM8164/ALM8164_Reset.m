function ALM8164_Reset(ALM)

Command = '*RST';
fwrite(ALM,Command)

return