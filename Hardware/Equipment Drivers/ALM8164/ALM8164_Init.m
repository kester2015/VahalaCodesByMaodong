function ALM8164_Init(ALM,ALMInfo)

LaserSource = ALMInfo.LaserSource;      
DetectorSource = ALMInfo.DetectorSource;
DetectorChannel = ALMInfo.DetectorChannel;

warning off instrument:fread:unsuccessfulRead

%Reset the device to make sure it's in a known mode...
ALM8164_Reset(ALM)
CheckAgilent8164ESR(ALM,'mainframe reset');

%Device clear
Command = ['*CLS' char(10)];
fwrite(ALM,Command)

%Set the Questionable Slot Status Enable Mask
Command = ['STAT:QUES:ENAB 32767' char(10)];
fwrite(ALM,Command)

%Set output path High
Command = ['OUTP' num2str(LaserSource,'%1i') ':PATH HIGH' char(10)];
fwrite(ALM,Command)
%Check command execution status
Command = ['*OPC?' char(10)];
fwrite(ALM,Command)
Opc = eval(fscanf(ALM));
if (Opc ~= 1)
    error('Error - Command execution status error.\n');
end

Command = ['STAT0:QUES:ENAB 32767' char(10)];
fwrite(ALM,Command)

Command = ['STAT1:QUES:ENAB 32767' char(10)];
fwrite(ALM,Command)

%Clear the mainframe
Command = ['*CLS' char(10)];
fwrite(ALM,Command)

%Set the TLS sweep mode to continuous
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAVE:SWE:MODE CONT' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set wavelength sweep mode CONT');

%Set output path High
Command = ['OUTP' num2str(LaserSource,'%1i') ':PATH HIGH' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set output path high');
%Check command execution status
Command = ['*OPC?' char(10)];
fwrite(ALM,Command)
Opc2 = eval(fscanf(ALM));
CheckAgilent8164ESR(ALM,'sending *OPC? #2');

%Set TLS to manual attenuation mode
Command = ['SOURCE' num2str(LaserSource,'%1i') ':POW:ATT:AUTO 0' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set power:att:auto 0');

%Set TLS to zero attenuation
Command = ['SOURCE' num2str(LaserSource,'%1i') ':POW:ATT 0' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set power:att 0');

%Set the TLS power unit to dBm
Command = ['SOURCE' num2str(LaserSource,'%1i') ':POWER:UNIT  0' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source power unit');

%Set TLS wavelength to Start
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAVE 1.5500e-06' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source wavelength to start');

%Set the TLS to 0dBm
Command = ['SOURCE' num2str(LaserSource,'%1i') ':POWER 6 dBm' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source power');

%Turn ON the TLS
Command = ['SOURCE' num2str(LaserSource,'%1i') ':POW:STATE 1' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'turn ON source');


%Disable Detector output triggers
Command = ['TRIG' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':OUTP DIS' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set trig(det) outp:dis');

%Perform one detector measurment
Command = ['TRIG' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':INP SME' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set trig(det) inp:sme');

%Set the detector wavelength
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':POW:WAVE 1.5500e-06' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set det. wavelength to Start');

%Set detector correction to zero
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':CORR 0' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set det. CORR 0');

%Turn OFF auto-range
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':POW:RANGE:AUTO  0' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set det. power range auto OFF');

%Set detector units
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':POW:UNIT  0' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set det. power unit');

%Set trigger software system to continuous measurment mode
Command = ['INIT' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':CONT 1' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set det. init:cont');

%Set trigger loopback configuration - any trigger at the output
% connector will automatically generate one at the input connector
Command = ['TRIG:CONF 3' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set trig:conf 3');

%Ignore input triggers
Command = ['TRIG' num2str(LaserSource,'%1i') ':INP IGN' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source trig:inp ign');

%Generate an output trigger when a sweep step finishes
Command = ['TRIG' num2str(LaserSource,'%1i') ':OUTP STF' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source trig:outp stf');

%Turn On logging of wavlength values
Command = ['sour' num2str(LaserSource,'%1i') ':chan1:wav:swe:llogging on' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source sweep on');

%Set the sweep mode to continuous
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAV:SWE:MODE CONT' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source sweep mode CONT');

%Set source repetition mode one one-way
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAV:SWE:REP ONEW' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source swee:rep ONEW');

%Set the number of sweep cycles to one
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAV:SWE:CYCL 1' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source sweep:cyc 1');

%Set the dwell time at each wavlength to zero (it's a continuous sweep)
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAV:SWE:DWEL 0' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source sweep:dwel 0');

%Turn Off the TLS
% TLSCommand = ['SOURCE' num2str(LSOURCE,'%1i') ':POW:STATE 0' char(10)];
% fwrite(gpibobject,TLSCommand)
% CheckAgilent8164ESR(gpibobject,'turn OFF source');

warning on instrument:fread:unsuccessfulRead


%Sub-function to check the ESR (to avoid the need for another script)
function err = CheckAgilent8164ESR(gpibobject,lstring)
% Check the Agilent mainframe for an error.  LSTRING is a string indicating
% where this check is being called from (to assist diagnostics).
TLSCommand = ['*ESR?'];
fwrite(gpibobject,TLSCommand)
err = eval(fscanf(gpibobject));
if (err ~= 0)       %This could be an endless loop, but we've never seen it...
    errstr = ['*ESR? returned ' num2str(err,'%3i') '!!  The error producing function is likely: ' lstring '.\n'];
    fprintf(1,errstr);
    fwrite(gpibobject,TLSCommand)
    err = fscanf(gpibobject);
end
return
