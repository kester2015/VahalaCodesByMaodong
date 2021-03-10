function [Wavelength,Power] = ALM8164_Sweep(ALM,ALMInfo,SweepParameters)

LaserSource = ALMInfo.LaserSource;      
DetectorSource = ALMInfo.DetectorSource;
DetectorChannel = ALMInfo.DetectorChannel;

DetectorRange = SweepParameters.DetectorRange;
OutputPower = SweepParameters.OutputPower;
AvTime = SweepParameters.AvTime;
StartWavelength = SweepParameters.StartWavelength;
StopWavelength = SweepParameters.StopWavelength;
Step = SweepParameters.Step;
SweepSpeed = SweepParameters.SweepSpeed;

%Set the TLS to 0dBm
Command = ['SOURCE' num2str(LaserSource,'%1i') ':POWER ' num2str(OutputPower,'%0.0e') ' dBm' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source power');

%Set detector range 
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':POW:RANGE ' num2str(DetectorRange,'%2i') char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set det. power range');

%Set the detector averaging time
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':POW:ATIME ' num2str(AvTime,'%0.4f') char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set det. averaging time');

%Set the detector wavelength
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':POW:WAVE ' num2str(StartWavelength*1e-9,'%0.5e') char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set det. wavelength to Start');

%Set the sweep speed (selected previously)
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAV:SWE:SPE  ' num2str(SweepSpeed,'%0.0e') char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source sweep speed');

%Set the sweep start wavelength
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAV:SWE:STAR ' num2str(StartWavelength*1e-9,'%0.7e') char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source sweep wavelength Start');

%Set the sweep stop wavelength
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAV:SWE:STOP ' num2str(StopWavelength*1e-9,'%0.7e') char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source sweep wavelength Stop');

%Set the sweep wavelength step size
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAV:SWE:STEP  ' num2str(Step*1e-9,'%0.0e') char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set source sweep step');

%Query the number of expected data points
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAV:SWE:EXP?' char(10)];
fwrite(ALM,Command)
N = eval(fscanf(ALM));
CheckAgilent8164ESR(ALM,'read expected number of triggers');

%Check the status of the sweep setup
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':FUNC:STAT?' char(10)];
fwrite(ALM,Command)
Sense1FuncStat2 = fscanf(ALM);
CheckAgilent8164ESR(ALM,'check sense Func status');
if (~(strcmp(Sense1FuncStat2(1:length(Sense1FuncStat2)-1),'NONE,PROGRESS')))
    error('Failure starting the sweep....exiting!');
end

%Setup the detector logging operation with the number of points and
% averaging time
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':FUNC:PAR:LOGG ' num2str(N,'%0.0f') ',' num2str(AvTime,'%0.4f') char(10)];
fwrite(ALM,Command)

%Start the detector logging
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN' num2str(DetectorChannel,'%1i') ':FUNC:STAT LOGG,START' char(10)];
fwrite(ALM,Command)

%Ignore trigger inputs to the laser
Command = ['TRIG' num2str(LaserSource,'%1i') ':INP IGN' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set Trig0:inp ign');

%Generate a laser output trigger when a sweep step finishes
Command = ['TRIG' num2str(LaserSource,'%1i') ':OUTP STF' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set Trig0:outp stf');

%Turn On logging of wavelength values
Command = ['sour' num2str(LaserSource,'%1i') ':chan1:wav:swe:llogging on' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'start sweep');
Command = ['*OPC?' char(10)];
fwrite(ALM,Command)
Opc4 = eval(fscanf(ALM));
CheckAgilent8164ESR(ALM,'send *OPC? after starting sweep');

    
%Start the wavelength sweep
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAV:SWE:STATE 1' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'set sweep state 1');

%Check if the sweep is done...loop until it is
Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAV:SWE:STATE?' char(10)];
fwrite(ALM,Command)
SWSS = eval(fscanf(ALM));
CheckAgilent8164ESR(ALM,'query sweep state');
while (SWSS == 1)
    Command = ['SOURCE' num2str(LaserSource,'%1i') ':WAV:SWE:STATE?' char(10)];
    fwrite(ALM,Command)
    SWSS = eval(fscanf(ALM));
    CheckAgilent8164ESR(ALM,'query sweep state');
end

%Read the number of points
Command = ['sour' num2str(LaserSource,'%1i') ':read:points? llogging' char(10)];
fwrite(ALM,Command)
readpts = eval(fscanf(ALM));
CheckAgilent8164ESR(ALM,'read number of points');
if (readpts ~= N)
    tmpstr = ['Error in number of points returned by TLS (' num2str(readpts,'%i') ')!'];
    display(tmpstr);
end

%Read the wavelength values
Command = ['sour' num2str(LaserSource,'%1i') ':read:data? LLOGGING' char(10)];
fwrite(ALM,Command)
Wavelength = binblockread(ALM,'double');
%One more read (there's a terminator left in the buffer)...
test = fscanf(ALM);
CheckAgilent8164ESR(ALM,'read wavelength values');

%Confirm the detector logging operation completed
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN1:FUNC:STAT?' char(10)];
fwrite(ALM,Command)
SenseFuncStat = fscanf(ALM);
if (~(strcmp(SenseFuncStat(1:length(SenseFuncStat)-1),'LOGGING_STABILITY,COMPLETE')))
    error('Sweep did not complete as expected....exiting!');
end

%Read the power values
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN1:FUNC:RESULT?' char(10)];
fwrite(ALM,Command)
Power = binblockread(ALM,'single');
%One more read (there's a terminator left in the buffer)...
test = fscanf(ALM);
CheckAgilent8164ESR(ALM,'read power values');

%Turn off the logging function
Command = ['SENSE' num2str(DetectorSource,'%1i') ':CHAN1:FUNC:STAT LOGG,STOP' char(10)];
fwrite(ALM,Command)
CheckAgilent8164ESR(ALM,'disable logging function');


%Convert to nm and dBm units...regardless of the earlier settings, it
% appears that the returned values are meters and Watts
Wavelength = Wavelength./1e-9;
Power = real(10.*log10(Power./1e-3));       %use Real because otherwise the result is imaginary (why?)
