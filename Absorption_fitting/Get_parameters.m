clc
clear
%% Cavity parameters
n0 = 1.45;
omega0 = 3e14*2*pi;
d = 8e-6; % disk height
r = (7.308/2)*1e-3; % radius
uc = 150e-6; % undercut
D1 = 10e9*2*pi; %% 
load('Q_factors.mat');
kappa = omega0/QL; %% cavity linewidth
kappa_std = QL_std/QL*kappa;
%% Equipment parameters
Vpp = 200e-3;
FSR = 40.4499e6; %% MZI FSR in Hz
%% Thermal coefficients
beta = 1.2e-5;
C = 2*pi*r*uc*d*2.2e3*740; % thermal compacity, undercut
% C = pi*r^2*d*2.2e3*740; % thermal compacity, whole disk
C0 = 1/488; % Simulation, k/W
%% Experimental coefficients
P_in = sqrt(217*138.6)*1e-3; %% in the unit of mW
V2P = 1/mean([214.819 214.963 214.998 214.967 214.291 214.314]*1e-3)*sqrt(190.1*121.5)*1e-3;
V2P_std = (sqrt(190.1*121.5)/121.5-1)/sqrt(3); % Relative std
%% Scanning parameters
M = 11; % Number of measurements in power-changing measuremetnt
N = 26; % Number of measurements in scanning speed sweeping experiment
save('Parameters.mat');