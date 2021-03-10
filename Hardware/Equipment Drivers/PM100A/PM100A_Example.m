
%% Open
[PM PMInfo] = PM100A_Open('P1001138');

%% Set Autoscale
AS = 1;
ASAns = PM100A_SetAutoScale(PM, AS)

%% Get Power
Power = PM100A_GetPower(PM)

%% Get Power Statistics
N = 10000; % free running about 36.75 ms per sample
t = zeros(N,1);
Power = zeros(N,1);
t0 = tic;
for ii=1:N
   Power(ii) = PM100A_GetPower(PM);
   t(ii) = toc(t0);
end
dt = t(2:N)-t(1:N-1);
MeanPower = mean(Power);
StDevPower = std(Power);
SNR = 10*log10(StDevPower/MeanPower)
plot(t,Power)

%% Close
PM100A_Close(PM);
clear PM PMInfo


