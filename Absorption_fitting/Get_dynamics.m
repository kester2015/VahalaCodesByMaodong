function [delta_p, P_out, FWHM] = Get_dynamics(kappa_t, v)
%% Parameters of cavity
load('Parameters.mat');
load('alpha.mat');
alpha = coe(1)*(kappa/2/eta/D1); 
%% Parameters of scanning
v = v*2*pi*1e6;
dt = 1e-6;
delta_b = -30*kappa/2;
delta_e = 80*kappa/2;
t_final = (delta_e - delta_b)/v;
M = round(t_final/dt);
delta_p = linspace(delta_b, delta_e, M);
delta_t = 0;
%% run the simulation
for m = 1 : M
    delta_t = delta_t + kappa_t*(-delta_t + alpha*D1*eta*kappa/(kappa^2/4+(delta_p(m)-delta_t)^2)*P_in)*dt;
    delta(m) = -delta_t + delta_p(m);
    P_out(m) = ((0.5-eta)^2*kappa^2+delta(m)^2)/(kappa^2/4+delta(m)^2)*P_in;
    delta_tt(m) = delta_t;
end
% figure
% plot(delta_p/2/pi/1e6, P_out);
% xlabel('Pump detuning \delta_{p} (MHz)');
% ylabel('P_{out} (mW)');
% box on
% grid on
% figure
% plot(delta_p/2/pi, delta/2/pi/kappa*2);
% xlabel('Pump detuning \delta_{p} (MHz)');
% ylabel('\delta (\kappa/2)');
% figure
% plot(delta_p/2/pi, delta_tt/2/pi/kappa*2);
%% Get FWHM
[dip_y, dip_x] = min(P_out);
Base = max(P_out);
mid_y = (dip_y + Base)/2;
mid_x = [min(find(P_out < mid_y)), max(find(P_out < mid_y))];
FWHM = (delta_p(mid_x(2)) - delta_p(mid_x(1)))/2/pi;
end