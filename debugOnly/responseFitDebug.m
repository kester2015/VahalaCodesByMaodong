% Maodong, 20200817, data processing of response function

%% Read table
pin_phase_table = readtable('Z:\Qifan\Tantala\VNA experiment\20200817\2.00 UW_0DBM_PIN_SAVEALL.CSV');
pin_abs_table = readtable('Z:\Qifan\Tantala\VNA experiment\20200817\2.00 UW_0DBM_PIN_SAVEALL2.CSV');
res_phase_table = readtable('Z:\Qifan\Tantala\VNA experiment\20200817\2.00 UW_0DBM_RES_SAVEALL.CSV');
res_abs_table = readtable('Z:\Qifan\Tantala\VNA experiment\20200817\2.00 UW_0DBM_RES_SAVEALL2.CSV');

%% brief plot to check correctness
    % close all
    % figure;
    % semilogx(pin_abs_table{:,1},pin_abs_table{:,2})
    % title("pin-abs")
    % figure;
    % semilogx(pin_phase_table{:,1},pin_phase_table{:,2})
    % title("pin-phase")

%%
pin_phase = pin_phase_table{:,1:2};
for ii = 1:length(pin_phase(:,2))-1
    if abs( pin_phase(ii+1,2)-pin_phase(ii,2) ) > 200
        pin_phase(ii+1:end,2) = pin_phase(ii+1:end,2) - 360;
    end
end

res_phase = res_phase_table{:,1:2};
for ii = 1:length(res_phase(:,2))-1
    if abs( res_phase(ii+1,2)-res_phase(ii,2) ) > 200
        res_phase(ii+1:end,2) = res_phase(ii+1:end,2) - 360;
    end
end

    close all
    figure;
    plot(pin_phase(:,1),pin_phase(:,2))
    title("smoothed pin-phase")
    figure;
    plot(res_phase(:,1),res_phase(:,2))
    title("smoothed res-phase")


diff_phase = res_phase;
diff_phase(:,2) = res_phase(:,2) - pin_phase(:,2);
    figure;
    plot(diff_phase(:,1),diff_phase(:,2))
    title("smoothed diff-phase")


phase_tofit = diff_phase(diff_phase(:,1)<1.5e8,:);
phase_tofit = phase_tofit(phase_tofit(:,1)>0.1e8,:);



coeff = polyfit(phase_tofit(:,1),phase_tofit(:,2),1);

phase_tofit_result = coeff(1)*phase_tofit(:,1) + coeff(2);

    figure;
    plot(phase_tofit(:,1),phase_tofit(:,2),'LineWidth',2.0)
    title("diff-phase to fit")
    hold on
    plot(phase_tofit(:,1),phase_tofit_result,'--','LineWidth',2.0);

coeff(1)



