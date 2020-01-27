classdef LowerOperationPowerObj < handle
    properties
        kappa; % with 2*pi
        yita; % Q/Qcoupling or kappaext/kappa, critical coupling=0.5
        g; % nonlinear gain, a normalization factor
        hv; % photon energy
        n2=2.2e-20;
        n=1.45;
        c=299792458;
        Aeff=40e-12;
        L=2*pi*1.5e-3;
        Pth;
        D1=21894.3e6*2*pi;
        D2=12.12e3*2*pi;
        beta2;
        taoR=2.4e-15;
        f=3e14/1.55;
        Q=219.04e8;
        
        zetaUpperBound=25; % plot to this number
        nSamplingPoint=301;
        
        Fboundry; % 2xn, soliton region in normalized space
        FBreather; % 2xn
        bestpath;
        Fzeta; % zeta corresponding to Fboundry
        
        SolitonPowerData;
        SolitonPowerzeta;
        SolitonPowerF2;
        SolitonPowerData2;
        SolitonPowerzeta2;
        SolitonPowerF22;
        
        EDFACorrectionRatio; % Ppumpinitial (taper power) / Pinitial (EDFA power)
    end
    properties 
        AOMTrans; % spline structure, input V, output T
        AOMTransInv; % spline structure, input T, output V
    end
    
    methods
        function obj=LowerOperationPowerObj(zetaUpperBound,nSamplingPoint,kappa,Q)
            obj.kappa=kappa;
            obj.Q=Q;
            % load AOM data
            data=load('AOM_Sheet.mat');
            V=data.Volt;
            T=data.Power_pct;
            T=smooth(V,T);
            obj.AOMTrans=spline(V,T);
            SmoothV=0.1:0.2:8.6;
            SmoothT=ppval(obj.AOMTrans,SmoothV);
            obj.AOMTransInv=spline(SmoothT,SmoothV);
            
            if nargin>0
                obj.zetaUpperBound=zetaUpperBound;
            end
            if ~isempty(nSamplingPoint)
                obj.nSamplingPoint=nSamplingPoint;
            end
            obj.Fzeta=linspace(sqrt(4),obj.zetaUpperBound,obj.nSamplingPoint);
            sgn=1;
            obj.Fboundry(1,:)=(2*obj.Fzeta-sgn*sqrt(obj.Fzeta.^2-3))/3.*(1+(sqrt(obj.Fzeta.^2-3)+sgn*obj.Fzeta).^2/9);
            sgn=-1;
            obj.Fboundry(2,:)=(2*obj.Fzeta-sgn*sqrt(obj.Fzeta.^2-3))/3.*(1+(sqrt(obj.Fzeta.^2-3)+sgn*obj.Fzeta).^2/9);
            
        end
        
        function []=LoadSolitonPowerData(obj,bSolitonRegionOnly)
            % load soliton power lines
            if nargin<2
                bSolitonRegionOnly=true;
            end
            FBreather=[3.45	4	4.5	5	5.5	6	7	8	9	10	12	14	16	18;6.981084	7.275993	7.552907	8.301653	9.150537	10.047	12.58434765	15.49413106	19.09759894	23.46780678	34.23250294	48.43088138	66.83691311	90.02873766];
            obj.FBreather=[];
            obj.FBreather(2,:)=spline(FBreather(1,:),FBreather(2,:),obj.Fzeta);
            obj.FBreather(1,:)=obj.Fzeta;
            obj.SolitonPowerF2=linspace(2,obj.FBreather(2,end)+20,obj.nSamplingPoint);
            
            obj.beta2=obj.D2*obj.n/(-obj.c*obj.D1^2);
            
            [zeta,f]=meshgrid(obj.Fzeta,sqrt(obj.SolitonPowerF2));
            B0=sqrt(2*zeta);
            coskai=cos(pi-asin(sqrt(8*zeta)/pi./f)+(5*pi^2-64)./zeta/4/pi^2);
%             coskai=cos(pi/2+acos(sqrt(8*zeta)/pi./f));
            B1=B0-5*pi/8./zeta.*f.*coskai;
            B2=B0-pi/4./zeta.*f.*coskai;
            
