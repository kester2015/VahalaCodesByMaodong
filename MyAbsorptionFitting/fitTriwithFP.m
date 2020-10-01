function [findmin_fit_result] = fitTriwithFP(data_filename, mode_Q0, mode_Qe, lambda, tosave)
    % input Q should be in units of Million!
    % Output parameters:
    % [fp_fit.A0*(1+r1r2^2), r1r2, fp_fit.x1, fp_fit.T, kappa0, kappae, dip_x0, alpha, rescaled_alpha]
    % alpha calculated here is in ""
    
    if nargin == 4
        tosave = 0;
    end
    load(data_filename,'timeAxis','Ch2','Ch3');
    if ~exist('timeAxis','var')
        load(data_filename,'data_matrix');
        timeAxis = data_matrix(:,1);
        Ch2 = data_matrix(:,2);
        Ch3 = data_matrix(:,3);
    end
    MZI_FSR = 39.9553; % MHz

    % function fitTriwithFP_main(data_filename,lambda,)
    %         load('Z:\Qifan\Tantala\20200819-thermal-rawdata\Dev21\1540nm-02-mat\Sweep_20Hz_Power_0.3V.mat','timeAxis','Ch2','Ch3')
    % 
    %         lambda = 1540.4;
    %         MZI_FSR = 39.9553; % MHz

%     if length(timeAxis) > 1e4
%             timeAxis = timeAxis(1:round(length(timeAxis)/1e4):end);
%             Ch3= Ch3(1:round(length(Ch3)/1e4):end);
%             Ch2 = Ch2(1:round(length(Ch2)/1e4):end);
%     end
    %     Ch2 = sgolayfilt(Ch2, 2, round(length(Ch2)/1000)*2 + 1);
    %%
    MZI = Ch3(1:end);
    Trans =  Ch2(1:end);

    if min(Trans)<0
            PD_background = min(Trans);
            Trans = Trans - PD_background;
            %warning(["transmission < 0 in rawdata, PD background %d mV are added. critical coupling assumed.", num2str(PD_background/0.001)]);
    end

    % Trans = Trans * sqrt(inputPower2 *outputPower2) * 1e-3 / sqrt(inputVoltage2 * outputVoltage2); % in unit of power;

    Trans_raw = Trans;

    MZI_phase = MZI2Phase(MZI);
    MZI_period_local       = round(2*pi/mean( diff(MZI_phase) ) );
    MZI_fit_T = 4*pi*round(MZI_period_local/4) / ...
            ( MZI_phase( round( min(length(MZI_phase)/2 + MZI_period_local/4, length(MZI_phase) )))...
            - MZI_phase( round( max(length(MZI_phase)/2 - MZI_period_local/4, 1                 ))) );
    
    x_freq = (MZI_phase /2/pi*2*pi / mean( diff(MZI_phase) )  ).';
    %%  First fit FP background
    fit_sine = fittype(' A0 +  B*cos((x-x1)/T*2*pi) ','coefficients',{'A0','B','x1','T'});
    fit_fp   = fittype(' A0   / ( 1-B*cos( (x-x1)/T*2*pi) )','coefficients',{'A0','B','x1','T'});
%     fit_fp   = fittype(' A0*abs(1 / ( 1-B*exp(-(x-x1)/T*2*pi) ) ).^2','coefficients',{'A0','B','x1','T'});

    Q_trace_freq = abs(fft(Trans_raw));
    Q_trace_freq_temp = Q_trace_freq;
    Q_trace_freq_temp(1) = 0;
    Q_trace_freq_temp = Q_trace_freq_temp(1:round(length(Trans_raw)/2));
    [amp_fp,pos_fp] = max(Q_trace_freq_temp);
    fit_T_estimate = length(Q_trace_freq)/(pos_fp-1);
    if pos_fp < 3
        fit_T_estimate = 2*length(Q_trace_freq);
    end
            fit_T_estimate = 0.5*length(Q_trace_freq);

    fit_B_estimate = amp_fp/length(Q_trace_freq);
    fit_A0_estimate = mean(Trans_raw);

    fp_fit_1 = fit( x_freq.',Trans_raw,fit_fp,...
                'StartPoint',[fit_A0_estimate fit_B_estimate length(Q_trace_freq)/2 fit_T_estimate],...
                'Weights',Trans_raw.^2);
    fp_fit_result_1 = fp_fit_1(x_freq.');%fp_fit.A0+fp_fit.B*cos(((1:length(Q_trace)).'-fp_fit.x1)/fp_fit.T*2*pi);
    fit_A0_estimate = fp_fit_1.A0;
    fit_A0_estimate = mean(Trans_raw);
%     fit_B_estimate  = fp_fit_1.B;
    fit_x1_estimate = fp_fit_1.x1;
