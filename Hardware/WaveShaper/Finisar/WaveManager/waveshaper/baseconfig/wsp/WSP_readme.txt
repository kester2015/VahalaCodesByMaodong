####################################################################################
##																				  ##
##     Sample .wsp files distributed with the WaveManager software installation	  ##
##																				  ##
##																				  ##
##    (c) 2010 Finisar Australia						  						  ##
##																				  ##
##    Please contact waveshaper@finisar.com for support or technical questions.	  ##
####################################################################################

This readme file describes the .wsp files in this directory, provided as examples of 
interesting profiles that can be loaded on a Finisar WaveShaper Programmable Optical
Processor (1000S) or Multiport Optical Processor (4000S).

-------------------------------------------------------------------------------------
1)		Bandpass_filter_fc194THx_BW50GHz_attn0dB_pt1.wsp

This is a simple bandpass filter, implemented by setting a 50 GHz region to 0 dB 
attenuation, and a block state outside of this region.

--------------------------------------------------------------------------------------
2)		Bandpass_filter_fc194THz_BW100GHz_attn0dB_pt1.wsp

Same as above, but using a 100 GHz region.

--------------------------------------------------------------------------------------
3)		Phase_notch_between_BW200GHz_channels_at_194THz_pt1.wsp

This profile illustrates the use of a phase change to create a very sharp notch filter.
Two adjacent bandpass filters, with bandwidth of 200 GHz, are set to have phase of 0 and pi,
respectively. This causes the formation of a very sharp notch between the different 
phase regions.

--------------------------------------------------------------------------------------
4)		Gaussian_profile_fc194THz_BW200GHz_attn0dB_pt1.wsp

A gaussian profile with a 3 dB bandwidth of 200 GHz, clipped to a 1 THz window.

---------------------------------------------------------------------------------------
5) 		Supergaussian_profile_n3_fc194THz_BW50GHz_attn0_pt1.wsp

A third-degree supergaussian profile with a 3 dB bandwidth of 50 GHz.

----------------------------------------------------------------------------------------
6)		Interleaver_BW100GHz_fstart191p7THz_44channels_pt1.wsp

This profile creates an interleaver pattern across the spectrum of the WaveShaper, using 
alternating 100 GHz regions, set to port 1 and block, respectively.

----------------------------------------------------------------------------------------
7)		Sinc_function_fc194THz_BW200GHz_Attn0dB_pt1.wsp

A sinc function with 3 dB bandwidth of 200 GHz, and the center of the main lobe set to 
0 dB attenuation.

----------------------------------------------------------------------------------------
8)		120S_GainEqualisation_20Channels.wsp

Designed for use with the WaveShaper 120 Gain Equaliser, this filter demonstrates gain 
equalisation for 20 channels equally spaced between 192 and 196 Thz.

----------------------------------------------------------------------------------------
9)		120S_GainEqualisation_40Channels.wsp

Same as above, but with 40 Channels.

----------------------------------------------------------------------------------------
10)		120S_GainEqualisation_80Channels.wsp

Same as above, but with 80 Channels.

----------------------------------------------------------------------------------------
11)		120S_GainEqualisation_ASEProfile.wsp

Designed for use with the WaveShaper 120S, this example profile performs gain equalisation
for an ASE optical source by introducing wavelength dependent attenuation of up to 10 dB.

----------------------------------------------------------------------------------------
12)		120S_GainEqualisation_ContinuousSpectrum.wsp

An arbitrary gain equalisation filter featuring wavelength dependent attenuation from 
0 to 10 dB.




