classdef nrlistToModeSpec < handle
    % Maodong, version 0. 012921
    properties
        c_const = 299792458;
        
        frequencylist
        nrlist
        
        FSR
        offset % TODO: add offset to each mode family.
    end
    
    properties
        modeNum
        centerLambda
    end
    
    properties (Access = public)
        modeSpectrum
        modeSpectrum_topolt
    end
    
    methods
        function obj = nrlistToModeSpec(varargin)
            ip = inputParser;
            ip.addParameter('frequencylist',0,@isnumeric); 
            ip.addParameter('nrlist',0,@isnumeric); 
            ip.addParameter('FSR',10e9,@isnumeric);
            ip.addParameter('offset',0,@isnumeric);            
            ip.addParameter('modeNum',30,@isnumeric);
            ip.addParameter('centerLambda',1550e-9,@isnumeric);
            ip.parse(varargin{:});
            
            obj.frequencylist = ip.Results.frequencylist;
            obj.nrlist = ip.Results.nrlist;
            obj.FSR = ip.Results.FSR;
            obj.offset = ip.Results.offset;
            obj.modeNum = ip.Results.modeNum;
            obj.centerLambda = ip.Results.centerLambda;
            
        end
        
        function processModeSpectrum(obj)
            obj.modeSpectrum = zeros(length((-obj.modeNum:obj.modeNum)),size(obj.nrlist,2));
            for ii = 1:size(obj.nrlist,2)
                obj.modeSpectrum(:,ii) = obj.processOneModeFamiliy(obj.frequencylist,obj.nrlist(:,ii) );
            end
        end
        
        function plot_MS(obj)
            figure;
            hold on
            set(gca,'ButtonDownFcn',@testBDF)
            % plot([0 1 2],[0 1 2])
            obj.modeSpectrum_topolt = mod(obj.modeSpectrum+obj.FSR/2,obj.FSR)-obj.FSR/2;
            for ii = 1:size(obj.nrlist,2)
                scatter((-obj.modeNum:obj.modeNum)',obj.modeSpectrum_topolt(:,ii));
            end
            xlabel('Mode number')
            ylabel('Frequency / Hz')
            function testBDF(gcbo,EventData,handles) % TODO: add callback function to figure
                disp(gcbo.CurrentPoint)
            end
        end
    end
    
    methods (Access = private)
        function mode_position = processOneModeFamiliy(obj,freqList,nrList)
            nrOverf = @(f) interp1(freqList,nrList,f);
            center_f = obj.c_const/obj.centerLambda;
            center_mu = nrOverf(center_f)*2*pi/obj.centerLambda;
            center_mu = round(center_mu);
            
            mu_List = (center_mu-obj.modeNum) : (center_mu+obj.modeNum);
            resonant_freq_list = center_f + (-obj.modeNum:obj.modeNum)*obj.FSR;
            
            mode_freq_list = mu_List*obj.c_const./nrOverf(resonant_freq_list)/2/pi;
            
            mode_position = (mode_freq_list - resonant_freq_list)';
            
            mode_position = mode_position + mode_position(round(end/2));
        end
    end
    
end