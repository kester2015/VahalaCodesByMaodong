function xy = drawRecRing(x,y,length,height,width,varargin)
%
% Function CrossMarker outputs a cross shaped marker
%
% x,y -- rectangular center position;
% length -- outer rectangular length along x axis
% height -- outer rectangular height along y axis
% width -- rectangular ring width

    ip = inputParser;
    ip.addParameter('angle', 0, @isnumeric); % rotate angle
    ip.parse(varargin{:});
    theta = ip.Results.angle * pi / 180 ;
    
    xyArray = zeros(10,2);
    xyArray(1,:) = [-length/2, height/2];
    xyArray(2,:) = [ length/2, height/2];
    xyArray(3,:) = [ length/2,-height/2];
    xyArray(4,:) = [-length/2,-height/2];
    xyArray(5,:) = [-length/2        , height/2 - width];
    xyArray(6,:) = [-length/2 + width, height/2 - width];
    xyArray(7,:) = [-length/2 + width,-height/2 + width];
    xyArray(8,:) = [ length/2 - width,-height/2 + width];
    xyArray(9,:) = [ length/2 - width, height/2 - width];
    xyArray(10,:) = [-length/2        , height/2 - width];
    
    xyArray = xyArray * [cos(theta), sin(theta); -sin(theta), cos(theta)];
    xyArray = xyArray + [x y];
    xy = {xyArray};
end