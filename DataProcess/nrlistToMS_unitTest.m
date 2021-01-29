

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