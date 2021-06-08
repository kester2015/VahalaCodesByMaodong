####################################################################################
##																		##
##     Sample .ucf files distributed with the WaveShaper software installation	  ##
##																		##
##																		##
##    (c) 2010 Finisar Australia						  ##
##																		##
##    Please contact waveshaper@finisar.com for support or technical questions.	  ##
####################################################################################

This readme file describes the .ucf files in this directory, provided as examples of 
interesting profiles that can be loaded on a Finisar WaveShaper Programmable Optical
Processor (1000S) or Multiport Optical Processor (4000S).

-------------------------------------------------------------------------------------
1)		Bandpass_flattop_filter_BW50GHz.ucf

This is a simple bandpass filter, implemented by setting a 50 GHz region to 0 dB 
attenuation, and 60 dB attenuation outside of this region.

--------------------------------------------------------------------------------------
2)		Bandpass_flattop_filter_BW100GHz.ucf

Same as above, but using a 100 GHz region. Please note that the bandwidth setting on
the WaveShaper software must be large enough to accomodate this profile.

--------------------------------------------------------------------------------------
3)		Phase_notch_between_BW200GHz_channels.ucf

This profile illustrates the use of a phase change to create a very sharp notch filter.
Two adjacent bandpass filters, with bandwidth of 200 GHz, are set to have phase of 0 and pi,
respectively. This causes the formation of a very sharp notch between the different 
phase regions.

--------------------------------------------------------------------------------------
4)		Gaussian_profile_BW200GHz.ucf

A gaussian profile with a 3 dB bandwidth of 200 GHz. This profile extends from -2.75 to 2.75 THz,
requiring the entire spectrum of the WaveShaper, but the bandwidth setting can be set to any 
value, which will clip the profile.

---------------------------------------------------------------------------------------
5) 		Supergaussian_profile_n3_BW50GHz.ucf

A third-degree supergaussian profile with a 3 dB bandwidth of 50 GHz.

----------------------------------------------------------------------------------------
6)		Sinc_function_BW200GHz_Attn0dB.ucf

A sinc function with 3 dB bandwidth of 200 GHz, and the center of the main lobe set to 
0 dB attenuation.

----------------------------------------------------------------------------------------
7)		DPSK_40Gbps.ucf

This profile demonstrates the power spectrum of a 40 Gbps DPSK signal, as taken on 
an OSA.

----------------------------------------------------------------------------------------
8)		RZ-OOK_40Gbps.ucf

This profile demonstrates the power spectrum of a 40 Gbps RZ-OOK signal, as taken on 
an OSA.


