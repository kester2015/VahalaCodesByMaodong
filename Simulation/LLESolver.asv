classdef LLESolver < handle
    % lugiato lefever equation solver
    % Maodong Gao, Version 1.1, 2020-12-09
    % \pdv{A}{t} = -(\frac{\kappa}{2} + i \delta \omega) A   % detuning and loss
    %              + \Sigma_{n=2}^\infty i^{n-1} \frac{D_n}{n!}\pdv[n]{A}{\phi} % Dispersion
    %              + ig\abs{A}^2 A  % nonlinearity
    %              + \sqrt{\frac{\kappa\eta P_{in}}{\hbar \omega_0}} % pump
    % A in unit of photon density. which is unitless
    % all time and frequency normalized to kappa/2. 
    % 
    properties % public properties
        modeNumber
        NStep % Number of timestep
        timeStep % timestep in units of kappa*t/2. Total scan time = NStep*h*2/kappa
        
        detuning % detuning in units of kappa
        pumpPower % pump power in units of threshold
        pulsePump % pump power on fast retarded time, length equal to mode number, pulse shape in time domain, will be normalized to [0 1]
        
        
        D2 % D2 in units of kappa; positive: anomalous
        D3 % D3 in units of kappa; 
        D4 % D4 in units of kappa;
        D1 % D1 usually not used. useful when pulse pump
        % DList % [D2, D3, D4, ...] store dispersion in this array
                
        initState % select initial state
        solver
    end
    
   properties (Access = public) % should be protected later
       phiResult % store Freq evolution result
       phiResult_Freq % Freq domain, 0->max->min->0 frequencies.
   end
   
   properties (Access = public) % should be private later
       reducedPhi % reduced phiResult(down sampling) for data visualization
       reducedPhiIndex
       reduceDim = 1000;
   end
   
   properties (Access = public) % for debug only
       pulsePump_freq_debugonly
   end
    %% LLE equation sloving methods
    methods % pubilc methods
        function obj = LLESolver(varargin)
            ip = inputParser;
            ip.addParameter('modeNumber',1024,@isnumeric); 
            ip.addParameter('NStep',10e4,@isnumeric);
            ip.addParameter('timeStep',5e-5,@isnumeric);
            
            ip.addParameter('detuning',30,@isnumeric);
            ip.addParameter('pumpPower',100,@isnumeric);
            ip.addParameter('pulsePump',1,@isnumeric);
            ip.addParameter('D2',0.02,@isnumeric);
            ip.addParameter('D3',0.0001,@isnumeric);
            ip.addParameter('D4',0,@isnumeric);
            ip.addParameter('D1',0,@isnumeric);
            ip.addParameter('initState','soliton',@ischar);
            ip.addParameter('solver','SSFT',@ischar); % SSFT: split step FT; RK: Runge kutta
            % ip.addParameter('DList',[0.02,0.0001,0],@isnumeric);
            % ip.addParameter('initState',1,@isnumeric);
            ip.parse(varargin{:});         
            
            % TODO: check input validility later
            % TODO: check modeNumber be power of 2 in splitstep mode
            obj.modeNumber = ip.Results.modeNumber;
            obj.NStep = ip.Results.NStep;
            obj.timeStep = ip.Results.timeStep;
            obj.D2 = ip.Results.D2;
            obj.D3 = ip.Results.D3;
            obj.D4 = ip.Results.D4;
            obj.D1 = ip.Results.D1;
            obj.initState = ip.Results.initState;
            obj.solver = ip.Results.solver;
            
            switch length(ip.Results.detuning)
                case 1
                    obj.detuning = linspace(ip.Results.detuning,ip.Results.detuning,obj.NStep);
                case 2
                    obj.detuning = linspace(ip.Results.detuning(1),ip.Results.detuning(2),obj.NStep);
                case obj.NStep
                    obj.detuning = ip.Results.detuning;
                otherwise
                    error('LLESolver:invalidInput',...
                        'obj.detuning length %d, required 1 or 2 or %d.\n\t detuning must be a constant number, or a 2-dim array specifing start and stop detuning,\n\t or the same length with NStep(current %d) specifing whole envoling time.',...
                    length(ip.Results.detuning), obj.NStep, obj.NStep);
            end
            switch length(ip.Results.pumpPower)
                case 1
                    obj.pumpPower = linspace(ip.Results.pumpPower,ip.Results.pumpPower,obj.NStep);
                case 2
                    obj.pumpPower = linspace(ip.Results.pumpPower(1),ip.Results.pumpPower(2),obj.NStep);
                case obj.NStep
                    obj.pumpPower = ip.Results.pumpPower;
                otherwise
                    error('LLESolver:invalidInput',...
                        'obj.pumpPower length %d, required 1 or 2 or %d.\n\t pumpPower must be a constant number, or a 2-dim array specifing start and stop pumpPower,\n\t or the same length with NStep(current %d) specifing whole envoling time.',...
                    length(ip.Results.pumpPower), obj.NStep, obj.NStep);
            end
            
            switch length(ip.Results.pulsePump)
                case 1
                    obj.pulsePump = linspace(1,1,obj.modeNumber);
                case obj.modeNumber
                    obj.pulsePump = ip.Results.pulsePump./max(abs(ip.Results.pulsePump));
            end
            
            % TODO: select different init state
            % obj.initState = 1; % ip.Results.initState;
            
            fprintf("Solver initiated, evolving time %2.2f/kappa.\n", obj.NStep * obj.timeStep * 2);
        end
        
