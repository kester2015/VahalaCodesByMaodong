mask_name='Positive_ridge';

mag = 10; % photomask mag; fixed at 10
board_length = 5*1000*mag; % half board size
global resolution;
resolution = 1*mag; % global resolution 

D_wedge = 3.2*1000*mag; % D of resonator
w_ridge = 22*mag; % ridge width, symmetrically distributed around D

w_base = 90*mag; % 2nd layer ring width outside ridge; not used for disks
w_ridge_spacing = 5*mag; % spacing for ridge; not used for disks

%% Geometric Calculations
R1_inner = D_wedge/2 + w_ridge/2;
R2_2 = D_wedge/2 - w_ridge/2;
R2_1 = R2_2 - w_ridge_spacing;
R2_3 = R2_2 + w_base;

%% Initialization
tp = cd; cd ../; addpath(genpath(cd)); cd(tp); % add all folders to path
gs = gds_structure(mask_name);

%% Ring
ring = DrawDisk(0,0,R1_inner,0,0,360);
gs(end+1) = gds_element('boundary', 'xy', ring, 'layer', 1);
ring = DrawDisk(0,0,R2_1,0,0,360);
gs(end+1) = gds_element('boundary', 'xy', ring, 'layer', 2);
ring = DrawDisk(0,0,R2_3,R2_2,0,360);
gs(end+1) = gds_element('boundary', 'xy', ring, 'layer', 2);

%% Align marks
stepper_mark={[-52000.0 -12.5; -52000.0 +12.5; -51000.0 +12.5; -51000.0 -12.5] ...
              [+52000.0 -12.5; +52000.0 +12.5; +51000.0 +12.5; +51000.0 -12.5] ...
              [-51512.5 -500.; -51512.5 +500.; -51487.5 +500.; -51487.5 -500.] ...
              [+51512.5 -500.; +51512.5 +500.; +51487.5 +500.; +51487.5 -500.]};
ridge_pos_mark={[-47500 -45090; -47500 -44910; -42500 -44910; -42500 -45090] ...
                [+47500 +45090; +47500 +44910; +42500 +44910; +42500 +45090] ...
                [-45090 -47500; -44910 -47500; -44910 -42500; -45090 -42500] ...
                [+45090 +47500; +44910 +47500; +44910 +42500; +45090 +42500]};
gs(end+1) = gds_element('boundary', 'xy', stepper_mark, 'layer', 1);
gs(end+1) = gds_element('boundary', 'xy', ridge_pos_mark, 'layer', 1);

%% Output gds
delete([mask_name, '.gds']);
glib = gds_library(mask_name, 'uunit',1e-6, 'dbunit',1e-9, gs);
write_gds_library(glib, [mask_name, '.gds']);