%     fit_T_estimate  = fp_fit_1.T;

    Trans_normed_1 = Trans_raw./fp_fit_result_1;
    [dip_y_est, dip_x_est] = min(Trans_normed_1);
    Base_est = max(Trans_normed_1);
    mid_y_est = (dip_y_est+Base_est)/2;
    half_cut_est = Trans_normed_1 < mid_y_est;
    mid_x_est = [find(half_cut_est(1:dip_x_est)==0, 1,'last' ), find(half_cut_est(dip_x_est:end)==1, 1)+dip_x_est-1];
    linewidth_est = abs(diff(mid_x_est));

    pos_fitrange = 7; % times of linewidth, Q to fit range
    pos_fitstart = round(max(0.03*length(Trans_raw) , dip_x_est - 0.6*pos_fitrange*linewidth_est)); % fitting range is peak position ± pos_fitrange/2 linewidth
    pos_fitend   = round(min(0.97*length(Trans_raw) , dip_x_est + 0.4*pos_fitrange*linewidth_est)); % fitting range is peak position ± pos_fitrange/2 linewidth
    fp_fit_weight = ones(size(Trans_raw));
    dip_fit_weight = fp_fit_weight*0;
    fp_fit_weight(pos_fitstart:pos_fitend) = 0;
    dip_fit_weight(pos_fitstart:pos_fitend) = 100;


    fp_fit = fit( x_freq.',Trans_raw,fit_fp,...
        'StartPoint',[fit_A0_estimate fit_B_estimate fit_x1_estimate fit_T_estimate],...
        'Weights',fp_fit_weight);
    fp_fit_result = fp_fit(x_freq.');%fp_fit.A0+fp_fit.B*cos(((1:length(Q_trace)).'-fp_fit.x1)/fp_fit.T*2*pi);

    Trans_normed = Trans_raw./fp_fit_result;

    [dip_y, dip_x] = min(Trans_normed);
    Base = max(Trans_normed);
%     Base = Trans(dip_x);
    mid_y = (dip_y+Base)/2;
    half_cut = Trans_normed < mid_y;
    mid_x = [find(half_cut(1:dip_x)==0, 1,'last' ), find(half_cut(dip_x:end)==1, 1)+dip_x-1];

            figure('Units', 'Normalized', 'OuterPosition', [0.1, 0.25, 0.6, 0.5])
            subplot(121)
