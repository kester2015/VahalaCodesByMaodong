####################################################################################
##																		 		##
##    Sample .wsgrid files distributed with the WaveManager software installation ##
##																				##
##																				##
##    (c) 2010 Finisar Australia						  ##
##																				##
##    Please contact waveshaper@finisar.com for support or technical questions.	  ##
####################################################################################

This readme file describes the sample .wsgrid files in this directory, provided as
examples of profiles that can be used in FlexGrid mode for the WaveShaper Multiport
Optical Processor (4000S).

-------------------------------------------------------------------------------------
1)	FlexGrid_40_x_50GHz_channels.wsgrid

This profile demonstrates how to create 40 50 GHz channels, set to alternating output
ports. Each channel has a 50 GHz block region adjacent to it.

-------------------------------------------------------------------------------------
2)	FlexGrid_mixed_BW_and_port_20_channels.wsgrid

For mixed channel plans, this profile demonstrates the ability of the WaveShaper to
create user-defined channel plans. This sample profile will generate 20 channels,
varying bandwidth from the minimum channel width of 25 GHz, to the maximum of 200 GHz.
Each channel is separated from its neighbor with a 50 GHz block region.

-------------------------------------------------------------------------------------
3)	FlexGrid_20_contiguous_interleaved_channels_w_drop_port.wsgrid

For high spectral efficiency applications, we demonstrate that FlexGrid can enable the
user to create an interleaved pattern: odd channels with width of 87.5 GHz directed to 
port 1, even channels with width of 162.5 GHz directed to port 2. One of the central
channels is 'dropped' to port 3.

-------------------------------------------------------------------------------------