%             g=obj.f*2*pi*obj.c*obj.n2/obj.n^2/obj.Aeff/obj.L;
%             omega0=real(-8/15*obj.taoR*B1.^2.*B2.^2/(-obj.c*obj.beta2*2/obj.n/obj.kappa));
%             
%             omega=8*obj.c*obj.taoR*obj.Q*obj.beta2/15/obj.n/obj.f*2*pi*B2.^4/(-2*obj.c*obj.beta2/obj.n/obj.kappa)^2;
%             
% %                 omega=zeros(obj.nSamplingPoint,obj.nSamplingPoint);
%                 options = optimoptions('fsolve','Display','none','Algorithm','levenberg-marquardt');
%                 for i=1:obj.nSamplingPoint
%                     for j=1:obj.nSamplingPoint
%                         fun=@(omegaSolve) (zeta(i,j)*obj.kappa/2)-sqrt(15*obj.c*obj.beta2*obj.f*2*pi*omegaSolve/32/obj.n/obj.Q/obj.taoR)+obj.c*obj.beta2/2/obj.n*omegaSolve^2;                       
%                         omega(i,j)=fsolve(fun,omega0(i,j),options);
%                     end
%                 end
%                 omega(imag(omega)~=0)=NaN;
            RamanCorrection=1;
%             RamanCorrection=sqrt(1+obj.c*obj.beta2*omega.^2/2/obj.n./(zeta*obj.kappa/2));
            obj.SolitonPowerData=real(B1.^2./B2).*RamanCorrection;
            obj.SolitonPowerData(imag(obj.SolitonPowerData)~=0)=NaN;
%             obj.SolitonPowerData=real(obj.SolitonPowerData);
            obj.SolitonPowerzeta=obj.Fzeta;
            
            if bSolitonRegionOnly
                % data outside of soliton area is set to NaN
                for i=1:length(obj.Fzeta)
                    index=obj.SolitonPowerF2>obj.FBreather(2,i);
                    obj.SolitonPowerData(index,i)=NaN;
                    index=obj.SolitonPowerF2<obj.Fboundry(2,i);
                    obj.SolitonPowerData(index,i)=NaN;
                end
            end
        end
        
        function []=LoadSolitonPowerDataFrommat(obj)
            data=load('data-exx4.mat');
%             data=load('data-raman-large-fine.mat');
            obj.SolitonPowerData=data.PComb;
            obj.SolitonPowerzeta=data.zlist;
            obj.SolitonPowerF2=data.Flist;
            obj.FBreather=[];
            for i=size(obj.SolitonPowerData,2):-1:1
                nIndex=find(obj.SolitonPowerData(:,i)>0,1,'last');
                if ~isempty(nIndex)
                    obj.FBreather(1,i)=obj.SolitonPowerzeta(i);
                    obj.FBreather(2,i)=obj.SolitonPowerF2(nIndex);
                end
            end
            obj.beta2=obj.D2*obj.n/(-obj.c*obj.D1^2);
            try
%                 data2=load('Raman-contour-fine.mat');
                data2=load('lowzetadetuning.mat');
                obj.SolitonPowerData2=abs(data2.PComb);
                obj.SolitonPowerzeta2=data2.zlist;
                obj.SolitonPowerF22=data2.Flist;
            catch
            end
        end
        
        function F2=NormalizePowerFromVoltage(obj,Pin,Vin)
            % input AOM voltage and pump power (in taper)
            % output normalized power F^2
            P=ppval(obj.AOMTrans,Vin)*Pin;
%             if isempty(obj.hv)
%                 obj.hv=obj.f0*6.6260693e-34;
%             end
%             if isempty(obj.g)
%                 obj.g=2*pi*obj.hv*obj.f0*obj.c*obj.n2/obj.n^2/obj.Aeff/obj.L;
%             end
%             F2=sqrt(8*obj.g*obj.yita*P/obj.kappa^2/obj.hv);
            F2=P/obj.Pth;
        end
        function F2=NormalizePowerFromEDFA(obj,Pcurrent)
            % requires the following correction (linear)
            % Ppump=Pcurrent*Ppumpinitial/Pinitial;
            % Pcurrent, Pinitial: EDFA power
            % Ppumpinitial: pump poewr corresponding to EDFA Pinitial
            F2=Pcurrent*obj.EDFACorrectionRatio/obj.Pth;
        end
        function Vaom=NormalizeVoltageFromPower(obj,Pin,F2)
            % inverse function
