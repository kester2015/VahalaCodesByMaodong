classdef RhodeSchwarzRTOScope < handle
    %%% Intro: This is a class definition to program and control the Rhode
    %%% and Schwarz Oscilloscope
    %%% Libraries Used: None
    %%% Author: Nathan O'Malley, Jose Jaramillo-Villegas
    %%% Date: 7/6/2016
    %%% Organization: Ultrafast Optics and Optical Fiber Communications Laboratory, Purdue University
    
    properties(Constant)
        REQVER = '1.52.2.4'; %required version number
    end
    
    properties
        %You can change this
        SingleSamples = 1; %defines the number of sweeps executed when RunSingleSample() is called
        %%% These are set automatically
        Status = 0; %1 if the RTO has been opened correctly
        Channel = 0; %This will be the open RTO. Commands will be sent here.
        Version = 0; %The version number of the software
        SN = 0; %serial number of hardware
    end
    
    methods
        %% Initialization Functions
        function RTO = RhodeSchwarzRTOScope()
            %Function:
            %%% creates a copy of class type RhodeSchwarzeRTOScope
            %Inputs: 
            %%% None
            %Outputs:
            %%% RTO -- a new object of class RhodeSchwarzeRTOScope  
        end
        
        function res = Open(RTO, IP)
            %Function:
            %%% Opens and initializes the RTO software
            %Inputs: 
            %%% IP --
            %%%%% IP == the IP address of the oscilloscope as a string
            %Outputs:
            %%% res --
            %%%%% res == 0: open success
            %%%%% res == -1: open fail
            %%%%% res == -2: software version mismatch
            
            try
                RTO.Channel = visa('ni', ['TCPIP::', IP, '::INSTR']);
%                 RTO.Channel = visa('ni', ['USB0::0x1313::0x8079::',num2str(Sno),'::INSTR']);
%                 GPIBAddress = 0;
%                 DeviceAddress = 20;
%                 RTO.Channel = gpib('ni',GPIBAddress, DeviceAddress, 'InputBufferSize', 500000, 'EOIMode', 'on', 'EOSCharCode', 'LF', 'EOSMode', 'none', 'Timeout', 30.0);
                fopen(RTO.Channel);
                res = 0;
                RTO.Status = 1;
            catch
                'instrument:fopen:opfailed';
                res = -1;
                return;
            end
%             RTO.SN = Sno;
            version = RTO.GetVersion();
            txt = query(RTO.Channel, '*IDN?');
            RTO.SN = RTO.backwardstrsplit(txt(1:end-length(version), '/'));
            if(~strcmp(RTO.REQVER, version(1:length(RTO.REQVER))))
                res = -2;
            end
            RTO.Version = version;
            fprintf(RTO.Channel, 'Acquire:Count %d', RTO.SingleSamples);
