function ALM8164_Close(ALM,ALMInfo)

LaserSource = ALMInfo.LaserSource;      
DetectorSource = ALMInfo.DetectorSource;
DetectorChannel = ALMInfo.DetectorChannel;

%Set the laser wavelength
%     TLSCommand = ['SOURCE' num2str(LSOURCE,'%1i') ':WAVE  ' num2str(startw*1e-9,'%0.3e') char(10)];
%     fwrite(gpibobject,TLSCommand)
%     CheckAgilent8164ESR(gpibobject,'set source wavelength after scan');

%Turn ON auto-range
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':POW:RANGE:AUTO  1' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set det. power range auto OFF');

%Ignore laser input triggers
Command = ['TRIG' num2str(LaserSource,'%1i') ':INP IGN' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source Trig:inp ign after sweep');

%Disable laser output triggers
Command = ['TRIG' num2str(LaserSource,'%1i') ':OUTP DIS' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source Trig:outp dis after sweep');

%Disable detector output triggers
Command = ['TRIG' num2str(DetectorSource,'%1i') ':CHAN1:OUTP DIS' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set det. Trig:outp dis after sweep');

%Ignore detector input triggers
Command = ['TRIG' num2str(DetectorSource,'%1i') ':CHAN1:INP IGN' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set det. Trig:inp ign after sweep');

%Set the default trigger connector configuration
Command = ['TRIG:CONF 1' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set Trig:conf 1');

Command = ['trig:conf:mfin 0' char(10)];             %I can't find this command in the documentation
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set trig:conf:mfin 0');

fclose(ALM);
delete(ALM);

end