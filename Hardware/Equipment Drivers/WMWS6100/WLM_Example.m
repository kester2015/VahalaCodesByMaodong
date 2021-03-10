%% Open
[WLM WLMInfo] = WLM_Open();

%% Get Wavelength
tic;
for ii=1:100
	Wavelength = WLM_GetWavelength(WLM);
end
toc

%% Close
WLM_Close(WLM);
clear WLM WLMInfo