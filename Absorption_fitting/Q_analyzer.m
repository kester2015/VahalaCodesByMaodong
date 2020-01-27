clearvars;
% load(['D:\QF\20181026\endfire\Dodos.Opt26.B4.3-1548.4nm.mat'],'data_matrix','-mat');
load(['D:\BShen\20171009\100517DODOSC7\C6T\Endfire1_Pcol_3_4mW-1550nm.mat'],'data_matrix','-mat');
if exist('data_matrix','var')
    trans = data_matrix(:,2);
    mzi = data_matrix(:,3);
end
Q_obj=Q_trace_fit(trans,mzi,5.9792,1550,0.9,'osc');
if (numel(Q_obj.modeQ0) > 0)
%     Qstat=Q_obj.plot_Q_stat;
%     saveas(gcf,[filename,'_Qstats.png']);
%     saveas(gcf,[filename,'_Qstats.fig']);
    tracestat=Q_obj.plot_trace_stat;
%     saveas(gcf,[filename,'_trace.png']);
%     saveas(gcf,[filename,'_trace.fig']);
%     Qmax=Q_obj.plot_Q_max;
%     saveas(gcf,[filename,'_Q_max=' num2str(Q_obj.modeQ0(1),'%.4g') 'M.png']);
%     saveas(gcf,[filename,'_Q_max=' num2str(Q_obj.modeQ0(1),'%.4g') 'M.fig']);
%     disp(['Maximum intrinsic Q = ' num2str(Q_obj.modeQ0(1),'%.4g') 'M']);
else
    disp('No mode detected');
end