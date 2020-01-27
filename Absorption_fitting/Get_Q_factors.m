clc
clear
omega0 = 3e14*2*pi;
for m = 1 : 10
    filename = strcat('Q_before_', num2str(m), '.bin');
    [~, data2] = importAgilentBin(filename, 4);
    [data1, data5] = importAgilentBin(filename, 3);
    data1 = data1(1:100:end);
    data2 = data2(1:100:end);
    data5 = data5(1:100:end);
    Q_obj = Q_trace_fit(data5, data2, 40.4499, 1000, 0.5);
    Q_obj.plot_Q_stat;
    Q_obj.plot_trace_stat;
    Q_obj.plot_Q_max;
    Q0(m) = Q_obj.modeQ0;
    Q1(m) = Q_obj.modeQ1;
    QL(m) = Q_obj.modeQL;
%     figure
%     hold on
%     plot(data1, data2);
%     plot(data1, data5);
end
for m = 11 : 20
    filename = strcat('Q_after_', num2str(m-10), '.bin');
    [~, data2] = importAgilentBin(filename, 4);
    [data1, data5] = importAgilentBin(filename, 3);
    data1 = data1(1:100:end);
    data2 = data2(1:100:end);
    data5 = data5(1:100:end);
    Q_obj = Q_trace_fit(data5, data2, 40.4499, 1000, 0.5);
    Q_obj.plot_Q_stat;
    Q_obj.plot_trace_stat;
    Q_obj.plot_Q_max;
    Q0(m) = Q_obj.modeQ0;
    Q1(m) = Q_obj.modeQ1;
    QL(m) = Q_obj.modeQL;
%     figure
%     hold on
%     plot(data1, data2);
%     plot(data1, data5);
end
%%
eta = QL./Q1;
eta_std = std(eta);
eta = mean(eta);
%%
kappa0 = omega0*ones(size(Q0))./Q0;
kappa0_std = std(kappa0);
kappa0 = mean(kappa0);
Q0 = omega0/kappa0;
Q0_std = Q0*kappa0_std/kappa0;
%%
kappa1 = omega0*ones(size(Q1))./Q1;
kappa1_std = std(kappa1);
kappa1 = mean(kappa1);
Q1 = omega0/kappa1;
Q1_std = Q1*kappa1_std/kappa1;
%%
kappaL = omega0*ones(size(QL))./QL;
kappaL_std = std(kappaL);
kappaL = mean(kappaL);
QL = omega0/kappaL;
QL_std = QL*kappaL_std/kappaL;
%%
disp(['Intrinsic Q factor:', num2str(Q0), '\pm', num2str(Q0_std), 'M']);
disp(['Coupling Q factor:', num2str(Q1), '\pm', num2str(Q1_std), 'M']);
disp(['Loaded Q factor:', num2str(QL), '\pm', num2str(QL_std), 'M']);
disp(['Coupling \eta:', num2str(eta), '\pm', num2str(eta_std)]);
%% Convert unit
Q0 = Q0*1e6;
Q0_std = Q0_std*1e6;
Q1 = Q1*1e6;
Q1_std = Q1_std*1e6;
QL = QL*1e6;
QL_std = QL_std*1e6;
save('Q_factors.mat', 'Q0', 'Q0_std', 'Q1', 'Q1_std', 'QL', 'QL_std', 'eta', 'eta_std');