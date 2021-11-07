clear all
clear
clc
%%
mask_name = 'LN_pole_test_curved';
gs = gds_structure(mask_name);

global resolution;
resolution = 1e-3; % global resolution 


chip_length = 10000; % 10mm length
chip_width = 5000; % 5mm width

background = drawRectangular(0,0,chip_length,chip_width);
gs(end+1) = gds_element('boundary', 'xy', background, 'layer', 1);
%% Define block size and block center
block_size = 5000; % block that contains multiple waveguides
block_distance_min = 500; % distance of blocks
nblock = floor( (chip_length-block_distance_min)/(block_size+block_distance_min) );





%% Draw pole
pad_length = 20;
finger2finger = 10;

pole = drawPolePad_smoothed(-(finger2finger+pad_length)/2,0,pad_length,chip_width,0.8,4.5, @(x)(sqrt(0.25-(x-0.5)^2)-0.5)*4);
pole_uncur = drawPolePad(-(finger2finger+pad_length)/2,0,pad_length,chip_width,0.8,4.5);

gs(end+1) = gds_element('boundary','xy',pole,'layer',2);
gs(end+1) = gds_element('boundary','xy',transAxisReflection(pole,'x',0),'layer',2);

gs(end+1) = gds_element('boundary','xy',pole_uncur,'layer',3);
gs(end+1) = gds_element('boundary','xy',transAxisReflection(pole_uncur,'x',0),'layer',3);

gs(end+1) = gds_element('text','text','testmytext','xy',[1000 0],'layer',4,'width',100)
% gs(end+1) = gds_element('boundary','xy',transAxisReflection(pole,'arbi',[0,0;1,2]),'layer',4);













%% GDS file output
delete([mask_name, '.gds']);
glib = gds_library(mask_name, 'uunit',1e-6, 'dbunit',1e-9, gs);
write_gds_library(glib, [mask_name, '.gds']);