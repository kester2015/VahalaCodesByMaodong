
classdef YokogawaOSA_deprecated < handle
    properties
        visaResourceString;
        visaObj;
        InputBufferSize=1.5e7;
    end
    
    methods
        function obj=YokogawaOSA(visaResourceString)
            if nargin>0
                obj.visaResourceString=visaResourceString;
                obj.visaObj=visa('agilent',visaResourceString);
                obj.visaObj.Timeout=30;
            end
        end
        
        function Connect(obj)
            obj.visaObj.InputBufferSize=obj.InputBufferSize;
            fopen(obj.visaObj);
        end
        
        function Delete(obj)
            fclose(obj.visaObj);
        end
        
        function n=GetTraceSamplingPoints(obj,strTraceName)
            n=query(obj.visaObj,[':TRACe:DATA:SNUMber? TR' strTraceName]);
        end
        
        function X=ReadTraceXData(obj,strTraceName,bPointCheck)
            if nargin<3
                bPointCheck=true;
            end
            y=query(obj.visaObj,[':TRACe:X? TR' strTraceName]);
            y=strsplit(y,',');
            X=str2double(y);
            if bPointCheck
                PointCheck(obj,strTraceName,length(X));
            end
        end
        
        function Y=ReadTraceYData(obj,strTraceName,bPointCheck)
            if nargin<3
                bPointCheck=true;
            end
            y=query(obj.visaObj,[':TRACe:Y? TR' strTraceName]);
            y=strsplit(y,',');
            Y=str2double(y);
            if bPointCheck
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
%             n=GetTraceSamplingPoints(obj,strTraceName);
%             if nFetched~=n
%                 warning('Fetched trace points are less than OSA sampling points. Try increase InputBufferSize.')
%                 bflag=false;
%             else
                bflag=true;
%             end
        end
    end
end