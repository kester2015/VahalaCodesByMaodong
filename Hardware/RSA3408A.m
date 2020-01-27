classdef RSA3408A < handle
    % RSA3408A
    properties
        visaObj
        visaResourceString
    end
    
    methods
        function obj=RSA3408A(visaResourceString)
            if nargin>0
                obj.visaResourceString=visaResourceString;
                obj.visaObj=visa('agilent',visaResourceString);
                obj.visaObj.Timeout=30;
                obj.visaObj.InputBufferSize = 131072;
            end
        end
        
        function delete(Obj)
            Obj.Disconnect();
        end
        
        function b = isconnected(Obj)
            b = strcmp(Obj.visaObj.Status,'open');
        end
        
        function Connect(Obj)
            if (Obj.isconnected)
                return
            end
            fopen(Obj.visaObj);
            disp('RSA3408A connected');
        end
        
        function Disconnect(Obj)
            if (Obj.isconnected)
                disp('RSA3408A disconnected');
            end
            fclose(Obj.visaObj);
        end
        
        function Write(obj,command)
            fprintf(obj.visaObj,command);
        end
        
        function o = Read(obj,numBufferSamples,type)
            o = fread(obj.visaObj,numBufferSamples,type);
        end
        
        function o = Query(obj,command)
            o = query(obj.visaObj,command);
        end
        
        function Run(Obj)
            Obj.Write(':INITiate[:IMMediate]');
            Obj.Write(':INITiate:CONTinuous ON');
        end
        
        function Stop(Obj)
            Obj.Write(':INITiate:CONTinuous OFF');
        end
        
        function [data,X]=ReadData(Obj)
            
            % fprintf( visaObj, ':READ:SPEC?' );          % Fetch the trace
            Obj.Write(':FETCh:SPEC?');          % Fetch the trace
            
            % inputBufferSize = get( visaObj, 'InputBufferSize' );
            inputBufferSize=131072;
            % The data we will parse has the following format:
            % #<Num_digit><Num_byte><IData 1><QData 1><IData 2><QData 2> ... <IData
            % N><QData N>
            %
            % where:
            %	<Num_digit>	Number of digits in the <Num_byte> field
            %	<Num_byte>	Number of bytes to follow
            %	<IData 1>	I channel in V (4 byte little-endian floating
            %				point format)
            %
            byteWidth	= 4;	% 32 bit data (single precision)
            strTemp		= Obj.Read(1, 'char');		% Get rid of the # sign
            numDigits	= str2double( char( Obj.Read(1, 'char') ) );
            numBytes	= str2double( char( Obj.Read(numDigits, 'char' ) ) );
            
            numSamples = (numBytes / byteWidth);
            
            data = zeros(1,numSamples);
            numBufferSamples = inputBufferSize / byteWidth;
            if numBufferSamples > numSamples,
                numBufferSamples = numSamples;
            end
            numReadIterations = floor( numSamples / numBufferSamples);
            numRemainingSamples = numSamples - numReadIterations * numBufferSamples;
            i2 = 0;
            for i=1:numReadIterations,
                i1 = i2 + 1;
                i2 = i1 + numBufferSamples - 1;
                data(i1:i2) = Obj.Read(numBufferSamples, 'single' );
            end
            if numRemainingSamples > 0,
                i1=i2+1;
                i2=i1+numRemainingSamples-1;
                data(i1:i2) = Obj.Read(numRemainingSamples, 'single' );
            end
            
            % Finish the read by reading the terminal character
            strTemp		= Obj.Read(1, 'char');
            
            if nargout>1
                % read x-axis frequency
                freqStart=str2double(Obj.Query(':SENSe:FREQuency:STARt?' ));
                freqStop=str2double(Obj.Query(':SENSe:FREQuency:STOP?' ));
                X=linspace(freqStart,freqStop,length(data));
            end
        end
    end
end

