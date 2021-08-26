clear all

mask_name = 'oxidize_silicon';
gs = gds_structure(mask_name);


background = drawRectangular(0,0,35000,35000);
gs(end+1) = gds_element('boundary', 'xy', background, 'layer', 1);

%% Draw global marker
for x = [-15500,0,15500]
    for y = [-15500,0,15500]
        if x==0 && y ==0
            continue
        end
        marker = crossMarker(x,y,50,10);
        gs(end+1) = gds_element('boundary', 'xy', marker, 'layer', 2);
        marker = crossMarker(x,y,60,20);
        gs(end+1) = gds_element('boundary', 'xy', marker, 'layer', 3);
        
        for guiderSize = 120:80:700
            markerGuider = drawRecRing(x,y,guiderSize,guiderSize,5,'angle',45);
            gs(end+1) = gds_element('boundary', 'xy', markerGuider, 'layer', 4);
        end
    end
end


%% Draw waveguide

offsetList = 6000*[-2:2];
WGwidthList = 0.5:0.5:5;
windowWGdistance = 10;
windowWidth = 3;
WGlength = 30000;
WGdistance = 400;

smallMKDistance = 40;

for offset = offsetList
    ii = 0;
    for center = WGdistance*([1:length(WGwidthList)]-6) + offset
        ii = ii + 1;
        WGwindow = drawRectangular(center + windowWGdistance + windowWidth ,0,windowWidth,WGlength);
        gs(end+1) = gds_element('boundary', 'xy', WGwindow, 'layer', 5);
        
        WG = drawRectangular(center + windowWidth/2 - WGwidthList(ii)/2 ,0,WGwidthList(ii),WGlength);
        gs(end+1) = gds_element('boundary', 'xy', WG, 'layer', 6);
        
        for mkx = [-smallMKDistance/2,smallMKDistance/2]
            for mky = [-smallMKDistance/2,smallMKDistance/2]
                marker = crossMarker(center + mkx, WGlength/2 - smallMKDistance/2 + mky,5,1);
                gs(end+1) = gds_element('boundary', 'xy', marker, 'layer', 7);
                marker = crossMarker(center + mkx, -WGlength/2 + smallMKDistance/2 + mky,5,1);
                gs(end+1) = gds_element('boundary', 'xy', marker, 'layer', 7);
                marker = crossMarker(center + mkx, WGlength/2 - smallMKDistance/2 + mky,6,1.4);
                gs(end+1) = gds_element('boundary', 'xy', marker, 'layer', 8);
                marker = crossMarker(center + mkx, -WGlength/2 + smallMKDistance/2 + mky,6,1.4);
                gs(end+1) = gds_element('boundary', 'xy', marker, 'layer', 8);
            end
        end
    end
end
%% GDS file output
delete([mask_name, '.gds']);
glib = gds_library(mask_name, 'uunit',1e-6, 'dbunit',1e-9, gs);
write_gds_library(glib, [mask_name, '.gds']);