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
    fit_sine = fittype(' A0+B*cos((x-x1)/T*2*pi)','coefficients',{'A0','B','x1','T'});
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

    fp_fit = fit( (1:length(Trans_raw)).',Trans_raw,fit_sine,...
        'StartPoint',[fit_A0_estimate fit_B_estimate length(Q_trace_freq)/2 fit_T_estimate],...
        'Weights',Trans_raw);
    fp_fit_result = fp_fit((1:length(Trans_raw)).');%fp_fit.A0+fp_fit.B*cos(((1:length(Q_trace)).'-fp_fit.x1)/fp_fit.T*2*pi);

    Trans = Trans_raw./fp_fit_result;

    fp_fit = fit( (1:length(Trans_raw)).',Trans_raw,fit_sine,...
        'StartPoint',[fit_A0_estimate fit_B_estimate length(Q_trace_freq)/2 fit_T_estimate],...
        'Weights',Trans.^6);
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
    mid_x = [find(Trans < mid_y, 1 ), find(Trans < mid_y, 1, 'last' )];
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
                figure('Units', 'Normalized', 'OuterPosition', [0.4, 0.45, 0.65, 0.5])
                subplot(121)
                plot((1:length(Trans_raw)).',Trans_raw)
                hold on
                scatter((1:length(Trans_raw)).',fp_fit_result);
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