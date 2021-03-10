clear all; clc; close all; 
daqreset

%% Configurable input parameters
% Sweep start wavelength in nm
SweepStartWavelength=1520;  
% Sweep start wavelength in nm, SweepStopWavelength should be greater than
% SweepStartWavelength
SweepStopWavelength=1570;    
% Sweep scan velocity in nm/s, the maximum scan velocity is 20nm/s
SweepScanVelocity=2;
% If ForwardBackward is 1 the scan will executed in both directions and
% if is 0 the scan will executed only in forward direction
ForwardBackward=0;

%% Fix and calculated parameters
% Bit resolution is 15, the full bit resolution of NI USB is 16 bits in the
% range from -10V to 10V, but the wavelength input range is from 0V to 10V.
bits=15;    
MinWavelength=1520; % Minimum wavelength of laser equivalent to 0V
MaxWavelength=1570; % Maximum wavelength of laser equivalent to 10V

WavelengthStep=(MaxWavelength-MinWavelength)/2^bits;
VoltageStep=10/2^bits;
SweepStartVoltage=10*(SweepStartWavelength-MinWavelength)/...
    (MaxWavelength-MinWavelength);
SweepStopVoltage=10*(SweepStopWavelength-MinWavelength)/...
    (MaxWavelength-MinWavelength);
if ForwardBackward==0
    OutputSignal=SweepStartVoltage:VoltageStep:SweepStopVoltage;
else
    OutputSignal=[SweepStartVoltage:VoltageStep:SweepStopVoltage ...
             (SweepStopVoltage-VoltageStep):-VoltageStep:SweepStartVoltage];
end
OutputSamples=length(OutputSignal);
OutputTime=(SweepStopWavelength-SweepStartWavelength)/SweepScanVelocity;
OutputSampleRate=round(OutputSamples/OutputTime); 
% Input sample rate for Analog Inputs, the maximum is 400000 
InputSampleRate=100000; 

%%
ao = analogoutput('nidaq','Dev1');
addchannel(ao,0);
ao.SampleRate = OutputSampleRate;
ao.TriggerType = 'HwDigital';
ao.HwDigitalTriggerSource = 'PFI8';
ao

%%
ai = analoginput('nidaq','Dev1');
addchannel(ai,0);
ai.SampleRate = InputSampleRate;
ai.SamplesPerTrigger = InputSampleRate*OutputTime;
ai.TriggerType = 'Immediate';
ai.ExternalTriggerDriveLine = 'PFI8';
ai


%% Synchronize Analog Input and Analog Output Using PFI8 Signal
putsample(ao,SweepStartVoltage)
pause(2);
putdata(ao,OutputSignal)
start(ao)
start(ai)
wait([ai,ao],100)
[data,time] = getdata(ai);
plot(time * 1000,data)
xlim([0 20])
title('Wavelength')
xlabel('milliseconds')
ylabel('volts')

%%
ao.TriggerCondition = 'PositiveEdge';
putsample(ao,0)
putdata(ao,outputSignal)
start(ao)
start(ai)
wait([ai,ao],2)
[data,time] = getdata(ai);
plot(time * 1000,data)
xlim([0 20])
title('Synchronization using RTSI (Positive Edge)')
xlabel('milliseconds')
ylabel('volts')

%%
putsample(ao,0)
start(ai)
trigger(ai)
wait(ai,2)
[data,time] = getdata(ai);
plot(time * 1000,data)
title('Synchronization using RTSI (Positive Edge)')
xlabel('milliseconds')
ylabel('volts')
F=fft(data);
figure;
plot(abs(F));

%%
dio = digitalio('nidaq','Dev1')
addline(dio,0,0,'Out','Triger')
addline(dio,0,2,'In')
putvalue(dio.Line(1),1)
val3 = getvalue(dio.Line(2))

%%
delete(ao)
delete(ai)