%             fprintf(RTO.Channel, 'RunContinuous');
        end
        
        %% Equipment Info
        
        function softwareVersion = GetVersion(RTO)
            %Function:
            %%% Sends software version for the RTO
            %Inputs: 
            %%% None
            %Outputs:
            %%% softwareVersion --
            %%%%% softwareVersion == -1: the hardware was not properly
            %%%%% opened. sn will be returned as 0.
            %%%%% softwareVersion == the software version number as a
            %%%%% string
            
            if(RTO.Status == 0)
                softwareVersion = -1;
            else
                fprintf(RTO.Channel, '*IDN?');
                text = fscanf(RTO.Channel); 
                softwareVersion = RTO.backwardstrsplit(text, ',');
            end
        end
        
        %% Equipment Settings     
        
        function res = SetGain(RTO, Channel, Gain)
            %Function:
            %%% Sets the gain level for the given channel
            %Inputs: 
            %%% Channel --
            %%%%% Channel == 1-4: the channel for which the gain value is
            %%%%% being set.
            %%% Gain --
            %%%%% Gain == 100e-6 - 10: the amplification/attenuation factor
            %%%%% to apply to the input on the given channel
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == -2: Channel value invalid
            %%%%% res == -3: Gain value invalid
            %%%%% res == 0: operation successful
            
            if(RTO.Status == 0)
                res = -1;
            elseif(~sum(Channel == [1, 2, 3, 4])) 
                res = -2;
            elseif(Gain < 100e-6 || Gain > 10)
                res = -3;
            else
                fprintf(RTO.Channel, sprintf('Probe%d:Setup:Gain:Manual %.4f', Channel, Gain));
                res = 0;
            end
        end
        
        function res = SetTimeScale(RTO, scale)
            %Function:
            %%% Sets the scale for the x-axis in seconds per division. Note 
            %%% that this will also redefine the range (seconds / screen) 
            %%% such that the time range / 10 = the new scale.
            %Inputs: 
            %%% scale -- 
            %%%%% scale == the new x-axis scale in seconds per division.
            %%%%% Must be between 25e-12 and 50 seconds.
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == -2: invalid input
            %%%%% res == 0: operation successful
            
            if(RTO.Status == 0)
                res = -1;
            elseif(~(scale < 50 && scale > 25e-12))
                res = -2;
            else
                fprintf(RTO.Channel, [sprintf('Timebase:Scale %.12f', scale), char(13)]);
                res = 0;
            end
        end
        
        function res = SetTimeRange(RTO, range)
            %Function:
            %%% Sets the range for the x-axis in seconds. Note that this
            %%% will also redefine the scale (seconds / division) such that
            %%% 10 * the scale = the new time range.
            %Inputs: 
            %%% range -- 
            %%%%% range == the new x-axis range in seconds per screen.
            %%%%% Must be between 250e-12 and 500 seconds.
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == -2: invalid input
            %%%%% res == 0: operation successful
            
            if(RTO.Status == 0)
                res = -1;
            elseif(~(range < 500 && range > 250e-12))
                res = -2;
            else
                fprintf(RTO.Channel, [sprintf('Timebase:Range %.12f', range), char(13)]);
                res = 0;
            end
        end
        
        
        function res = SetVoltageScale(RTO, scale, channel)
            %Function:
            %%% Sets the scale for the y-axis in volts per division. Note 
            %%% that this will also redefine the range (volts / screen) 
            %%% such that the voltage range / 10 = the new scale.
            %Inputs: 
            %%% scale -- 
            %%%%% scale == the new y-axis scale in volts per division.
            %%%%% Must be between 1e-3 and 1 volts.
            %%% channel --
            %%%%% channel == the channel for which the voltage scale is
            %%%%% being set. must be between 1 and 4
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == -2: invalid input
            %%%%% res == 0: operation successful
            
            if(RTO.Status == 0)
                res = -1;
            elseif(~((scale <= 1 && scale >= 1e-3)&&(channel >= 1 && channel <= 4)))
                res = -2;
            else
                fprintf(RTO.Channel, [sprintf('Channel%d:Scale %.3f', channel, scale), char(13)]);
                res = 0;
            end
        end
        
        function res = SetVoltageRange(RTO, range, channel)
            %Function:
            %%% Sets the range for the y-axis in volts. Note that this
            %%% will also redefine the scale (volts / division) such that
            %%% 10 * the scale = the new volt range.
            %Inputs: 
            %%% range -- 
            %%%%% range == the new y-axis range in volts per screen.
            %%%%% Must be between 0.01 and 10 volts.
            %%% channel --
            %%%%% channel == the channel for which the voltage scale is
            %%%%% being set. must be between 1 and 4
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == -2: invalid input
            %%%%% res == 0: operation successful
            
            if(RTO.Status == 0)
                res = -1;
            elseif(~(range <= 10 && range >= 0.01))
                res = -2;
            else
                fprintf(RTO.Channel, [sprintf('Channel%d:Range %.2f', channel, range), char(13)]);
                res = 0;
            end
        end
        
        
        function res = SetRemoteState(RTO, state)
            %Function:
            %%% Sets whether the oscilloscope is in remote state or local
            %%% state. If in remote state, the buttons on the scope will
            %%% not work.
            %Inputs: 
            %%% state -- 
            %%%%% state == 0: The oscilloscope will be in local mode
            %%%%% state == 1: The oscilloscope will be in remote mode
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == -2: invalid input
            %%%%% res == 0: operation successful
            
            if(RTO.Status == 0)
                res = -1;
            else
                if(state == 0)
                    fprintf(RTO.Channel, ['&GTL', char(13)]);
                elseif(state == 1)
                    fprintf(RTO.Channel, ['&GTR', char(13)]);
                else
                    res = -2;
                    return
                end
                res = 0;
            end
        end
        
        function res = SetSampleRate(RTO, samples)
            %Function:
            %%% Sets the rate at which the oscilloscope will sample in
            %%% samples per second
            %Inputs: 
            %%% samples -- 
            %%%%% range == the new sample rate in samples per second. Must
            %%%%% be between 1e10 and 4e12
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == -2: invalid input
            %%%%% res == 0: operation successful
            
            if(RTO.Status == 0)
                res = -1;
            elseif(~(samples <= 4e12 && samples >= 1e10))
                res = -2;
            else
                fprintf(RTO.Channel, [sprintf('Acquire:Srate %d', samples), char(13)]);
                res = 0;
            end
        end
        
        
        %% Measurement Functions
        
        function res = ActivateWaveform(RTO, waveform, channel, state)
            %Function:
            %%% Sets the state of the specified waveform in the specified
            %%% channel.
            %Inputs: 
            %%% waveform -- 
            %%%%% waveform == the waveform to activate or deactivate. Must
            %%%%% be 1, 2, or 3.
            %%% channel --
            %%%%% channel == the channel for which the activation state is
            %%%%% being set. must be between 1 and 4
            %%% state --
            %%%%% state == 0: the specified waveform will be deactivated
            %%%%% state == 1: the specified waveform will be activated
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == -2: invalid input
            %%%%% res == 0: operation successful
            
            if(RTO.Status == 0)
                res = -1;
            elseif(~((waveform <= 3 && waveform >= 1) && ...
                    (channel <= 4 && channel >= 1) && ...
                    (state == 1 || state == 0)))
                res = -2;
            else
                if(state == 1)
                    fprintf(RTO.Channel, [sprintf('Channel%d:Waveform%d:State ON', channel, waveform), char(13)]);
                else
                    fprintf(RTO.Channel, [sprintf('Channel%d:Waveform%d:State OFF', channel, waveform), char(13)]);
                end
                res = 0;
            end
        end
        
        function res = RunSingleSample(RTO)
            %Function:
            %%% Causes the oscilloscope to run a single scan. Note that
            %%% this can be used to sample multiple channels
            %%% simultaneously. Call this, then GetData() to get data about
            %%% two or more channels measured at the same instant.
            %Inputs: 
            %%% None
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == 0: operation successful
            
            if(RTO.Status == 0)
                res = -1;
            else
                fprintf(RTO.Channel, ['RunSingle', char(13)]);
                res = 0;
            end
        end
        
        function res = SetTrigger(RTO, Channel, TriggerLevel)
            %Function:
            %%% Sets the trigger level for the specified channel
            %Inputs: 
            %%% Channel --
            %%%%% Channel == 1-4: Channel is the channel for which the
            %%%%% trigger will be defined
            %%%%% TriggerLevel --
            %%%%% TriggerLevel == -10 - 10: TriggerLevel is the level for
            %%%%% the new trigger in volts
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == -2: Channel number input invalid
            %%%%% res == -3: Trigger level out of bounds
            %%%%% res == 0: operation successful
            
            if(RTO.Status == 0)
                res = -1;
            elseif(~sum(Channel == [1, 2, 3, 4])) 
                res = -2;
            elseif(TriggerLevel < -10 || TriggerLevel > 10)
                res = -3;
            else
                fprintf(RTO.Channel, [sprintf('Trigger1:Level%d:Value %.3f', Channel, TriggerLevel) char(13)]);
                res = 0;
            end
        end
        
        function res = StartSample(RTO)
            %Function:
            %%% Starts the oscilloscope sampling process. Note that the
            %%% scope will continue to sample until StopSample is run
            %Inputs: 
            %%% None
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == 0: operation successful
            
            if(RTO.Status == 0)
                res = -1;
            else
                fprintf(RTO.Channel, ['RunContinous', char(13)]);
                res = 0;
            end
        end
        
        function res = StopSample(RTO)
            %Function:
            %%% Stops the oscilloscope sampling process
            %Inputs: 
            %%% None
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == 0: operation successful
            
            if(RTO.Status == 0)
                res = -1;
            else
                fprintf(RTO.Channel, ['Stop', char(13)]);
                res = 0;
            end
        end
        
        function [res, voltage] = GetData(RTO, waveform, channel)
            %Function:
            %%% Returns an array of all the voltages currently measured on
            %%% the specified channel and waveform
            %Inputs: 
            %%% waveform -- 
            %%%%% waveform == the waveform to activate or deactivate. Must
            %%%%% be 1, 2, or 3.
            %%% channel --
            %%%%% channel == the channel for which the activation state is
            %%%%% being set. must be between 1 and 4
            %Outputs:
            %%% res --
            %%%%% res == -1: RTO not open
            %%%%% res == 0: operation successful, results in voltage
            %%% voltage --
            %%%%% if the open fails, voltage is empty and res is -1
            %%%%% otherwise, voltage contains all the measured voltages
            
            voltage = [];
            if(RTO.Status == 0)
                res = -1;
            else
                fprintf(RTO.Channel, [sprintf('CHANNEL%d:WAVEFORM%d:DATA:VALUES?', channel, waveform), char(13)]);
                text = fscanf(RTO.Channel);
                voltage = str2double(RTO.stringsplit(text, ','));
                res = 0;
            end
        end        
        
        %% Termination Functions
        
        function res = Close(RTO)
            %Function:
            %%% Closes the RTO software
            %Inputs: 
            %%% None
            %Outputs:
            %%% res --
            %%%%% res == 0: close successful
            %%%%% res == -1: RTO not open
            
            if(RTO.Status == 0)
                res = -1;
            else
                fprintf(RTO.Channel, 'Stop'); %end all sweeps
                fclose(RTO.Channel);
                RTO.Status = 0;
                res = 0;
            end
        end
        
        %% Utility Functions
        
        function res = stringsplit(~, str, del)
            % the equivalent of strsplit on Matlab 2014 and later. In some
            % of the lab computers, the versions of matlab do not have this
            % function.
            old = 1;
            res = {};
            for ii = 1:length(str)
                if(str(ii) == del)
                    res{length(res)+1} = str(old:ii-1);
                    old = ii+1;
                end
            end
            %res = '';
        end
        
        function res = backwardstrsplit(~, str, del) 
            % returns the text between the end of the string and the first
            % delimeter going from right to left
            for(i = length(str):-1:1)
                if(str(i) == del)
                    res = str(i+1:end);
                    return;
                end
            end
            res = '';
        end
        
    end
end