%             if isempty(obj.hv)
%                 obj.hv=obj.f0*6.6260693e-34;
%             end
%             if isempty(obj.g)
%                 obj.g=2*pi*obj.hv*obj.f0*obj.c*obj.n2/obj.n^2/obj.Aeff/obj.L;
%             end
%             P=(F2/sqrt(8*obj.g*obj.yita/obj.kappa^2/obj.hv)).^2;
            P=F2*obj.Pth;
            Vaom=ppval(obj.AOMTransInv,P/Pin);
        end
        function Pcenter=TheoreticalCentralLinePower(obj)
            Pcenter=-pi*obj.c/2*obj.yita*obj.Aeff*obj.beta2/obj.n2*obj.D1/obj.Q;
        end
        
        function zeta=NormalizeDetuning(obj,fdetuning)
            zeta=2*fdetuning/(obj.kappa/2/pi);
        end

        
        function DrawPath(obj,Pin,Vin,fdetuning,varargin)
            F2=NormalizePowerFromVoltage(obj,Pin,Vin);
            zeta=2*fdetuning/(obj.kappa/2/pi);
            fig=figure(9);hold on;
            ax=fig.Children;
            if isempty(ax)
                % draw boundary
                DrawSolitonBoundary(obj);
            end
            if isempty(varargin)
                varargin{1}='.-';
            end
            plot(zeta,F2,varargin{:});
            

        end
        
        function DrawSolitonBoundary(obj,ax)
            if nargin<2
                plot(obj.Fzeta,obj.Fboundry,'-');
                xlabel('Normalized detuning');
                ylabel('Normalized power');
                hold('on')
            else
                axes(ax);
                plot(ax,obj.Fzeta,obj.Fboundry,'-');
                xlabel(ax,'Normalized detuning');
                ylabel(ax,'Normalized power');
                hold(ax,'on')
            end
            fill([obj.Fzeta,obj.FBreather(1,end:-1:1)],[obj.Fboundry(2,:),obj.FBreather(2,end:-1:1)],'g');alpha(0.2);
            fill([obj.FBreather(1,:),obj.Fzeta(end:-1:1)],[obj.FBreather(2,:),obj.Fboundry(1,end:-1:1)],'r');alpha(0.2);
            xlim([obj.Fzeta(1),obj.Fzeta(end)]);
            ylim([4,60]);
            
            if ~isempty(obj.SolitonPowerData)
                % draw contour plot
                MaxData=max(max(abs(obj.SolitonPowerData)));
                MinData=min(min(abs(obj.SolitonPowerData)));
                Energy=linspace(MinData,MaxData,31);
                contour(ax,obj.SolitonPowerzeta,obj.SolitonPowerF2,abs(obj.SolitonPowerData),Energy,'Color','r'); % Energy(12:end)
                if ~isempty(obj.SolitonPowerData2)
                    contour(ax,obj.SolitonPowerzeta2,obj.SolitonPowerF22,abs(obj.SolitonPowerData2),Energy,'Color','r');
                end
            end
        end
        
        function [Vservo,Vboundry]=GetInversePath(obj,Pin,ppzeta_Vservo)
            % if no input, return the best path in F2-zeta space and plot
            % in V. Requires the Vservo-detuning relation
            % ppzeta_Vservo: spline(zeta,Vservo)
            % the best path considers to be the 1/3 position of soliton
            % region
            for i=3:-1:1
                Vboundry(i,:)=NormalizeVoltageFromPower(obj,Pin,obj.Fboundry(i,:)); % Vaom
            end
            Vservo=ppval(ppzeta_Vservo,obj.Fzeta);
            
        end
        
        function Pth=Threshold(obj,loadedQ,couplingQ)
            Pth=2*pi^2*obj.n*obj.f*obj.Aeff(1)/4/obj.n2/obj.D1(1)/loadedQ^3*couplingQ;
        end
        
    end
    
end