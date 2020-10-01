function [Q0, Q1, QL,findmin_fit_result] = getQwithFP(filename,lambda,tosave)
    % GETQWITHFP Summary of this function goes here
    %   Detailed explanation goes here
    if nargin == 1
        temp = strfind(filename,'-');
        temp2 = strfind(filename,'nm');
        lambda = str2double(filename(temp(end)+1:temp2(end)-1));
        tosave = 0;
    elseif nargin == 2
        tosave = 0;
    end
    filename = char(filename);
    load(filename,'data_matrix');
    MZI_FSR = 39.9553;
    %% define data set to fit    
    Q_trace = data_matrix(:,2);
    MZI_trace = data_matrix(:,3);
    %%--You may use the following code to do sampling if original dataset is too large
    % if length(timeAxis) > 1e3
    %     timeAxis = timeAxis(1:round(length(timeAxis)/1e4):end);
    %     MZI_trace= Ch3(1:round(length(Ch3)/1e4):end);
    %     Q_trace = Ch2(1:round(length(Ch2)/1e4):end);
    % end
    if min(Q_trace)<0
        PD_background = min(Q_trace);
        Q_trace = Q_trace - PD_background;
        warning("transmission < 0 in rawdata, PD background %d mV are added. critical coupling assumed.", PD_background/0.001);
    end
    %% Fit models defination
    % Lorentz-Gibbs lineshape, used for fitting signals after high-pass filters
    % fit_Lorentz_osc=fittype('AL*LS^2*(cos((x-x0)*f0)-(x-x0)/LS*sin((x-x0)*f0))/(LS^2+(x-x0)^2)','coefficients',{'AL','LS','x0'},'problem',{'f0'});
    fit_Lorentz      = fittype(                        'A*(1-LP/(LS^2+(x-x0)^2))','coefficients',{'A','LP','LS','x0'});
    fit_Lorentz_sine = fittype('(A0+B*cos((x-x1)/T*2*pi))*(1-LP/(LS^2+(x-x0)^2))','coefficients',{'A0','B','x1','T','LP','LS','x0'});
    fit_sine         = fittype(' A0+B*cos((x-x1)/T*2*pi)'                        ,'coefficients',{'A0','B','x1','T'});

    fit_fp         = fittype('  A0/( 1-B*cos((x-x1)/T*2*pi) )',                        'coefficients',{'A0','B','x1','T'});
    fit_Lorentz_fp = fittype('( A0/( 1-B*cos((x-x1)/T*2*pi) ))*(1-LP/(LS^2+(x-x0)^2))','coefficients',{'A0','B','x1','T','LP','LS','x0'});
    
    fit_Lorentz_sine_fano = fittype('(A0+B*cos((x-x1)/T*2*pi))      *((x-x0+F0)^2+LS^2-LP)/(LS^2+(x-x0)^2)','coefficients',{'A0','B','x1','T','LP','LS','x0','F0'});
    fit_Lorentz_fp_fano   = fittype('(A0/( 1-B*cos((x-x1)/T*2*pi)) )*((x-x0+F0)^2+LS^2-LP)/(LS^2+(x-x0)^2)','coefficients',{'A0','B','x1','T','LP','LS','x0','F0'});


    %% Fit FP background
    Q_trace_freq = abs(fft(Q_trace));
    % figure;
    % plot(Q_trace_freq)
    Q_trace_freq_temp = Q_trace_freq;
    Q_trace_freq_temp(1) = 0;
    [amp_fp,pos_fp] = max(Q_trace_freq_temp(1:round(end/2)));
    fit_T_estimate = length(Q_trace_freq)/(pos_fp-1);
    if pos_fp < 3
        fit_T_estimate = 0.5*length(Q_trace_freq);
    end
            fit_T_estimate = 1*length(Q_trace_freq);
    
    fit_B_estimate = amp_fp/length(Q_trace_freq);
    fit_A0_estimate = mean(Q_trace);

    fp_fit = fit( (1:length(Q_trace)).',Q_trace,fit_fp,...
        'StartPoint',[fit_A0_estimate fit_B_estimate length(Q_trace_freq)/2 fit_T_estimate]);
    fp_fit_result = fp_fit((1:length(Q_trace)).');%fp_fit.A0+fp_fit.B*cos(((1:length(Q_trace)).'-fp_fit.x1)/fp_fit.T*2*pi);