%             figure
            plot(x_freq.',Trans_raw,'Linewidth',2.0)
            hold on
            scatter(x_freq.',fp_fit_result, 5);
            hold on
            plot(x_freq.',fp_fit_weight*max(Trans_raw)/max(fp_fit_weight))
            title(sprintf("FP 2nd fitting result, %g nm\n T=%g",lambda,fp_fit.T));
    %% 2. Fit mode parameters using Q measurement data
%         [mode_Q0,mode_Qe,mode_QT,~] = getQwithFP(Q_data_file);
        kappa0 = 299792.458/lambda/( mode_Q0 /MZI_fit_T * MZI_FSR );
        kappae = 299792.458/lambda/( mode_Qe /MZI_fit_T * MZI_FSR );
    % %     kappa0 = 299792458/(lambda*1e-9)/( mode_Q0 * 1e6 );
    % %     kappae = 299792458/(lambda*1e-9)/( mode_Qe * 1e6 );
    %% 3. Estimate alpha factor
    Qabs_est = 3 * 1e6;
    c = 299792458;
    % n0 = 2.0573;
    neff = 1.8373;
    n0 = neff;
    r = 109.5e-6;
    nT = 10.46e-6;
    % Aeff and dTdP from simulation
    Aeff = 1.0575e-12;
    dTdP = 613;%1685;%1570;
    alpha_est = nT * dTdP *(2*pi*c/lambda)^2/n0/Qabs_est;   % unit Hz^2/W
    alpha_est = 10*alpha_est;
    alpha_est = 2000;
    % alpha_est = alpha_est / ( sqrt(inputPower2 *outputPower2) * 1e-3 / sqrt(inputVoltage2 * outputVoltage2)); % in unit of power;
    % alpha_est = alpha_est *  (MZI_fit_T / (MZI_FSR*1e6)) ; % unit Num/W
    % 

	%     r1r2=fp_fit.B/2;
    r1r2 = ( 1-sqrt(1-fp_fit.B^2) )/fp_fit.B;

    %             figure
    %             plot((1:length(Trans_raw)).',Trans_raw,'Linewidth',2.0)
    %             hold on
    %             scatter((1:length(Trans_raw)).',fp_fit_result, 5);
    %             hold on
    %             plot((1:length(Trans_raw)).',fp_fit_weight*max(Trans_raw)/max(fp_fit_weight))
    %             hold on
    %             plot(transOutput((1:length(Trans_raw)).', dip_x, 5*alpha_est, kappa0+kappae, kappae, fp_fit) )
    %             hold on
    %             plot(modtrans(fp_fit.A0*(1+r1r2^2),r1r2,fp_fit.x1,fp_fit.T,kappa0,kappae , mid_x(1),5*alpha_est,(1:length(Trans_raw)).') )
    %             title(sprintf("FP 2nd fitting result, %g nm",lambda));


    %% 4. fit begins here
    tic
%     findmin_fun = @(paras)LCL(modtrans_residual(paras(1),paras(2),paras(3),paras(4),paras(5),paras(6),paras(7),paras(8),(1:length(Trans_raw)).',Trans_raw) ,dip_fit_weight);
%     findmin_start_point = [fp_fit.A0*(1+r1r2^2), r1r2, fp_fit.x1, fp_fit.T, kappa0, kappae, mid_x(1), 0.5*alpha_est];
%     %         options = optimset('MaxFunEvals',5000);
%     findmin_fit_result = fminsearch(findmin_fun,findmin_start_point);

    %--fix Q version----
%     findmin_fun = @(paras)LCL(modtrans_residual(paras(1),paras(2),paras(3),paras(4),kappa0,kappae,paras(5),paras(6),(1:length(Trans_raw)).',Trans_raw) ,dip_fit_weight);
%     findmin_start_point = [fp_fit.A0*(1+r1r2^2), r1r2, fp_fit.x1, fp_fit.T, mid_x(1), 2*alpha_est];
%     %         options = optimset('MaxFunEvals',5000);
%     findmin_fit_result = fminsearch(findmin_fun,findmin_start_point);
%     findmin_fit_result = [findmin_fit_result(1:4), kappa0, kappae, findmin_fit_result(5:6)]; 

    findmin_fun = @(paras)LCL(modtrans_residual(fp_fit.A0*(1+r1r2^2),r1r2,fp_fit.x1,fp_fit.T,kappa0,kappae,paras(1),paras(2),x_freq.',Trans_raw) ,dip_fit_weight);
    findmin_start_point = [mid_x(1)-0.5*linewidth_est, 0.5*alpha_est];
    findmin_start_point = [x_freq(mid_x(1)), alpha_est];

    %         options = optimset('MaxFunEvals',5000);
    findmin_fit_result = fminsearch(findmin_fun,findmin_start_point);
    triangle_fit_result = modtrans(fp_fit.A0*(1+r1r2^2),r1r2,fp_fit.x1,fp_fit.T,kappa0,kappae,...
                               findmin_fit_result(1),findmin_fit_result(2),x_freq.');
%     findmin_fun = @(paras)LCL(modtrans_residual(fp_fit.A0*(1+r1r2^2),r1r2,fp_fit.x1,fp_fit.T,kappa0,kappae,paras(1),paras(2),(1:length(Trans_raw)).',Trans_raw) ,dip_fit_weight);
%     findmin_start_point = [mid_x(1), 0.2*alpha_est];
%     %         options = optimset('MaxFunEvals',5000);
%     findmin_fit_result = fminsearch(findmin_fun,findmin_start_point);
     findmin_fit_result = [fp_fit.A0*(1+r1r2^2), r1r2, fp_fit.x1, fp_fit.T, kappa0, kappae, findmin_fit_result]; 
%     
% %     triangle_fit_result = modtrans(fp_fit.A0*(1+r1r2^2),r1r2,fp_fit.x1,fp_fit.T,kappa0,kappae,...
% %                                    findmin_fit_result(1),findmin_fit_result(2),(1:length(Trans_raw)).');
%     triangle_fit_result = modtrans(findmin_fit_result(1),findmin_fit_result(2),findmin_fit_result(3),...
%                                    findmin_fit_result(4),findmin_fit_result(5),findmin_fit_result(6),...
%                                    findmin_fit_result(7),findmin_fit_result(8),(1:length(Trans_raw)).');
    
%    triangle_fit_result = modtrans(fp_fit.A0*(1+r1r2^2),r1r2,fp_fit.x1,fp_fit.T,kappa0,kappae,...
%                                    mid_x(1), 0.5*alpha_est,(1:length(Trans_raw)).');


%             figure
            subplot(122)
            plot(x_freq.',Trans_raw,'Linewidth',2.0)
%             hold on
%             scatter((1:length(Trans_raw)).',fp_fit_result, 5);
            hold on
            scatter(x_freq.',triangle_fit_result, 5 );
            hold on
            plot(x_freq.',dip_fit_weight*max(Trans_raw)/max(dip_fit_weight))
%             title(sprintf("FP and Triangle fitting result, %g nm",lambda));         
                title(sprintf("FP and Tri fitting result, %g nm\n x0 = %g, alpha = %g, base = %g\n",...
                            lambda,findmin_fit_result(end-1),findmin_fit_result(end),findmin_fit_result(1) ));         

                if tosave
                    tt = strfind(data_filename,'\');
                    file_tosave_dir = data_filename(1:tt(end));
                    file_tosave_dir = strcat(file_tosave_dir,'Fitting_results');
                   if ~isfolder(file_tosave_dir)
                       mkdir(file_tosave_dir);
                   end
                    % --------save fig----------
                    filename_tosave = strcat(file_tosave_dir,'\',data_filename(tt(end)+1:end-4),'-FP-Tri-fitting.fig');
%                     if isfile(filename_tosave)
%                         backup_filename = strcat(filename_tosave(1:end-4),'_',char(datetime('now','Format','yyMMdd_HHmmss')),'_bak.fig');
%                         movefile(filename_tosave,backup_filename);
%                         warning('Old file was renamed!')
%                     end
                    saveas(gcf,filename_tosave);
                    filename_tosave = strcat(file_tosave_dir,'\',data_filename(tt(end)+1:end-4),'-FP-Tri-fitting.png');
                    saveas(gcf,filename_tosave);
                end
    toc
    
    %%
    omegaOverX = 2*pi*(MZI_FSR*1e6)/MZI_fit_T;
    
    findmin_fit_result(end+1) = omegaOverX^2 * findmin_fit_result(end);

end


%% optimization related codes

function dd = modtrans(A0,r,x1,T,k0,ke,x0,alpha,x)
    fit_fp   = fittype(' A0   /     ( 1-B*cos( (x-x1)/T*2*pi) )','coefficients',{'A0','B','x1','T'});
    fp_fit = cfit(fit_fp,0,0,0,0);
    fp_fit.A0 = A0/(1+r^2);
    fp_fit.B = 2*r/(1+r^2);
    fp_fit.x1 = x1;
    fp_fit.T = T;
    k = k0 + ke;
    dd = transOutput(x, x0, alpha, k, ke, fp_fit);
%     dd=( A0*abs((1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2)).^2 )./ (abs(1-r*( (1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2) ).^2 .* exp(-1i*2*pi*(x-x1)/T) ).^2);
end

function res = modtrans_residual(A0,r,x1,T,k0,ke,x0,alpha,  x,   trans)
    % trans is the real transmission. calculate residual
    res = (trans - modtrans(A0,r,x1,T,k0,ke,x0,alpha, x))./trans;
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

%% Interactivity power
function a2 = interCavityP(x, x0, alpha, k, ke, fp_fit)
    ss = size(x);
    if ss(1) < ss(2)
        x = x.';
    end % make sure column vector
    para1 = alpha^2 * ones(size(x));
    para2 = -2*(x-x0)*alpha;
    para3 = (x-x0).^2 + (k/2)^2;
    para4 = -ke * fp_fit(x);
    if alpha == 0
        a2 = -para4./para3;
        return 
    end
    solution_quartic = CardanRoots([para1 para2 para3 para4]);
    solution_quartic(imag(solution_quartic)~=0) = -Inf; % remove imaginary solutions
    a2 = max(solution_quartic,[],2);
end

%% Cavity Transmission function
function T = cavitytransT(x, x0, alpha, k, ke, fp_fit)
    k0 = k - ke;
    a2 = interCavityP(x, x0,alpha, k, ke, fp_fit);
    T = (1i*(x-x0-alpha*a2)+(k0-ke)/2)./(1i*(x-x0-alpha*a2)+(k0+ke)/2);
end

%% On waveguide output function
function output = transOutput(x, x0, alpha, k, ke, fp_fit)
    Tran = cavitytransT(x, x0, alpha, k, ke, fp_fit);
    r1r2 = ( 1-sqrt(1-fp_fit.B^2) )/fp_fit.B ;
    % r1r2=fp_fit.B/2; % B/2 is not correct. actually 2r/(1+r^2) is equal to B.
    % % ---The following two output expressions are actually equivalant. Checked by Maodong.---
    % output = fp_fit.A0 * (1+r1r2^2)* abs( Tran./(1 - r1r2*Tran.^2.*exp(-1i*2*pi*(x-fp_fit.x1)/fp_fit.T)) ).^2;
    output = fp_fit(x).* abs( (1 - r1r2.*exp(-1i*2*pi*(x-fp_fit.x1)/fp_fit.T)) ).^2 .* abs( Tran./(1 - r1r2*Tran.^2.*exp(-1i*2*pi*(x-fp_fit.x1)/fp_fit.T)) ).^2;
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
