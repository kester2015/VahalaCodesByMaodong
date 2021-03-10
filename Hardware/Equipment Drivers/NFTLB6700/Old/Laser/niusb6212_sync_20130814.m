%% Synchronizing Analog Input and Output Using RTSI
% In R2008b, The Data Acquisition Toolbox(TM) added support for
% synchronization of devices using Programmable Function Interface (PFI)
% terminals and Real-Time System Integration (RTSI) bus.  These are both
% features of National Instruments(R) data acquisition hardware.
%
% For a complete list of hardware supported by the toolbox, visit the Data
% Acquisition Toolbox page at www.mathworks.com/products/daq
%%
%    Copyright 2008-2010 The MathWorks, Inc.
%    $Revision: 1.1.6.4 $  $Date: 2010/11/08 02:18:04 $

%%
% <html><hr><p><b>Note:</b> This can only be run using the 32-bit version of MATLAB(R) and
% Data Acquisition Toolbox(TM).  To learn more about using data acquisition
% devices on other platforms, see <a href="demo_compactdaq_intro.html">this demo</a><hr></html>

%%
% First, reset the toolbox.  This stops all running data acquisition
% objects from interfering with this demo. This code is usually not
% necessary outside this demo. 
daqreset

%% Synchronizing Analog Input and Output
% Often, you may need to synchronize the start of your analog
% output and analog input operations.  This is commonly done for
% stimulus/response testing.  This demonstration will discuss and evaluate
% several mechanisms available in the toolbox.

%% Connect to Hardware and Configure
% For the demonstration, we are using a National Instruments PCI-6229
% M-series device.  Channel 0 of the analog input subsystem is connected to
% channel 0 of the analog output subsystem.

%%
% Configure the data acquisition analog input subsystem.  Configure the
% subsystem to acquire 10,000 samples per second, 10 times faster than
% the analog output subsystem.  You will therefore be able to clearly see
% the analog output updates.
ai = analoginput('nidaq','Dev2');
addchannel(ai,0);
ai.SampleRate = 10000;
ai.SamplesPerTrigger = 10000;
ai

%%
% Configure the analog output subsystem
ao = analogoutput('nidaq','Dev2');
addchannel(ao,0);
ao.SampleRate = 1000;
ao

%% Synchronize Analog Input and Analog Output Using START
% Without any hardware coordination, there will be a delay between the
% start of the analog input and analog output. This represents the time to
% set up the operations.

% Make sure the analog output is at zero.  This ensures that we can clearly
% see when the analog output begins.
putsample(ao,0)

% Generate an output test signal (1Hz sine wave) and load test signal into
% the analog output buffer.
outputSignal = sin(linspace(0,pi*2,ao.SampleRate)');
putdata(ao,outputSignal)

% Start the acquisition and generation.  These two operations are
% not coordinated by hardware.  Because of the order in the brackets, the
% analog input is simply started before the analog output.
start([ai,ao])

% Wait up to two seconds to allow the operations to complete,
% and retrieve the results from the toolbox.
wait([ai,ao],2)
[data,time] = getdata(ai);

%%
% Plot the result. Notice that at the far left, there is a delay between
% the start of the analog input and the analog output.

% Multiply the time by 1000 to convert seconds to milliseconds.
plot(time * 1000,data)
title('Synchronization using START')
xlabel('milliseconds')
ylabel('volts')

%%
% When you zoom in, you see the delay was 4-5 milliseconds.
xlim([0 20])

%% Synchronize Analog Input and Analog Output Using a Manual TRIGGER
% We can minimize the delay in software using the TRIGGER command.
% This sets up the acquisition and generation ahead of time.  When the
% TRIGGER command is issued, the minimum amount of time is needed to start 
% the operations.

% Configure the subsystems for manual trigger mode.
ai.TriggerType = 'Manual';
ao.TriggerType = 'Manual';

% Make sure the analog output is at zero.
putsample(ao,0)

% Load test signal into the analog output buffer.
putdata(ao,outputSignal)

% Set up the acquisition and generation.  With TriggerType set to
% 'Manual', START configures everything possible except actually
% telling the hardware to begin.
start([ai,ao])

% Start the two subsystems. These two operations are not coordinated by
% hardware.
trigger([ai,ao])

wait([ai,ao],2)
[data,time] = getdata(ai);


%%
% Plot the result. Notice that the analog input system shows a smaller
% delay at the beginning.
plot(time * 1000,data)
xlim([0 20])
title('Synchronization using manual TRIGGER')
xlabel('milliseconds')
ylabel('volts')

%% Synchronize Analog Input and Analog Output Using RTSI Hardware
% To coordinate the analog input and output subsystems, there is an
% internal bus available on National Instruments devices called RTSI.
%
% RTSI can be used to synchronize two subsystems on the same card with
% no additional wiring.  In addition, you can use RTSI to synchronize
% multiple subsystems on multiple cards using a cable.
%
% You can eliminate the delay by coordinating the subsystems using the
% RTSI bus.  Configure the acquisition start to trigger the generation
% start in hardware.

%%
% Configure the subsystems to use RTSI. You will configure the analog input
% subsystem as the "master."  When it is started, it will send a pulse on
% the RTSI bus.  The analog output subsystem (the "slave") will detect the
% pulse on the RTSI bus, and start within nanoseconds.

%Set the analog input subsystem to start when the START command is issued.
ai.TriggerType = 'Immediate';

% Set the analog input system to signal on RTSI line 0 when it starts.
ai.ExternalTriggerDriveLine = 'RTSI0';

% Set the analog output system to receive its trigger from a
% hardware line, in this case, RTSI0.
ao.TriggerType = 'HwDigital';
ao.HwDigitalTriggerSource = 'RTSI0';

% Make sure the analog output is at zero.
putsample(ao,0)

% Load test signal into the analog output buffer.
putdata(ao,outputSignal)

%%
% Start the acquisition and generation.  Note that you must start
% the analog output
% *first*, since it must wait for the analog input to start.
start(ao)
start(ai)

wait([ai,ao],2)
[data,time] = getdata(ai);

%%
% Plot the result. Notice that the analog output has started *before* the
% analog input.  The first reading should have been zero.  By default, the
% default for analog output TriggerCondition is 'NegativeEdge', but RTSI
% lines operate active high.  The effect is that the trigger occurred at
% the *end* of the trigger pulse, rather than the beginning.
plot(time * 1000,data)
xlim([0 20])
title('Synchronization using RTSI (Negative Edge)')
xlabel('milliseconds')
ylabel('volts')

%%
% Repeat the test, with the AO TriggerCondition set to
% 'PositiveEdge' and repeat the acquisition.
ao.TriggerCondition = 'PositiveEdge';

% Make sure the analog output is at zero.
putsample(ao,0)

% Load test signal into the analog output buffer.
putdata(ao,outputSignal)

% Start the acquisition and generation again.
start(ao)
start(ai)

wait([ai,ao],2)
[data,time] = getdata(ai);

%%
% Plot the result. Now the analog output and analog input start
% simultaneously.
plot(time * 1000,data)
xlim([0 20])
title('Synchronization using RTSI (Positive Edge)')
xlabel('milliseconds')
ylabel('volts')

%%
% Clean up. When you are done with analog input objects, you must delete them to
% ensure that the hardware resources are released.
delete(ao)
delete(ai)

