function [delta_p, P_out, v] = Get_delta(filename)
%% Parameters definition
load('Parameters.mat');
load('alpha.mat');
alpha = coe(1)*(kappa/2/eta/D1); % rad/mW in cavity
%% Load traces
load(filename);
if length(data1) > 1e4
        data1 = data1(1:round(length(data1)/1e4):end);
        data2 = data2(1:round(length(data2)/1e4):end);
        data5 = data5(1:round(length(data5)/1e4):end);
end
data5 = sgolayfilt(data5, 2, round(length(data5)/1000)*2 + 1);
phase = MZI_to_phase(data2(1:end));
MZI = data2(1:end);
Trans =  data5(1:end);
%% Get dip
[~, dip_x] = min(Trans);
Base = max(Trans);
P_out = P_in/Base*Trans;
%% Get detuning
delta_p = FSR*phase/2/pi;
delta_p = delta_p - delta_p(dip_x) + alpha*D1*eta*kappa/((1/2-eta)^2*kappa^2)*min(P_out)/2/pi;
delta_p = delta_p*2*pi;
v = (max(phase) - min(phase)*FSR/2/pi/1e6)/(data1(end) - data1(1));
% disp(strcat(num2str((v)), 'MHz/s scanned in total'));
% figure
% hold on
% plot(delta_p/1e6/2/pi, P_out);
% xlabel('Detuning (MHz)');
% ylabel('Output power (mW)');
% delta_t = alpha*D1*eta*kappa/((1/2-eta)^2*kappa^2)*min(P_out)
% %% Intracavity power
% P_int = D1*eta*kappa*ones(size(delta_p))./((0.5-eta)^2*kappa^2+delta_p.^2).*P_out';
% figure
% plot(delta_p/2/pi/1e6, P_int);
% xlabel('Detuning (MHz)');
% ylabel('Intracavity power (mW)')
end 