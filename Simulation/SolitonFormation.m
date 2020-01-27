classdef SolitonFormation < handle
    % Normalized equation solver
    properties
        % Simulation parameters
        N;                  % Number of points (must be odd number)
        t;                  % t*(2/k)
        seed;               % seeding
        
        %function object
        d2;                 % D2*(2/k)
        d_int;              % D_int(mu)*(2/k) 3rd order dispersion or higher, D2 was counted
        zeta;               % detuning(t) (wc-wp)*2/k
        f;                  % pump power(mu) sqrt(Pin/Pth)
        eta;                % Q/Qext = k_ext/k
        
        %Transform
        F2T;                % Freq to Time
        T2F;                % Time to Freq
        
        %Raman
        D1;                 % FSR(Hz) * 2pi
        
        %Output
        Phi;                % N * Ntimesteps
        
        %
        theta;
    end
    
    methods
        function obj = SolitonFormation()
            % Initialize
            obj.N = 2001;
            obj.t = 0:0.001:10;
            obj.d2 = 0.01;
            obj.d_int = 0;
            obj.zeta = 20;
            obj.f = sqrt(20);
            obj.eta = 1/2;
            obj.D1 = 20e9 * 2 * pi;
            obj.seed = obj.getseed(obj.N,obj.f,obj.zeta,obj.d2);
        end
        
        function solve(obj,method)
            if nargin < 2
                method = 'SS';
            end
            %% Initilize
            % Transform
            psi = linspace(0,2*pi*(obj.N-1)/obj.N,obj.N).';
            Nside = floor(obj.N/2);
            mu = -Nside:Nside;
            PA = exp(1i*psi*mu);
            AP = PA^-1;
            mu = ifftshift(mu.');
            
            % Time step
            Nstep = numel(obj.t);
            h = diff(obj.t);
            
            % Conditions
            if ~isa(obj.d_int,'function_handle') && obj.d_int == 0
                obj.d_int = @(x) zeros(size(x));
            end
            if ~isa(obj.zeta,'function_handle')
                z = obj.zeta;
                obj.zeta = @(t) z * ones(size(t));
            end
            if ~isa(obj.f,'function_handle')
                ff = obj.f;
                obj.f = @(t) ff * ones(size(t));
            end
            
            dw = 1/2 * obj.d2 * mu.^2 + obj.d_int(mu);
            detuning = obj.zeta(obj.t);
            
            maxincr = 1/h(1);
            if max(abs(dw(:))) > maxincr
               BadPercent = numel(find(abs(dw) > maxincr)) / obj.N * 100;
               warning(sprintf('Time step is too large, it may cause some issue. Percentage: %.1f%%. dPhi:%.3f, ',BadPercent,max(abs(dw(:)))*h(1)));
               dw(dw>maxincr) = maxincr;
               dw(dw<-maxincr) = -maxincr;
            end
            
            %% Initial seeding
            phi = zeros(obj.N,Nstep);
            phi(:,1)=obj.seed;
            %% Time Evolution
            switch (method)
                case {'Runge-Kutta','RK'} % less Nmode
                    h = h(1); % equal space
                    for k=1:(Nstep-1)
                        pump1 = obj.f(obj.t(k));
                        pump2 = obj.f(obj.t(k+1));
                        %%%k1
                        pk = phi(:,k);
                        ak = fft(pk);
                        couple = 1i* abs(pk).^2.*pk;
                        da = -(1+1i*dw+1i*detuning(k)).*ak;
                        k1 = ifft(da) + couple + pump1;
                        %%%k2
                        pk = phi(:,k) + k1 * h/2;
                        ak = fft(pk);
                        couple = 1i* abs(pk).^2.*pk;
                        da = -(1+1i*dw+1i/2*(detuning(k)+detuning(k+1))).*ak;
                        k2 = ifft(da) + couple +(pump1+pump2)/2;
                        %%%k3
                        pk = phi(:,k) + k2 * h/2;
                        ak = fft(pk);
                        couple = 1i* abs(pk).^2.*pk;
                        da = -(1+1i*dw+1i/2*(detuning(k)+detuning(k+1))).*ak;
                        k3 = ifft(da) + couple +(pump1+pump2)/2;
                        %%%k4
                        pk = phi(:,k) + k3 * h;
                        ak = fft(pk);
                        couple = 1i* abs(pk).^2.*pk;
                        da = -(1+1i*dw+1i*detuning(k)).*ak;
                        k4 = ifft(da) + couple + pump2;
                        %%%
                        phi(:,k+1)=phi(:,k)+h/6*(k1+2*k2+2*k3+k4);
                    end
                case {'','Linear','L'}  % less Nmode
                    h = h(1); % equal space
                    for k=1:(Nstep-1)
                        pump = obj.f(obj.t(k));
                        pk = phi(:,k);
                        ak = fft(pk);
                        da = -(1+1i*dw+1i*detuning(k)).*ak;
                        dp = ifft(da) + 1i*pk.* abs(pk).^2 + pump;
                        phi(:,k+1)= pk + h * dp;
                    end
                case {'Splitted-Step','SS'}
                    h = h(1); % equal space
                    for k=1:(Nstep-1)
                        pump = obj.f(obj.t(k));
                        pk = phi(:,k);
                        ak = fft((pk.*exp(1i * h * abs(pk).^2)));
                        phi(:,k+1) = ifft((exp((-(1+1i*dw+1i*detuning(k))) * h).* ak)) + pump * h;
                    end
                case {'Raman'}
                    h = h(1);
                    dphi = 2*pi/obj.N;
                    G = obj.D1 * 2.4e-15;
                    for k=1:(Nstep-1)
                        pump = obj.f(obj.t(k));
                        pk = phi(:,k);
                        Asqrd = abs(pk).^2;
                        Raman = G * [diff(Asqrd);Asqrd(1)-Asqrd(end)]/dphi;
                        ak = fft(pk.*exp(1i * h * (Asqrd + Raman)));
                        phi(:,k+1) = ifft((exp((-(1+1i*dw+1i*detuning(k))) * h).* ak)) + pump * h;
                    end
                case {'Raman2','RamanFull'}
                    if isempty(obj.D1)
                        error('Please specify D1');
                    end
                    h = h(1);
                    t1 = 12.2e-15;
                    t2 = 32e-15;
                    tb = 96e-15;
                    if strcmp('RamanFull',method)
                        fb = 0.21;
                        fR = 0.245;
                    else
                        fb = 0;
                        fR = 0.18;
                    end
                    Coeff1 = (1-fb) * (t1^-2 + t2^-2) * t1;
                    Coeff2 = fb * tb^-2;
                    tt = psi / obj.D1;
                    RamanResponse = Coeff1 * exp(-tt/t2) .* sin (tt/t1) +...
                        Coeff2 * (2 * tb - tt).* exp(-tt/tb);
                    RamanVal = sum(RamanResponse)*2*pi/obj.N/obj.D1;
                    if RamanVal > 1.01 || RamanVal < 0.99
                        warning(sprintf('Too little sidebands.%.3f',RamanVal));
                    end
                    RW = fft(RamanResponse) / obj.D1 * 2*pi/obj.N;
                    for k=1:(Nstep-1)
                        pump = obj.f(obj.t(k));
                        pk = phi(:,k);
                        Asqrd = abs(pk).^2;
                        % Raman = (1 - fR) * Asqrd + fR * ifft(fft(Asqrd).*RW);  WRONG, have to reverse coordinate
                        Raman = (1 - fR) * Asqrd + fR * fft(ifft(Asqrd).*RW);
                        ak = fft(pk.*exp(1i * h * Raman));
                        phi(:,k+1) = ifft((exp((-(1+1i*dw+1i*detuning(k))) * h).* ak)) + pump * h;
                    end
            end
            obj.Phi = phi;
            obj.F2T = PA;
            obj.T2F = AP;
        end
        
        function rt = Check(obj,method,F,z)
            rt.F = F;
            rt.z = z;
            a = 1e-3;
            obj.seed = obj.getseed(obj.N,sqrt(F),z,obj.d2);
            obj.f = sqrt(F);
            obj.zeta = z;
            obj.t = 0:1e-3:10;
            obj.solve(method);
            [~,P] = obj.plot_t('Pin',1);
            if P(end)/P(1) < 0.01
                rt.info = 'No soliton';
                return;
            end
            if min(P(round(end/2):end))/max(P(round(end/2):end)) > 1-a
                rt.info = 'Stable soliton';
                rt.P = P(end);
                return;
            end
            fit_Exp = fittype('A*exp(-x/x0)+B','coefficients',{'A','x0','B'});
            obj.seed = obj.Phi(:,end);
            obj.t = 0:1e-3:20;
            obj.solve(method);
            [ts,P] = obj.plot_t('Pin',1);
            if min(P(round(end/2):end))/max(P(round(end/2):end)) > 1-a
                rt.info = 'Stable soliton';
                rt.P = P(end);
                return;
            end
            off = median(P);
            [mag,idx] = findpeaks(+P,'MinPeakHeight', +off);
            if numel(mag) < 3
                rt.info = 'Unknown';
                rt.P = P(end);
                return;
            end
            t0 = (ts(idx(2))-ts(idx(1)))/(log((off-mag(1))/(off-mag(2))));
            A0 = exp(ts(idx(1))/t0) * (mag(1)-off);
            env_u = fit(ts(idx).', mag.', fit_Exp,'StartPoint', [A0,t0,off]);
            [mag,idx] = findpeaks(-P,'MinPeakHeight', -off);
            if numel(mag) < 3
                rt.info = 'Unknown';
                rt.P = P(end);
                return;
            end
            mag = -mag;
            t0 = (ts(idx(2))-ts(idx(1)))/(log((off-mag(1))/(off-mag(2))));
            A0 = exp(ts(idx(1))/t0) * (mag(1)-off);
            env_d = fit(ts(idx).', mag.', fit_Exp,'StartPoint', [A0,t0,off]);
            if env_d.B/env_u.B < 1-a
                rt.info = 'Breather';
                rt.P = mean(P);
                rt.Pmax = env_u.B;
                rt.Pmin = env_d.B;
                rt.t1 = env_u.x0;
                rt.t2 = env_d.x0;
                
                plot(ts,P);
                hold on
                plot(ts,env_u(ts),'r');
                plot(ts,env_d(ts),'b');
                saveas(gca,sprintf('F_%.2f_z_%.2f_Breather.png',F,z));
            else
                rt.info = 'Stable soliton';
                rt.P = (env_d.B + env_u.B)/2;
                rt.Perror = env_u.B - env_d.B;
                rt.t1 = env_u.x0;
                rt.t2 = env_d.x0;
            end
        end
        
        function rt = Check2(obj,method,F,z,a)
            rt.F = F;
            rt.z = z;
            obj.f = sqrt(F);
            obj.zeta = z;
            step = 1;
            tmax = 10;
            if nargin < 5
                a = 1e-3;
            end
            while step < 5
                if step == 1
                    obj.seed = obj.getseed(obj.N,sqrt(F),z,obj.d2);
                else
                    obj.seed = obj.getpulse;
                end
                obj.t = 0:a:tmax;
                obj.solve(method);
                [~,P] = obj.plot_t('Pin',1);
                if P(end)/P(1) < 0.01
                    break;
                end
                P = P(round(end*0.8):end);
                if min(P)/max(P) > 1-a
                    break;
                end
                step = step + 1;
                tmax = tmax * 2;
            end
            if P(end)/P(1) < 0.01
                rt.info = 'No soliton';
                return;
            end
            if step == 5
                rt.info = 'Breather';
                rt.P = mean(P);
                rt.Pmax = min(P);
                rt.Pmin = max(P);
                rt.pulse = obj.getpulse;
                return;
            else
                rt.info = 'Stable soliton';
                rt.pulse = obj.getpulse;
                rt.P = mean(P);
                return;
            end
        end
        
        function [t_p,data] = plot_t(obj,type,silent)
            if isempty(obj.Phi)
                error('No data');
            end
            if nargin < 3 || ~silent
                silent = 0;
                figure;
                hold off;
                if nargin < 2
                    type = 'temproal';
                end
            end
            if size(obj.Phi,2) > 10000
                selected = round(linspace(1,size(obj.Phi,2),10001));
                phi = obj.Phi(:,selected);
                t_p = obj.t(selected);
            else
                phi = obj.Phi;
                t_p = obj.t;
            end
            A_mat = obj.T2F * phi;
            center = floor(obj.N / 2) + 1;
            Pt=abs(phi.^2);  %temporal power
            switch type
                case {'temproal','t','phi','pulse'}
                    maxd = max(max(Pt));
                    data = abs(Pt)/maxd*100;
                    if silent
                        return
                    end
                    pcolor(t_p,obj.theta,log(data));
                    shading interp;
                    colormap jet;
                    xlabel('Scan time (2/\kappa)');
                    ylabel('\phi/\pi');
                    title('Pulse evolution');
                case {'Intrcavity','Pin'}
                    A_mat(center,:) = 0; % filter pump
                    Pin = sum(abs(obj.F2T * A_mat).^2)*2*pi/obj.N; % ~ 2sqrt(2zeta*d2)
                    data = Pin;
                    if silent
                        return
                    end
                    plot(t_p,data);
                    xlabel('Time (2/\kappa)');
                    ylabel('Comb Power');
                case {'transmission','T'}
                    transmission=abs(obj.f(0,t_p)-2*obj.eta*A_mat(center,:)).^2./obj.f(0,t_p).^2;%normalized pump transmission
                    data = transmission;
                    if silent
                        return
                    end
                    plot(t_p,transmission);
                    xlabel('Scan time (2/\kappa)');
                    ylabel('Transmission');
                    title('Transmission');
                case {'Spectrum','spectrum'}
                    A_mat(center,:) = 0; % filter pump
                    NSide = floor(obj.N/2);
                    mu = (-NSide:NSide).';
                    data = 20*log10(abs(A_mat(center + mu,:)));
                    pcolor(t_p,mu,data);
                    xlabel('Scan time (2/\kappa)');
                    ylabel('Mode number (\mu)');
                    shading interp;
                    colormap jet;
            end
        end
        
        function LPower = plot_spectrum(obj,t,type)
            if nargin < 3
                type = '';
                if nargin < 2
                    t = obj.t(end);
                end
            end
            Aw = obj.getspectrum(t);
            NSide = floor(obj.N/2);
            mu = (-NSide:NSide).';
            LPower = 20*log10(abs(Aw));
            if strcmp(type,'lines')
                Base = floor(min(LPower/20)) * 20;
                bar(mu,LPower - Base,0.6);
                xlabel('Mode number (\mu)');
            elseif strcmp(type,'f')
                plot(mu * obj.D1/2/pi/1e12,LPower);
                xlabel('Frequency (THz)');
            else
                plot(mu,LPower);
                xlabel('Mode number (\mu)');
            end
            ylabel('Power (dB)');
        end
        
        function plot_pulse(obj,t)
            if nargin < 2
                t = obj.t(end);
            end
            shape = abs(obj.getpulse(t).^2);
            plot(obj.theta,shape);
            xlabel('\phi/\pi');
            ylabel('Power');
        end
        
        function plot_phase(obj,t)
            if nargin < 2
                t = obj.t(end);
            end
            phase = angle(obj.getpulse(t))/pi;
            plot(obj.theta,phase);
            xlabel('\phi/\pi');
            ylabel('Phase');
        end
        
        function t = get.theta(obj)
            t = linspace(-1,(obj.N-2)/obj.N,obj.N);
        end
        
        function f = getRep(obj,sign)
            if nargin < 2
                sign = 1;
            end
            shape = abs(obj.Phi.^2);
            [~,I]=max(shape,[],1);
            I = I *  2 *pi/ obj.N;
            if sign > 0
                I(I<I(1))=I(I<I(1))+2*pi;
            else
                I(I>I(1))=I(I>I(1))-2*pi;
            end
            myfit = fit(obj.t.',I.','poly1');
            f = myfit.p1/2;
        end
        
        function Pt = getpulse(obj,t)
            if nargin < 2
                t = obj.t(end);
            end
            Pt = obj.Phi(:,obj.getindex(t));
        end
        
        function Aw = getspectrum(obj,t)
            if nargin < 2
                t = obj.t(end);
            end
            Aw = obj.T2F * obj.getpulse(t);
        end
        
        function movie(obj,fileout,t)
            if nargin < 3
                t = obj.t;
            end
            if numel(t) > 10000
                selected = round(linspace(1,numel(t),10001));
                t = t(selected);
            end
            Nside = floor(obj.N/2);
            mu = (-Nside:Nside).';
            center = Nside + 1;
            if center > 500
                selected = center-250:center+250;
            else
                selected = 1:obj.N;
            end
            mu_p = mu(selected);
            Aw = obj.T2F * obj.Phi;
            phi = obj.theta;
            Pin = NaN(size(t));
            
            [~,P] = obj.plot_t('Pin',1);
            Pmin = min(P) * 1.1 - max(P) * 0.1;
            Pmax = max(P) * 1.1 - min(P) * 0.1;
            
            d_time=0.04; %delay time
            writerObj = VideoWriter(fileout);
            writerObj.FrameRate=1/d_time;
            open(writerObj)
            H = figure;
            set(gcf,'Position', [100,329,1000,800]);
            for ii = 1:numel(t)
                Pt = obj.getpulse(t(ii));
                Aw = obj.getspectrum(t(ii));
                
                subplot(3,1,2)
                shape = abs(Pt.^2);
                plot(phi/pi,shape);
                ylim([0 2])
                xlabel('Co-rotating angular coordinate \phi (\pi)');
                ylabel('Normalized power');
                
                %                 subplot(3,1,3)
                %                 phase = angle(fft(Aw).* exp(1i * phi.' * (N - 1)/2))/pi;
                %                 plot(phi/pi,phase);
                %                 xlabel('Co-rotating angular coordinate \phi (\pi)');
                %                 ylabel('Phase (\pi)');
                
                subplot(3,1,3)
                plot(mu_p,20*log10(abs(Aw(selected))));
                xlabel('Mode number (\mu)');
                ylabel('Power (dB)');
                
                subplot(3,1,1)
                Aw(center) = 0;
                Pin(ii) = sum(abs(obj.F2T * Aw).^2)*2*pi/obj.N;
                plot(t,Pin)
                xlim([t(1) t(end)])
                ylim([Pmin Pmax])
                xlabel('t (2/\kappa)');
                ylabel('Normalized Comb Power');
                
                drawnow
                frame = getframe(H);
                writeVideo(writerObj,frame);
            end
            close(writerObj)
        end
    end
    
    methods (Access = private)
        function idx = getindex(obj,t)
            [~,idx] = min(abs(obj.t - t));
        end
    end
    
    methods (Static)
        %% get something using f zeta D2
        % N Total number
        % f normalized pump power
        % zeta normalized pump detuning
        % D2
        function Seed = getseed(N,f,z,d2)
            phi = linspace(0,2*pi*(N-1)/N,N);
            BG = 1i*f/(1i-1/3*z-2/3*sqrt(z^2 - 3)*cosh(1/3*acosh((2*z^3+18*z-27*f^2)/2/(z^2-3)^(3/2))));
            B = sqrt(2*z);
            phase = acos(B*2/pi/f);
            X = pi - asin(B*2/pi/f) + (5*pi^2-64)/(4*z*pi^2);
            B1 = B - 5*pi*f/8/z * cos(X);
            B2 = B - pi*f/4/z * cos(X);
            if B2/sqrt(d2) > N / 10
                warning('Seed is under sampling');
            end
            Seed = BG + B1 * exp(1i * phase) * sech(B2 * (phi - pi)/sqrt(d2)); % Modified Soliton Solution
        end
        
        function rho = getrho(f,zeta)
            BG = 1i*f/(1i-1/3*zeta-2/3*sqrt(zeta^2 - 3)*cosh(1/3*acosh((2*zeta^3+18*zeta-27*f^2)/2/(zeta^2-3)^(3/2))));
            rho = abs(BG)^2;
        end
        
        function F = Upper(zeta)
            rho = (2 * zeta - sqrt(zeta.^2 - 3))/3;
            rho(zeta < sqrt(3)) = NaN;
            F = (1+(zeta-rho).^2) .* rho;
        end
        
        function F = Lower(zeta)
            rho = (2 * zeta + sqrt(zeta.^2 - 3))/3;
            rho(zeta < sqrt(3)) = NaN;
            F = (1+(zeta-rho).^2) .* rho;
        end
    end
end