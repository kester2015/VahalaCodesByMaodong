

c_const = 299792458;
NUM = 1000;
freqlist = c_const./( linspace(1520,1580,NUM)*1e-9);
n0 = 1.44;
nlist          = n0 + 0.02*(linspace(-NUM/2,NUM/2,NUM).^2/(NUM/2)^2);
nlist(end+1,:) = n0 + 0.01*(linspace(-NUM/2,NUM/2,NUM).^2/(NUM/2)^2);
FSR = 10e9; % 10GHz
radius = c_const/(2*pi*n0*FSR);
t1 = nrlistToModeSpec('frequencylist',freqlist','nrlist',nlist'*radius,'FSR',FSR);
t1.processModeSpectrum;
t1.plot_MS;
%%
close all
load('DataProcess\AlGaAs_No15_nr_disp.mat')
n_eff_r = real(n_eff_r(3:4,:))
nr_est = 0.0020;
FSR = 17.1e9;%299792458/2/pi/nr_est
FSR = 15.9e9;
% FSR = 15.7e9;
% FSR = 15.5e9;
t2 = nrlistToModeSpec('frequencylist',freq_list,'nrlist',n_eff_r','FSR',FSR,'modeNum',200);
t2.processModeSpectrum;
t2.plot_MS;

%%
close all
clear
load('DataProcess\Warren_workspace_388.mat')
c_const = 299792458;
FSR = 9e9;
t3 = nrlistToModeSpec('frequencylist',c_const./(wavel'*1e-9),'nrlist',n_eff_r(3:4,:)','FSR',FSR,'modeNum',200);
t3.processModeSpectrum;
t3.plot_MS;

