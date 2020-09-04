function [Base_voltage, FWHM] = getFWHM(filename,plotfig)
    if nargin == 1
        plotfig = 0;
    end
    
    load(filename,'timeAxis','Ch2','Ch3');

    % timeAxis = timeAxis(end/2:end);
    % Ch2 = Ch2(end/2:end);
    % Ch3 = Ch3(end/2:end);

    if length(timeAxis) > 1e4
            timeAxis = timeAxis(1:round(length(timeAxis)/1e4):end);
            Ch3= Ch3(1:round(length(Ch3)/1e4):end);
            Ch2 = Ch2(1:round(length(Ch2)/1e4):end);
    end
%     Ch2 = sgolayfilt(Ch2, 2, round(length(Ch2)/1000)*2 + 1);
    phase = MZI_to_phase(Ch3(1:end));
    MZI = Ch3(1:end);
    Trans =  Ch2(1:end);
    if min(Trans)<0
            PD_background = min(Trans);
            Trans = Trans - PD_background;
    %         warning("transmission < 0 in rawdata, PD background %d mV are added. critical coupling assumed.", PD_background/0.001);
    end
    Trans_raw = Trans;
    %% FP background filter
    fit_sine = fittype(' A0 +  B*cos((x-x1)/T*2*pi) ','coefficients',{'A0','B','x1','T'});
    fit_fp   = fittype(' A0/(1-B*cos((x-x1)/T*2*pi))','coefficients',{'A0','B','x1','T'});
    Q_trace_freq = abs(fft(Trans_raw));

    Q_trace_freq_temp = Q_trace_freq;
    Q_trace_freq_temp(1) = 0;
    [amp_fp,pos_fp] = max(Q_trace_freq_temp(1:round(end/2)));
    fit_T_estimate = length(Q_trace_freq)/(pos_fp-1);
    if pos_fp < 3
        fit_T_estimate = 2*length(Q_trace_freq);
    end
    fit_B_estimate = amp_fp/length(Q_trace_freq);
    fit_A0_estimate = mean(Trans_raw);

    % --First do a rough fitting to find dip position
    fp_fit_1 = fit( (1:length(Trans_raw)).',Trans_raw,fit_fp,...
        'StartPoint',[fit_A0_estimate fit_B_estimate length(Q_trace_freq)/2 fit_T_estimate],...
        'Weights',Trans_raw);
    fp_fit_result_1 = fp_fit_1((1:length(Trans_raw)).');%fp_fit.A0+fp_fit.B*cos(((1:length(Q_trace)).'-fp_fit.x1)/fp_fit.T*2*pi);
    fit_A0_estimate = fp_fit_1.A0;
    fit_B_estimate  = fp_fit_1.B;
    fit_x1_estimate = fp_fit_1.x1;
    fit_T_estimate  = fp_fit_1.T;
    
    Trans_1 = Trans_raw./fp_fit_result_1;
    [dip_y_est, dip_x_est] = min(Trans_1);
    Base_est = max(Trans_1);
    mid_y_est = (dip_y_est+Base_est)/2;
    half_cut_est = Trans_1 < mid_y_est;
    mid_x_est = [find(half_cut_est(1:dip_x_est)==0, 1,'last' ), find(half_cut_est(dip_x_est:end)==1, 1)+dip_x_est-1];
    linewidth_est = abs(diff(mid_x_est));
    
    pos_fitrange = 5; % times of linewidth, Q to fit range
    pos_fitstart = round(max(0.03*length(Trans_raw) , dip_x_est - 0.8*pos_fitrange*linewidth_est)); % fitting range is peak position ± pos_fitrange/2 linewidth
    pos_fitend   = round(min(0.97*length(Trans_raw) , dip_x_est + 0.2*pos_fitrange*linewidth_est)); % fitting range is peak position ± pos_fitrange/2 linewidth

    fp_fit_weight = ones(size(Trans_raw));
    fp_fit_weight(pos_fitstart:pos_fitend) = 0;
    
    
    fp_fit = fit( (1:length(Trans_raw)).',Trans_raw,fit_fp,...
        'StartPoint',[fit_A0_estimate fit_B_estimate fit_x1_estimate fit_T_estimate],...
        'Weights',fp_fit_weight);
    fp_fit_result = fp_fit((1:length(Trans_raw)).');%fp_fit.A0+fp_fit.B*cos(((1:length(Q_trace)).'-fp_fit.x1)/fp_fit.T*2*pi);

    Trans = Trans_raw./fp_fit_result;

%     fp_fit = fit( (1:length(Trans_raw)).',Trans_raw,fit_sine,...
%         'StartPoint',[fit_A0_estimate fit_B_estimate length(Q_trace_freq)/2 fit_T_estimate],...
%         'Weights',Trans.^6);
%     fp_fit_result = fp_fit((1:length(Trans_raw)).');%fp_fit.A0+fp_fit.B*cos(((1:length(Q_trace)).'-fp_fit.x1)/fp_fit.T*2*pi);
% 
%     Trans = Trans_raw./fp_fit_result;

    %%
    
%     Trans_phasor = hilbert(Trans_raw); % use phasor for non-parametric fit
% 
%     Trans_fp_phase = [0; cumsum(mod(diff(angle(Trans_phasor))+pi, 2*pi) - pi)] + angle(Trans_phasor(1));

    %% Get dip
    [dip_y, dip_x] = min(Trans);
    Base = max(Trans);
%     Base = Trans(dip_x);
    mid_y = (dip_y+Base)/2;
    half_cut = Trans < mid_y;
    mid_x = [find(half_cut(1:dip_x)==0, 1,'last' ), find(half_cut(dip_x:end)==1, 1)+dip_x-1];
    % figure
    % hold on
    % plot(phase, MZI);
    % plot(phase, Trans);
    % scatter(phase(dip_x), dip_y);
    % plot(phase, Base*ones(size(Trans)));
    % scatter(phase(mid_x), [mid_y mid_y]);
    count = (phase(mid_x(2)) - phase(mid_x(1)))/2/pi;
    FWHM = count;
    Base_voltage = fp_fit_result(dip_x);
    %% Plot
    if plotfig
                figure('Units', 'Normalized', 'OuterPosition', [0.2, 0.45, 0.65, 0.5])
                subplot(121)
                plot((1:length(Trans_raw)).',Trans_raw,'Linewidth',2.0)
                hold on
                scatter((1:length(Trans_raw)).',fp_fit_result,5);
                hold on
                plot((1:length(Trans_raw)).',fp_fit_weight * max(Trans_raw)/max(fp_fit_weight));
                title("FP fitting")
                subplot(122)
                plot((1:length(Trans)).',Trans)
                hold on
                yline(mid_y,'--','FWHM position','LineWidth',2);
                title("normalized lineshape and FWHM fitting")
    end
    % box on
    % grid on
    % title(strcat(num2str(count), ' periods in FWHM of transmission'));
end