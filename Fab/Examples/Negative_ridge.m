mask_name='Negative_ridge';

mag = 10; % photomask mag; fixed at 10
board_length = 5*1000*mag; % half board size
global resolution;
resolution = 1*mag; % global resolution 

D_wedge = 4.234*1000*mag; % D of resonator
w_ridge = 90*mag; % ridge width, symmetrically distributed around D
w_spacing = 15*mag; % 1st layer spacing

taper_pass_u = 15*mag; % width for taper pass, upper section
taper_pass_d = 50*mag; % width for taper pass, upper section
taper_pass_slope = 0.05;
w_rounding = 200*mag; % corner rounding

w_ridge_spacing = 5*mag; % spacing for ridge; not used for disks

%% Geometric Calculations
% assuming taper goes horizontally
R1_inner = D_wedge/2 + w_ridge/2;
R1_outer = R1_inner + w_spacing;
taper_pass_center = R1_inner + (taper_pass_u - taper_pass_d)/2;
taper_pass_width = taper_pass_u + taper_pass_d;
taper_pass_rcy = R1_inner - taper_pass_d - w_rounding;
taper_pass_rcx = sqrt((R1_outer + w_rounding)^2 - taper_pass_rcy^2);
taper_pass_ang = 180 - atand(taper_pass_rcx / taper_pass_rcy);

R2_2 = D_wedge/2 - w_ridge/2;
R2_1 = R2_2 - w_ridge_spacing;

%% Initialization
tp = cd; cd ../; addpath(genpath(cd)); cd(tp); % add all folders to path
gs = gds_structure(mask_name);

%% Ring
ring = DrawDisk(0,0,R1_outer,0,0,360);
gs(end+1) = gds_element('boundary', 'xy', ring, 'layer', 2);
ring = DrawDisk(0,0,R1_inner,0,0,360);
gs(end+1) = gds_element('boundary', 'xy', ring, 'layer', 3);

%% Taper & Background
rect = DrawRect(-board_length,-board_length,2*board_length,board_length+R1_inner-taper_pass_d,'corner');
gs(end+1) = gds_element('boundary', 'xy', rect, 'layer', 1);
rect = DrawRect(-board_length,+board_length,2*board_length,-(board_length-R1_inner-taper_pass_u),'corner');
gs(end+1) = gds_element('boundary', 'xy', rect, 'layer', 3);

taper_pass = DrawTaper(board_length,taper_pass_center,-board_length*0.9,board_length*taper_pass_slope,board_length*taper_pass_slope/10,'l');
gs(end+1) = gds_element('boundary', 'xy', taper_pass, 'layer', 4);
taper_pass = ShapeFlip(taper_pass,'x',0);
gs(end+1) = gds_element('boundary', 'xy', taper_pass, 'layer', 4);

%% Rounding
rounding = DrawDisk(taper_pass_rcx,taper_pass_rcy,taper_pass_rcx,1.01*w_rounding,90,90+taper_pass_ang);
gs(end+1) = gds_element('boundary', 'xy', rounding, 'layer', 2);
rounding = ShapeFlip(rounding,'x',0);
gs(end+1) = gds_element('boundary', 'xy', rounding, 'layer', 2);

%% 2nd layer
ring = DrawDisk(0,0,R2_2,R2_1,0,360);
gs(end+1) = gds_element('boundary', 'xy', ring, 'layer', 6);
bkg = DrawRect(0,0,2*board_length,2*board_length,'center');
gs(end+1) = gds_element('boundary', 'xy', bkg, 'layer', 5);

%% Align marks
stepper_mark={[-52000.0 -12.5; -52000.0 +12.5; -51000.0 +12.5; -51000.0 -12.5] ...
              [+52000.0 -12.5; +52000.0 +12.5; +51000.0 +12.5; +51000.0 -12.5] ...
              [-51512.5 -500.; -51512.5 +500.; -51487.5 +500.; -51487.5 -500.] ...
              [+51512.5 -500.; +51512.5 +500.; +51487.5 +500.; +51487.5 -500.]};
ridge_neg_mark={[-45750 -45010; -45750 -44990; -44250 -44990; -44250 -45010] ...
                [+45750 +45010; +45750 +44990; +44250 +44990; +44250 +45010] ...
                [-45010 -45750; -44990 -45750; -44990 -44250; -45010 -44250] ...
                [+45010 +45750; +44990 +45750; +44990 +44250; +45010 +44250]};
gs(end+1) = gds_element('boundary', 'xy', stepper_mark, 'layer', 1);
gs(end+1) = gds_element('boundary', 'xy', ridge_neg_mark, 'layer', 4);

%% Output gds
delete([mask_name, '.gds']);
glib = gds_library(mask_name, 'uunit',1e-6, 'dbunit',1e-9, gs);
write_gds_library(glib, [mask_name, '.gds']);


%% Output boolean.rb
layer_a={'1' '1' '1' '5'};
boolean={'-' '+' '-' '-'};
layer_b={'2' '3' '4' '6'};
layer_c={'1' '1' '1' '2'};
layer_delete='(3..6)';

fid=fopen('boolean.rb','w');
fprintf(fid,'cl = RBA::CellView::active.layout\n');
fprintf(fid,'cc = RBA::CellView::active.cell\n');
fprintf(fid,'sp = RBA::ShapeProcessor.new\n\n');

for op_index=1:length(layer_a)
    fprintf(fid,['la = cl.layer(' layer_a{op_index} ',0)\n']);
    fprintf(fid,['lb = cl.layer(' layer_b{op_index} ',0)\n']);
    fprintf(fid,['lc = cl.layer(' layer_c{op_index} ',0)\n']);
    switch boolean{op_index}
        case '+'
            fprintf(fid,'sp.boolean(cl,cc,la,cl,cc,lb,cc.shapes(lc),RBA::EdgeProcessor::mode_or,true,true,true)\n\n');
        case '-'
            fprintf(fid,'sp.boolean(cl,cc,la,cl,cc,lb,cc.shapes(lc),RBA::EdgeProcessor::mode_anotb,true,true,true)\n\n');
        case '*'
            fprintf(fid,'sp.boolean(cl,cc,la,cl,cc,lb,cc.shapes(lc),RBA::EdgeProcessor::mode_and,true,true,true)\n\n');
        case '^'
            fprintf(fid,'sp.boolean(cl,cc,la,cl,cc,lb,cc.shapes(lc),RBA::EdgeProcessor::mode_xor,true,true,true)\n\n');
    end
end

fprintf(fid,[layer_delete '.each do |i|\n']);
fprintf(fid,'  ln=cl.layer(i,0)\n');
fprintf(fid,'  cl.delete_layer(ln)\n');
fprintf(fid,'end');

fclose(fid);