%         function obj = set.modeNumber(obj,value)
%             obj.modeNumber = value;
%         end



        function solve(obj)
            modeIndexs = linspace(-floor(obj.modeNumber/2), ceil(obj.modeNumber/2)-1,obj.modeNumber)';
            % ----- initialize initial phi function ----- %
            obj.phiResult = zeros(obj.modeNumber, obj.NStep + 1);
            obj.phiResult_Freq = zeros(obj.modeNumber, obj.NStep + 1);
            obj.initializeState();
            % ----- initialize detuning and power evolution array ----- %
            shiftModeIndexs = fftshift(modeIndexs); % DC->max freq->min Freq->DC
            shiftModeIndexs_power  = shiftModeIndexs;
            shiftModeIndexs_power2 = shiftModeIndexs.^2;
            shiftModeIndexs_power3 = shiftModeIndexs.^3;
            shiftModeIndexs_power4 = shiftModeIndexs.^4;
            switch obj.solver
                case 'SSFT'
                    % ----- Split step fourier transform method ------ %
                    fprintf("Using Split step fft method, Sloving...");
                    for kk = 1:obj.NStep
                        k1 = -( 1 + 1i * obj.detuning(kk) * 2 + ... % kappa/2 + i \delta \omega terms.  
                            1i * obj.D1 * shiftModeIndexs_power * 2 + ...
                            1i * obj.D2 * shiftModeIndexs_power2 + ... % dispersion terms
                            1i * obj.D3 * shiftModeIndexs_power3 / 3 + ...
                            1i * obj.D4 * shiftModeIndexs_power4 / 12 ) ...
                            * obj.timeStep; 
                        k2 = ( 1i*abs(obj.phiResult(:,kk)).^2 ) * obj.timeStep;
                        obj.phiResult(:,kk+1) = exp(k2).* ifft(...
                            exp(k1).* fft(obj.phiResult(:,kk)) ...
                            ) + sqrt(obj.pumpPower(kk)) * obj.timeStep * obj.pulsePump';
                        obj.phiResult_Freq(:,kk+1) = fft(obj.phiResult(:,kk+1))/sqrt(length(obj.phiResult(:,kk+1)));
                        if mod(kk,100) == 0
                            fprintf("calculating step %d of %d, %.2f%% finished.\n",kk, obj.NStep, 100 * kk/obj.NStep);
                        end
                    end
                case 'RK'
                    % ----- Runge Kutta method ------ %
                    fprintf("Using Runge Kutta method, Sloving...");
                    pulsePump_freq = fft(obj.pulsePump)'/sqrt(length(obj.pulsePump));
                    obj.pulsePump_freq_debugonly = pulsePump_freq;
                    for kk = 1:obj.NStep-1 % Runge Kutta method
                        %k1
                        aj = ifft(obj.phiResult_Freq(:,kk))*sqrt(length(obj.phiResult_Freq(:,kk)));
                        couple = fft(abs(aj.^2).*aj)/sqrt(length(obj.phiResult_Freq(:,kk)));
                        k1 = -( 1 + 1i * obj.detuning(kk) * 2 + ... % kappa/2 + i \delta \omega terms.   
                            1i * obj.D1 * shiftModeIndexs_power * 2 + ...
                            1i * obj.D2 * shiftModeIndexs_power2 + ... % dispersion terms
                            1i * obj.D3 * shiftModeIndexs_power3 / 3 + ...
                            1i * obj.D4 * shiftModeIndexs_power4 / 12 ).*obj.phiResult_Freq(:,kk) + pulsePump_freq * sqrt(obj.pumpPower(kk)) + 1i*couple;
                        %k2
                        aj = ifft(obj.phiResult_Freq(:,kk) + k1*obj.timeStep/2)*sqrt(length(obj.phiResult_Freq(:,kk)));
                        couple = fft(abs(aj.^2).*aj)/sqrt(length(obj.phiResult_Freq(:,kk)));
                        k2 = -( 1 + 1i * (obj.detuning(kk) + obj.detuning(kk+1)) + ... % kappa/2 + i \delta \omega terms.  
                            1i * obj.D1 * shiftModeIndexs_power * 2 + ...
                            1i * obj.D2 * shiftModeIndexs_power2 + ... % dispersion terms
                            1i * obj.D3 * shiftModeIndexs_power3 / 3 + ...
                            1i * obj.D4 * shiftModeIndexs_power4 / 12 ).*(obj.phiResult_Freq(:,kk)+k1*obj.timeStep/2) + pulsePump_freq * sqrt(obj.pumpPower(kk)) + 1i*couple;
                        %k3
                        aj = ifft(obj.phiResult_Freq(:,kk) + k2*obj.timeStep/2)*sqrt(length(obj.phiResult_Freq(:,kk)));
                        couple = fft(abs(aj.^2).*aj)/sqrt(length(obj.phiResult_Freq(:,kk)));
                        k3 = -( 1 + 1i * (obj.detuning(kk) + obj.detuning(kk+1)) + ... % kappa/2 + i \delta \omega terms.   
                            1i * obj.D1 * shiftModeIndexs_power * 2 + ...
                            1i * obj.D2 * shiftModeIndexs_power2 + ... % dispersion terms
                            1i * obj.D3 * shiftModeIndexs_power3 / 3 + ...
                            1i * obj.D4 * shiftModeIndexs_power4 / 12 ).*(obj.phiResult_Freq(:,kk)+k2*obj.timeStep/2) + pulsePump_freq * sqrt(obj.pumpPower(kk)) + 1i*couple;
                        %k4
                        aj = ifft(obj.phiResult_Freq(:,kk) + k3*obj.timeStep)*sqrt(length(obj.phiResult_Freq(:,kk)));
                        couple = fft(abs(aj.^2).*aj)/sqrt(length(obj.phiResult_Freq(:,kk)));
                        k4 = -( 1 + 1i * obj.detuning(kk+1) * 2 + ... % kappa/2 + i \delta \omega terms.    
                            1i * obj.D1 * shiftModeIndexs_power * 2 + ...
                            1i * obj.D2 * shiftModeIndexs_power2 + ... % dispersion terms
                            1i * obj.D3 * shiftModeIndexs_power3 / 3 + ...
                            1i * obj.D4 * shiftModeIndexs_power4 / 12 ).*(obj.phiResult_Freq(:,kk)+k3*obj.timeStep) + pulsePump_freq * sqrt(obj.pumpPower(kk)) + 1i*couple;
                        %finally
                        obj.phiResult_Freq(:,kk+1) = obj.phiResult_Freq(:,kk) + obj.timeStep/6*(k1+2*k2+2*k3+k4);
                        obj.phiResult(:,kk+1) = ifft(obj.phiResult_Freq(:,kk+1))*sqrt(length(obj.phiResult_Freq(:,kk+1)));
                        if mod(kk,100) == 0
                            fprintf("calculating step %d of %d, %.2f%% finished.\n",kk, obj.NStep, 100 * kk/obj.NStep);
                        end
                    end
            end
            % ------- create reduced phi result for visualization ------- %
            obj.visualizeReduce;
        end
    end
    %% Data visualization model
    methods
        function h = plotPhiAbsAll(obj)
            % h = figure;
            pcolor(obj.reducedPhiIndex, 1:obj.modeNumber, abs(obj.reducedPhi).^2);
            xlabel('Iteration Time Step ($\frac{2}{\kappa}$ per step)','Interpreter','latex');
            ylabel('circular rotation angle $\phi$','Interpreter','latex');
            title('Intracavity field shape evolution over time','Interpreter','latex');
            shading interp
        end
        
        function h = plotIntracavityPower(obj)
            % h = figure;
            intracavityPower = sum(abs(obj.reducedPhi.^2))/obj.modeNumber;
            plot(obj.reducedPhiIndex, intracavityPower);
            xlabel('Iteration Time Step ($\frac{2}{\kappa}$ per step)','Interpreter','latex');
            ylabel('Intracavity power','Interpreter','latex');
            title('Intracavity Power evolution over time','Interpreter','latex');
        end
        
        function h = plotSpectrumFinal(obj)
            % h = figure;
            spectrumFinal = abs(fft(obj.reducedPhi(:,end))/sqrt(obj.modeNumber)).^2;
            spectrumFinal = fftshift(spectrumFinal);
            
            spectrumFinaldbmax = 10*log10(spectrumFinal/max(spectrumFinal)) + 100;
            % arrayfun(@(x) 10*log10(x/max(spectrumFinal)) + 100 ,spectrumFinal);
            mu = linspace(-obj.modeNumber/2,obj.modeNumber/2 - 1,obj.modeNumber).';
            bar(mu,spectrumFinaldbmax);
            xlabel('Iteration Frequency Step ($\frac{\kappa}{2}$ per step)','Interpreter','latex');
            ylabel('Spectrum / (dBmax+100) ','Interpreter','latex');
            title('Final Spectrum','Interpreter','latex');
        end
        
        function h = plotSpectrumAll(obj)
            % h = figure;
            ss = size(obj.reducedPhi);
            spectrumAll = zeros(ss);
            for ii = 1:ss(2)
                temp = abs(fft(obj.reducedPhi(:,ii))/sqrt(obj.modeNumber)).^2;
                spectrumAll(:,ii) = fftshift(temp);
            end
            spectrumAlldb = 10*log10(spectrumAll);
            
            mu = linspace(-obj.modeNumber/2,obj.modeNumber/2 - 1,obj.modeNumber).';
            pcolor(obj.reducedPhiIndex, mu, spectrumAlldb);
            xlabel('Iteration Time Step ($\frac{2}{\kappa}$ per step)','Interpreter','latex');
            ylabel('Iteration Frequency Step ($\frac{\kappa}{2}$ per step)','Interpreter','latex');
            title('Spectrum evolution over time','Interpreter','latex');
            hh = colorbar;
            ylabel(hh ,'Spectrum /dBm ','Interpreter','latex');
            shading interp
        end
        
        
        function plotAll(obj)
            % close all
            figure('Units','normalized','position',[0.1 0.1 0.8 0.8]);
            subplot(221)
            obj.plotIntracavityPower;
            subplot(222)
            obj.plotPhiAbsAll;
            subplot(223)
            obj.plotSpectrumFinal;
            subplot(224)
            obj.plotSpectrumAll;
            fprintf('Calculation finished! Plot showing process...\n');
        end
    end
    %% protected methods
    methods (Access = protected)
        function obj = initializeState(obj)
            if isempty(obj.phiResult) || isempty(obj.phiResult_Freq)
                % check phiResult is already inited
                error('LLESolver:internalError','state cannot init before result storage init');
            end
            
            switch obj.initState
                case 'random'
                    rand('state',sum(100*clock));
                    obj.phiResult_Freq(:,1) = 1e-5 * randn(obj.modeNumber, 1).*exp(1i * 2 * pi * rand(obj.modeNumber, 1));
                    obj.phiResult(:,1) = ifft(obj.phiResult_Freq(:,1))*sqrt(obj.modeNumber);
                otherwise
                    ita=2 * obj.detuning(1);
                    f = sqrt(obj.pumpPower(1));
                    mu = linspace(-obj.modeNumber/2,obj.modeNumber/2 - 1,obj.modeNumber).';
                    obj.phiResult(:,1) = (4*ita/pi/f+1i*sqrt(2*ita-16*ita^2/pi^2/f^2))*sech(sqrt(ita/obj.D2)*mu/obj.modeNumber*2*pi);
                    obj.phiResult_Freq(:,1) = fft(obj.phiResult(:,1))/sqrt(obj.modeNumber);
            end
        end
        
        function visualizeReduce(obj)
            if isempty(obj.phiResult)
                % check phiResult is already inited
                error('LLESolver:internalError','cannot create reduced phi before phi is solved.');
            end
            obj.reducedPhiIndex = floor(obj.NStep/obj.reduceDim) * (1:obj.reduceDim);
            obj.reducedPhi = obj.phiResult(:,obj.reducedPhiIndex);
        end
    end
end