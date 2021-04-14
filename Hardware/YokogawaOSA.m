classdef YokogawaOSA < handle
    properties
        visaResourceString;
        visaObj;
        InputBufferSize=1.5e7;
        bPointCheck = true;
    end
    
    methods
        function obj=YokogawaOSA(visaResourceString)
            if nargin>0
                obj.visaResourceString = visaResourceString;
            else
                obj.visaResourceString = "GPIB1::1::INSTR";
            end
            obj.visaObj=visa('ni',obj.visaResourceString);
            obj.visaObj.Timeout=30;
            obj.visaObj.InputBufferSize=obj.InputBufferSize;
        end
        
        function connect(Obj)
            if (Obj.isconnected)
                return
            end
            fopen(Obj.visaObj);
            disp('Yokogawa OSA connected');
        end
        
        % function delete(Obj)
        %     Obj.disconnect();
        % end
        
        function b = isconnected(Obj)
            b = strcmp(Obj.visaObj.Status,'open');
        end
        
        function disconnect(Obj)
            if ~isvalid(Obj)
                return
            end
            if (Obj.isconnected)
                disp('Yokogawa OSA disconnected');
            end
            fclose(Obj.visaObj);
        end
        
        function n=GetTraceSamplingPoints(obj,strTraceName)
            n=str2double(query(obj.visaObj,[':TRACe:DATA:SNUMber? TR' strTraceName]));
        end
        
        function [X,Y] = ReadTrace(obj,strTraceName,bSingle)
            if nargin == 3 && bSingle
                obj.Initiate;
            end
            x=query(obj.visaObj,[':TRACe:X? TR' strTraceName]);
            x=strsplit(x,',');
            X=str2double(x)*1e9;
            y=query(obj.visaObj,[':TRACe:Y? TR' strTraceName]);
            y=strsplit(y,',');
            Y=str2double(y);
            if obj.bPointCheck
                PointCheck(obj,strTraceName,length(Y));
            end
        end
        
        function Initiate(obj,strCommand)
            % strCommand='SINGLE' (default),"REPEAT','STOP'
            if nargin<2
                strCommand='SINGLE';
            end
            if strcmp(strCommand,'STOP') || strcmp(strCommand,'stop')
                fprintf(obj.visaObj,'ABORt');
            else
                fprintf(obj.visaObj,[':INITIATE:SMODE ' strCommand]);
                fprintf(obj.visaObj,':INITIATE');
            end
        end
    end
    
    methods (Access=protected)
        function bflag=PointCheck(obj,strTraceName,nFetched)
            % check if fetched trace points == OSA sampling points
            n=GetTraceSamplingPoints(obj,strTraceName);
            if nFetched~=n
                warning('Fetched trace points(%d) are less than OSA sampling points(%d). Try increase InputBufferSize.\n',nFetched,n);
                bflag=false;
            else
                bflag=true;
            end
        end
    end
end