%             figure
%             plot((1:length(Q_trace)).',Q_trace);
%             hold on
%             plot((1:length(Q_trace)).',MZI_trace);
%             title("Original data")
% 
%             figure
%             plot((1:length(Q_trace)).',Q_trace)
%             hold on
%             scatter((1:length(Q_trace)).',fp_fit_result);
%             title("FP fitting")
            
    %% Peak position find and parameter estimation
    % First get difference between FP background and Q_trace original data
    peak_trace_temp = Q_trace - fp_fit_result;
    % Where deviation most is the position of the dip
    [amp_peak,pos_peak] = min(peak_trace_temp);
    base_local = fp_fit_result(pos_peak); % FP background at the position of dip
     dip_local = Q_trace(pos_peak); % dip depth
     mid_local = (dip_local + base_local)/2; % middle depth of the dip, used to estimate FWHM

        transmission_estimate = dip_local/base_local; % transmission estimation at the dip
    dip_boundary_pos_estimate = [find(peak_trace_temp < mid_local-base_local, 1 ), ...
                                 find(peak_trace_temp < mid_local-base_local, 1, 'last' )]; % Cut off position at linewidth FWHM
           linewidth_estimate = abs(diff(dip_boundary_pos_estimate)); % linewidth is difference of FWHM cut off position
    % Then pick the data range to fit
    pos_fitstart = round(0.03*length(Q_trace));
    pos_fitend   = round(0.97*length(Q_trace));
    pos_fitrange = 1200; % times of linewidth, Q to fit range
    pos_fitstart = round(max(0.03*length(Q_trace) , pos_peak - pos_fitrange*linewidth_estimate/2)); % fitting range is peak position � pos_fitrange/2 linewidth
    pos_fitend   = round(min(0.97*length(Q_trace) , pos_peak + pos_fitrange*linewidth_estimate/2)); % fitting range is peak position � pos_fitrange/2 linewidth

    Q_trace_tofit   =   Q_trace(pos_fitstart:pos_fitend);
    MZI_trace_tofit = MZI_trace(pos_fitstart:pos_fitend);
    peak_trace_temp = peak_trace_temp(pos_fitstart:pos_fitend); % peak_trace_temp = Q_trace - fp background.
    % update position information because we picked only part of original data
    pos_peak                  = pos_peak                  - pos_fitstart + 1;
    dip_boundary_pos_estimate = dip_boundary_pos_estimate - pos_fitstart + 1;

    %             figure
    %             plot(Q_trace_tofit);
    %             hold on
    %             plot(MZI_trace_tofit);
    %             title("data to fit")

    
    %% Peak with FP background fitting
    % parameter estimation
    fit_A0_estimate = fp_fit.A0;
    fit_B_estimate = fp_fit.B;
    fit_x1_estimate = mod(fp_fit.x1, fp_fit.T);
    fit_T_estimate = fp_fit.T;
    fit_LP_estimate = (1-transmission_estimate)*linewidth_estimate^2/4;
    fit_LS_estimate = linewidth_estimate/2;
    fit_x0_estimate = pos_peak;  
    
    %% ----------Give the peak position higher weight---------------
    fit_weight_dip = 1*ones(length(Q_trace_tofit),1);
%     fit_weight_dip = zeros(length(Q_trace_tofit),1);
    fit_weight_fp = fit_weight_dip;
    
    weight_width = 5; % times of linewidth
    weight_start = max(round(pos_peak - 1.0*weight_width*linewidth_estimate/2),1);
    weight_end   = min(round(pos_peak + 1.0*weight_width*linewidth_estimate/2),length(Q_trace_tofit));
%     fit_weight_dip(weight_start:weight_end) = 1; %10*max(round(length(Q_trace_tofit)/(weight_end-weight_start)),1);
    fit_weight_fp(weight_start:weight_end) = 0;
% % % %     --------Delete these lines later, --------
% % % %     --------for a mode with accompany mode at side------
% % % %         fit_weight_fp(weight_end:end) = 10;
% % % %         weight_start = max(round(pos_peak + 0.7*weight_width*linewidth_estimate/2),1);
% % % %         weight_end   = min(round(pos_peak + 1.1*weight_width*linewidth_estimate/2),length(Q_trace_tofit));
% % % %         fit_weight_fp(weight_start:weight_end) = 0;
        
    
    weight_width = 20; % times of linewidth
    weight_start = max(round(pos_peak - 1.0*weight_width*linewidth_estimate/2),1);
    weight_end   = min(round(pos_peak + 1.0*weight_width*linewidth_estimate/2),length(Q_trace_tofit));
    fit_weight_dip(weight_start:weight_end) = 10; %10*max(round(length(Q_trace_tofit)/(weight_end-weight_start)),1);
% % % %     --------Delete these lines later--------
% % % %     --------for a mode with accompany mode at side------
% % % %         weight_start = max(round(pos_peak + 0.7*20*linewidth_estimate/2),1);
% % % %         weight_end   = min(round(pos_peak + 1.1*20*linewidth_estimate/2),length(Q_trace_tofit));
% % % %         fit_weight_dip(weight_start:weight_end) = 0;
% % % %         fit_weight_dip(weight_end:end) = 1;
        
    % ----------weighing module finished---------------
    MZI_trace_local_start  = pos_fitstart;%max(round(0.03*length(MZI_trace_tofit)) , pos_peak - 10*linewidth_estimate);
    MZI_local_local_end    = pos_fitend;%min(round(0.97*length(MZI_trace_tofit)) , pos_peak + 10*linewidth_estimate);
    MZI_trace_local        = MZI_trace_tofit;%(MZI_trace_local_start:MZI_local_local_end);
    MZI_trace_local_phasor = hilbert(MZI_trace_local-mean(MZI_trace_local));
    MZI_trace_local_phase  = [0;cumsum(mod(diff(angle(MZI_trace_local_phasor))+pi,2*pi)-pi)]+angle(MZI_trace_local_phasor(1));
    MZI_period_local       = round(2*pi/mean( angle(MZI_trace_local_phasor(2:end)./MZI_trace_local_phasor(1:end-1) ) ) );
    x_freq = (MZI_trace_local_phase/2/pi*2*pi/mean( diff(MZI_trace_local_phase) )).';
    
    fit_x0_estimate = x_freq(fit_x0_estimate);
    %% Begin fitting Here
    % first redo the FP (2nd fp)
    fp_fit_2 = fit( x_freq.',Q_trace_tofit,fit_fp,...
        'StartPoint',[fit_A0_estimate fit_B_estimate length(Q_trace_freq)/2 fit_T_estimate],...
        'Weight',fit_weight_fp);
    fp_fit_result_2 = fp_fit_2(x_freq.');%fp_fit.A0+fp_fit.B*cos(((1:length(Q_trace)).'-fp_fit.x1)/fp_fit.T*2*pi);

%             figure
            figure('Units', 'Normalized', 'OuterPosition', [0.1, 0.45, 0.75, 0.5])
            subplot(131)
            plot(x_freq.',Q_trace_tofit,'Linewidth',2.0)
            hold on
            scatter(x_freq.',fp_fit_result_2, 5);
            hold on
            plot(x_freq.',fit_weight_fp*max(Q_trace_tofit)/max(fit_weight_fp));
            title(sprintf("FP 2nd fitting result, %g nm.\n T=%g",lambda,fp_fit_2.T ));

    fit_A0_estimate = fp_fit_2.A0;
    fit_B_estimate = fp_fit_2.B;
    fit_x1_estimate = mod(fp_fit_2.x1, fp_fit_2.T);
    fit_T_estimate = fp_fit_2.T;
%     
    Q_withfp_fit=fit( x_freq.', Q_trace_tofit, fit_Lorentz_fp, ...
        'StartPoint', [fit_A0_estimate, fit_B_estimate, fit_x1_estimate, fit_T_estimate...
                        fit_LP_estimate, fit_LS_estimate, fit_x0_estimate],...
                    'Weight',fit_weight_dip ); % Lorentz with FP fit, {'A0','B','x1','T','LP','LS','x0'}
                
%  % ---------------------- For Debug Only, cross validation to Q_trace_fit.m using pure Lorentian----------------------%
%     Q_withfp_fit=fit( (1:length(Q_trace_tofit)).', Q_trace_tofit, fit_Lorentz, ...
%                         'StartPoint', [fit_A0_estimate,fit_LP_estimate, fit_LS_estimate, fit_x0_estimate],...
%                          'Weight',fit_weight_dip ); % Lorentz fit, {'A','LP','LS','x0'}
%  % ---------------------- For Debug Only, cross validation Finished --------------------------------------------------%
% 
%     % -------Fit with Fano-----------%
%     Q_withfp_fit=fit( (1:length(Q_trace_tofit)).', Q_trace_tofit, fit_Lorentz_fp_fano, ...
%         'StartPoint', [fit_A0_estimate, fit_B_estimate, fit_x1_estimate, fit_T_estimate...
%                         fit_LP_estimate, fit_LS_estimate, fit_x0_estimate 0],...
%                     'Weight',fit_weight_dip ); % Lorentz with FP fit, {'A0','B','x1','T','LP','LS','x0','F'}
                 
    Q_withfp_fit_result = Q_withfp_fit( x_freq.' );
    kappa  = 2*abs(Q_withfp_fit.LS); % LS may be negative due to nonlinear fitting
    kappa0 = abs(Q_withfp_fit.LS)+sqrt(Q_withfp_fit.LS^2-Q_withfp_fit.LP);
    fitted_transmission = 1-Q_withfp_fit.LP/Q_withfp_fit.LS^2;
    if Q_withfp_fit.LS^2-Q_withfp_fit.LP<0 
        % Near critical coupling, sometime fitted lorentian has negative transmission, result in imaginary kappa.
        % Solve the problem and give a warning here.
        if (abs(kappa0)-kappa/2)/kappa < 0.05 % first check imaginary part are actually neglectable.
            kappa0 = kappa/2; % Critical coupling condition
            fitted_transmission = 0;
            warning("transmission < 0 in fitting result. Critical coupling are assumed. kappa0 = kappa/2.");
        else % In this case probabily the fitting process are failed. Contact Maodong for more help.
            figure
            plot(x_freq.',Q_trace_tofit)
            hold on
            scatter(x_freq.',Q_withfp_fit_result);
            title("Q trace with FP fitting")
            % Of course you can increase the 0.05 threshold to pass this
            % checkpoint, as long as you can tolerate the fititng result.
            error("kappa0 fitted result has unneglectable imaginary part. Need check estimation value and debug.");
        end
    end
    
    % Q_baseline=Q_withfp_fit.A;
    % transmission=Q_withfp_fit(Q_withfp_fit.x0)/Q_withfp_fit.A;
% 
%             figure
%             plot((1:length(Q_trace_tofit)).',Q_trace_tofit,'Linewidth',2.0)
%             hold on
%             scatter((1:length(Q_trace_tofit)).',Q_withfp_fit_result,5);
%             title("Q trace with FP fitting")

    %% Then fit MZI with Q trace
    
    % MZI_fit_T = 4*pi*round(MZI_period_local/4) /( MZI_trace_local_phase(round(min(end/2 + MZI_period_local/4,end))) - MZI_trace_local_phase(round(max(end/2 - MZI_period_local/4,1))) );
    MZI_fit_T = 4*pi*round(MZI_period_local/4) / ...
        ( MZI_trace_local_phase( round( min(length(MZI_trace_local_phase)/2 + MZI_period_local/4, length(MZI_trace_local_phase) )))...
        - MZI_trace_local_phase( round( max(length(MZI_trace_local_phase)/2 - MZI_period_local/4, 1                             ))) );

    Q0=299792.458/lambda/( kappa0       /MZI_fit_T * MZI_FSR);
    Q1=299792.458/lambda/((kappa-kappa0)/MZI_fit_T * MZI_FSR);
    QL=299792.458/lambda/( kappa        /MZI_fit_T * MZI_FSR);
    
    
    %% SiN: previous codes failed somehow, 
            Q_obj = Q_trace_fit(Q_trace_tofit./fp_fit_result_2,MZI_trace_tofit,MZI_FSR, lambda, 0.7,'fanomzi'); % 0.4 is sensitivity
            mode_Q = Q_obj.get_Q;
            Q0 = mode_Q(1)
            Q1 = mode_Q(2)
            QL = 1/(1/Q0+1/Q1);
    %%
%             figure
            subplot(132)
            plot(x_freq.',Q_trace_tofit,'Linewidth',2.0)
            hold on
            plot_step = 1;
            scatter(x_freq.',Q_withfp_fit_result(1:plot_step:length(Q_trace_tofit)) ,5); % last parameter is Marker size
            hold on
            plot(x_freq.',fit_weight_dip*max(Q_trace_tofit)/max(fit_weight_dip));
            title(sprintf("Q trace with FP fitting, NO FP, %g nm\n Q0=%.4gM, Q1=%.4gM, Q=%.4gM, Trans=%.4g",lambda,Q0,Q1,QL,fitted_transmission))
            
            % % --------save fig----------
%             filename_tosave = strcat(filename(1:end-4),'-FPfitting.fig');
%             if isfile(filename_tosave)
%                 backup_filename = strcat(filename_tosave(1:end-4),'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.fig');
%                 movefile(filename_tosave,backup_filename);
%                 warning('Old file was renamed!')
%             end
%             saveas(gcf,filename_tosave);

    %% ------------ fit FP dip with interference ---------
% %             % % ----This part is actually a 2nd appearance in this file,
% %             % % ----rewrite only for convenience----
% %             % %----------Give the peak position higher weight---------------
% %                 fit_weight_dip = 0.05*ones(length(Q_trace_tofit),1);
% %                 fit_weight_fp = fit_weight_dip;
% %                 weight_width = 10; % times of linewidth
% %                 weight_start = max(round(pos_peak - weight_width*linewidth_estimate/2),1);
% %                 weight_end   = min(round(pos_peak + weight_width*linewidth_estimate/2),length(Q_trace_tofit));
% %                 fit_weight_dip(weight_start:weight_end) = 1; %10*max(round(length(Q_trace_tofit)/(weight_end-weight_start)),1);
% %                 fit_weight_fp(weight_start:weight_end) = 0;
% %             % % ----------weighing module finished---------------
%         
        % % -----recalculate parameters in the new formula, using fitted FP background result.
        r1r2 = ( 1-sqrt(1-fp_fit_2.B^2) )/fp_fit_2.B ;
        fit_A0_estimate_new = fp_fit_2.A0 * (1+r1r2^2);
        fit_B_estimate_new  = fp_fit_2.B  * (1+r1r2^2);
        % % --------recalculate finished--------
        
%         % % --------treat FP as free parameters, complex form--------------
%         
% %         fit_interfere_complexform = fittype(@(A0,r,x1,T,k0,ke,x0,x)( A0.*abs((1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2)).^2 )./ (abs(1-r.*( (1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2) ).^2 .* exp(1i*2*pi*(x-x1)./T) ).^2)  );
% %         fit_interfere_complexform = fittype('( A0.*abs((1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2)).^2 )./ (abs(1-r.*( (1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2) ).^2 .* exp(1i*2*pi*(x-x1)./T) ).^2) ',...
% %                                             'coefficients',{'A0','r','x1','T','ke','k0','x0'});
% %         Q_withfp_interfere_fit = fit( (1:length(Q_trace_tofit)).', Q_trace_tofit, fit_interfere_complexform, ...
% %         'StartPoint', [fit_A0_estimate_new, r1r2, fit_x1_estimate, fit_T_estimate...
% %                         kappa0, 2*kappa-2*kappa0, fit_x0_estimate],...
% %                     'Weight',fit_weight_dip );
% 
%         % % ----------treat FP as problem arguments, complex form------------
%         fit_interfere_complexform = fittype(@(A0,r,x1,T,k0,ke,x0,x)( A0.*abs((1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2)).^2 )./ (abs(1-r.*( (1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2) ).^2 .* exp(1i*2*pi*(x-x1)./T) ).^2)  );
%         fit_interfere_complexform = fittype('( A0*abs((1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2)).^2 )./ (abs(1-r*( (1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2) ).^2 .* exp(-1i*2*pi*(x-x1)/T) ).^2) ',...
%                                             'coefficients',{'ke','k0','x0'},...
%                                             'problem',{'A0','r','x1','T'});
%         Q_withfp_interfere_fit = fit( (1:length(Q_trace_tofit)).', Q_trace_tofit, fit_interfere_complexform, ...
%                                     'StartPoint', [568, 124, fit_x0_estimate],...
%                                     'problem',{fit_A0_estimate_new, r1r2, fit_x1_estimate, fit_T_estimate},...
%                                     'Weight',fit_weight_dip );
% 
%         % % --------treat FP as free parameters--------------
% %         fit_Lorentz_fp_interfere = fittype('( A0/( 1 + (B/2)^2*(1-LP/(LS^2+(x-x0)^2))^2 - B* (1-LP/(LS^2+(x-x0)^2)) *cos((x-x1)/T*2*pi + 2* atan(sqrt(LS^2-LP)/(x-x0)) - 2* atan( 2*abs(LS)/(x-x0) ) )))*(1-LP/(LS^2+(x-x0)^2))',...
% %                                          'coefficients',{'A0','B','x1','T','LP','LS','x0'});
% %         Q_withfp_interfere_fit = fit( (1:length(Q_trace_tofit)).', Q_trace_tofit, fit_Lorentz_fp_interfere, ...
% %         'StartPoint', [fit_A0_estimate_new, fit_B_estimate_new, fit_x1_estimate, fit_T_estimate...
% %                         fit_LP_estimate, fit_LS_estimate, fit_x0_estimate],...
% %                     'Weight',fit_weight_dip );
%         % % ----------treat FP as problem arguments------------
% %         fit_Lorentz_fp_interfere = fittype('( A0/( 1 + (B/2)^2*(1-LP/(LS^2+(x-x0)^2))^2 - B* (1-LP/(LS^2+(x-x0)^2)) *cos((x-x1)/T*2*pi + 2* atan(sqrt(LS^2-LP)/(x-x0)) - 2* atan( 2*abs(LS)/(x-x0) ) )))*(1-LP/(LS^2+(x-x0)^2))',...
% %                                          'coefficients',{'LP','LS','x0'}, 'problem',{'A0','B','x1','T'});
% %         Q_withfp_interfere_fit = fit( (1:length(Q_trace_tofit)).', Q_trace_tofit, fit_Lorentz_fp_interfere, ...
% %                     'StartPoint', [fit_LP_estimate, fit_LS_estimate, fit_x0_estimate],...
% %                     'problem',{fit_A0_estimate_new, fit_B_estimate_new, fit_x1_estimate, fit_T_estimate},...
% %                     'Weight',fit_weight_dip );
%         % % -------fitting code finished--------------
%         
%         % % ================================================================
%         % % -------extract kappa from fitting results, real form----------
% %         kappa  = 2*abs(Q_withfp_interfere_fit.LS); % LS may be negative due to nonlinear fitting
% %         kappa0 = abs(Q_withfp_interfere_fit.LS)+sqrt(Q_withfp_interfere_fit.LS^2-Q_withfp_interfere_fit.LP);
% %         fitted_transmission = 1-Q_withfp_interfere_fit.LP/Q_withfp_interfere_fit.LS^2;
%         % % -------extract kappa from fitting results, complex form----------
%         kappa = Q_withfp_interfere_fit.k0 + Q_withfp_interfere_fit.ke;
%         kappa0 = Q_withfp_interfere_fit.k0;
%         fitted_transmission = abs((Q_withfp_interfere_fit.k0 - Q_withfp_interfere_fit.ke)/kappa)^2;
%         
%         
%         Q0=299792.458/lambda/( kappa0       /MZI_fit_T * MZI_FSR);
%         Q1=299792.458/lambda/((kappa-kappa0)/MZI_fit_T * MZI_FSR);
%         QL=299792.458/lambda/( kappa        /MZI_fit_T * MZI_FSR);
%         
%         Q_withfp_interfere_fit_result = Q_withfp_interfere_fit( (1:length(Q_trace_tofit)).' );
%         
%             figure
%             plot((1:length(Q_trace_tofit)).',Q_trace_tofit,'Linewidth',2.0)
%             hold on
%             plot_step = 1;
%             scatter((1:plot_step:length(Q_trace_tofit)).',Q_withfp_interfere_fit_result(1:plot_step:length(Q_trace_tofit)) ,5); % last parameter is Marker size
%             hold on
%             plot((1:length(Q_trace_tofit)).',fit_weight_dip*max(Q_trace_tofit)/max(fit_weight_dip));
%             title(sprintf("Q trace with FP fitting, INCLUDED interference, %g nm\n Q0=%.4gM, Q1=%.4gM, Q=%.4gM, Trans=%.4g",lambda,Q0,Q1,QL,fitted_transmission))
%  
% 
% %% --Direct estimation by directly plot transmission. Added for debug--
%             kappa0_direct_estimate = 5*kappa0;
%             kappae_direct_estimate = 0.5*(kappa-kappa0);
%             
%             Q0=299792.458/lambda/( kappa0_direct_estimate                            /MZI_fit_T * MZI_FSR);
%             Q1=299792.458/lambda/(                           kappae_direct_estimate  /MZI_fit_T * MZI_FSR);
%             QL=299792.458/lambda/( (kappa0_direct_estimate + kappae_direct_estimate) /MZI_fit_T * MZI_FSR);
%             fitted_transmission = abs((kappa0_direct_estimate - kappae_direct_estimate)/(kappa0_direct_estimate + kappae_direct_estimate))^2;
%             
%             figure
%             plot((1:length(Q_trace_tofit)).',Q_trace_tofit,'Linewidth',2.0)
%             hold on
%             plot_step = 1;
%             %scatter((1:plot_step:length(Q_trace_tofit)).',Q_withfp_interfere_fit_result(1:plot_step:length(Q_trace_tofit)) ,5); % last parameter is Marker size
%             scatter((1:plot_step:length(Q_trace_tofit)).', modtrans(fit_A0_estimate_new,r1r2, fit_x1_estimate, fit_T_estimate,kappa0_direct_estimate, kappae_direct_estimate,fit_x0_estimate, (1:plot_step:length(Q_trace_tofit)).' ) ,5);
%             title(sprintf("Q trace with FP fitting, INCLUDED interference, %g nm\n Q0=%.4gM, Q1=%.4gM, Q=%.4gM, Trans=%.4g",lambda,Q0,Q1,QL,fitted_transmission))
%% -- Write my own fminsearch to fit --
            % % ----This part is actually a 3rd appearance in this file,

%             % % ----rewrite only for convenience----
%             % %----------Give the peak position higher weight---------------
                fit_weight_dip = 1*ones(length(Q_trace_tofit),1);
                fit_weight_fp = fit_weight_dip;
                weight_width = 20; % times of linewidth
                weight_start = max(round(pos_peak - weight_width*linewidth_estimate/2),1);
                weight_end   = min(round(pos_peak + weight_width*linewidth_estimate/2),length(Q_trace_tofit));
                fit_weight_dip(weight_start:weight_end) = 10; %10*max(round(length(Q_trace_tofit)/(weight_end-weight_start)),1);
                fit_weight_fp(weight_start:weight_end) = 0;
%             % % ----------weighing module finished---------------

        Q0_findmin_estimate = Q0;%1.8; % Estimate Q0 should be around 1.8M
        Q1_findmin_estimate = Q1;%8.0; % Estimate Qe should be around 8.0M
        kappa0_findmin_estimate = 299792.458/lambda/( Q0_findmin_estimate /MZI_fit_T * MZI_FSR);
        kappae_findmin_estimate = 299792.458/lambda/( Q1_findmin_estimate /MZI_fit_T * MZI_FSR);
        
%         % % % Fit everything version
%         findmin_fun = @(paras)LCL(modtrans_residual(paras(1),paras(2),paras(3),paras(4),paras(5),paras(6),paras(7),x_freq.',Q_trace_tofit) ,fit_weight_dip);
%         findmin_start_point = [fit_A0_estimate_new, r1r2, fit_x1_estimate, fit_T_estimate, kappa0_findmin_estimate, kappae_findmin_estimate,fit_x0_estimate];
% %         options = optimset('MaxFunEvals',5000);
%         findmin_fit_result = fminsearch(findmin_fun,findmin_start_point);
        
        % % % Don't re-fit FP version
        findmin_fun = @(paras)LCL(modtrans_residual(fit_A0_estimate_new,r1r2,fit_x1_estimate,fit_T_estimate,paras(1),paras(2),paras(3),x_freq.',Q_trace_tofit) ,fit_weight_dip);
        findmin_start_point = [kappa0_findmin_estimate, kappae_findmin_estimate,fit_x0_estimate];
%         options = optimset('MaxFunEvals',5000);
        findmin_fit_result = fminsearch(findmin_fun,findmin_start_point);
        findmin_fit_result = [fit_A0_estimate_new, r1r2, fit_x1_estimate, fit_T_estimate,findmin_fit_result];
        
        Q0=299792.458/lambda/(  findmin_fit_result(5)                           /MZI_fit_T * MZI_FSR);
        Q1=299792.458/lambda/(                           findmin_fit_result(6)  /MZI_fit_T * MZI_FSR);
        QL=299792.458/lambda/(( findmin_fit_result(5) +  findmin_fit_result(6)) /MZI_fit_T * MZI_FSR);
        fitted_transmission = abs((findmin_fit_result(5) -  findmin_fit_result(6))/(findmin_fit_result(5) +  findmin_fit_result(6)))^2;

%             figure
            subplot(133)
            plot(x_freq.',Q_trace_tofit,'Linewidth',2.0)
            hold on
            plot_step = 1;
            %scatter((1:plot_step:length(Q_trace_tofit)).',Q_withfp_interfere_fit_result(1:plot_step:length(Q_trace_tofit)) ,5); % last parameter is Marker size
            scatter(x_freq.', modtrans(findmin_fit_result(1),findmin_fit_result(2),findmin_fit_result(3),...
                                                                    findmin_fit_result(4),findmin_fit_result(5),findmin_fit_result(6),...
                                                                    findmin_fit_result(7), x_freq.' ) ,5);
            hold on
%                     scatter(x_freq.', modtrans(findmin_fit_result(1),findmin_fit_result(2),findmin_fit_result(3),...
%                                                                             findmin_fit_result(4),findmin_fit_result(6),findmin_fit_result(5),...
%                                                                             findmin_fit_result(7), x_freq.' ) ,5);
%                     hold on
            plot(x_freq.',fit_weight_dip*max(Q_trace_tofit)/max(fit_weight_dip));
            title(sprintf("Q trace with FP fitting, INCLUDED interference, %g nm\n Q0=%.4gM, Q1=%.4gM, Q=%.4gM, Trans=%.4g",lambda,Q0,Q1,QL,fitted_transmission))
%             legend(["original data","fitted data","exchange Qo and Qe"],'location','best');
            
            % --------- Plot another one to save ---------
                    figure;
                    plot(x_freq.',Q_trace_tofit,'Linewidth',2.0)
                    hold on
                    plot_step = 1;
                    %scatter((1:plot_step:length(Q_trace_tofit)).',Q_withfp_interfere_fit_result(1:plot_step:length(Q_trace_tofit)) ,5); % last parameter is Marker size
                    scatter(x_freq.', modtrans(findmin_fit_result(1),findmin_fit_result(2),findmin_fit_result(3),...
                                                                            findmin_fit_result(4),findmin_fit_result(5),findmin_fit_result(6),...
                                                                            findmin_fit_result(7), x_freq.' ) ,5);
                    hold on
%                                         scatter(x_freq.', modtrans(findmin_fit_result(1),findmin_fit_result(2),findmin_fit_result(3),...
%                                                                             findmin_fit_result(4),findmin_fit_result(6),findmin_fit_result(5),...
%                                                                             findmin_fit_result(7), x_freq.' ) ,5);
%                                         hold on

                    plot(x_freq.',fit_weight_dip*max(Q_trace_tofit)/max(fit_weight_dip));
                    title(sprintf("Q trace with FP fitting, INCLUDED interference, %g nm\n Q0=%.4gM, Q1=%.4gM, Q=%.4gM, Trans=%.4g",lambda,Q0,Q1,QL,fitted_transmission))
%                         legend(["original data","fitted data","exchange Qo and Qe"],'location','best');

            
            if tosave
%                 % --------save fig----------
%                 filename_tosave = strcat(filename(1:end-4),'-FPfitting.fig');
%                 if isfile(filename_tosave)
%                     backup_filename = strcat(filename_tosave(1:end-4),'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.fig');
%                     movefile(filename_tosave,backup_filename);
%                     warning('Old file was renamed!')
%                 end
%                 saveas(gcf,filename_tosave);
                
                tt = strfind(filename,'\');
                    file_tosave_dir = filename(1:tt(end));
                    file_tosave_dir = strcat(file_tosave_dir,'Fitting_results');
                   if ~isfolder(file_tosave_dir)
                       mkdir(file_tosave_dir);
                   end
                    % --------save fig----------
                    filename_tosave = strcat(file_tosave_dir,'\',filename(tt(end)+1:end-4),'-FP-Q-fitting.fig');
%                     if isfile(filename_tosave)
%                         backup_filename = strcat(filename_tosave(1:end-4),'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.fig');
%                         movefile(filename_tosave,backup_filename);
%                         warning('Old file was renamed!')
%                     end
                    saveas(gcf,filename_tosave);
                    filename_tosave = strcat(file_tosave_dir,'\',filename(tt(end)+1:end-4),'-FP-Q-fitting.png');
                    saveas(gcf,filename_tosave);
            end
end



%% MZI to Phase function
function phase = MZI2Phase(trace_MZI)
    trace_length = length(trace_MZI);
    trace_MZI_tofit = trace_MZI;
    % trace_MZI_tofit = sgolayfilt(trace_MZI, 1, 11);
    Base = (max(trace_MZI_tofit) + min(trace_MZI_tofit))/2;
    trace_MZI_phasor = hilbert(trace_MZI_tofit - Base); % use phasor for non-parametric fit

    trace_MZI_phase = [0; cumsum(mod(diff(angle(trace_MZI_phasor))+pi, 2*pi) - pi)] + angle(trace_MZI_phasor(1));
    % trace_MZI_phase = sgolayfilt(trace_MZI_phase, 1, 11);
    phase = sgolayfilt(trace_MZI_phase, 2, round(trace_length/40)*2 + 1);
    % phase = trace_MZI_phase;
end
%% fminsearch loss functions
function dd = modtrans(A0,r,x1,T,k0,ke,x0,x) %(x,x0,k0,ke,r,x1,T,A0)
    dd=( A0*abs((1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2)).^2 )./ (abs(1-r*( (1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2) ).^2 .* exp(-1i*2*pi*(x-x1)/T) ).^2);
end

function rr = modtrans_residual(A0,r,x1,T,k0,ke,x0,x,   trans)
    % trans is the real transmission. calculate residual
    rr = trans - modtrans(A0,r,x1,T,k0,ke,x0,x);
end

function loss = QLF(rr,weight) %Quadratic Loss Function
    if nargin == 1
        weight = ones(size(rr));
    end
    loss = sum( weight.*(rr.^2) )/length(rr);
end

function loss = LCL(rr,weight) % Log-Cosh Loss
    if nargin == 1
        weight = ones(size(rr));
    end
    loss = sum( weight .* log(cosh(rr)) ) / length(rr);
end
