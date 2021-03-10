function [Wavelength] = WLM_GetWavelength(TLB)

Wavelength = calllib('wlmData','GetWavelength',0);

end