function xy = drawRectangular(x,y,length,height,varargin)
%
% Function CrossMarker outputs a cross shaped marker
%
% x,y -- rectangular center position;
% length -- rectangular length along x axis
% height -- rectangular height along y axis

    ip = inputParser;
    ip.addParameter('angle', 0, @isnumeric); % rotate angle
    ip.parse(varargin{:});
    theta = ip.Results.angle * pi / 180 ;
    
    xyArray = zeros(4,2);
    xyArray(1,:) = [-length/2, height/2];
    xyArray(2,:) = [ length/2, height/2];
    xyArray(3,:) = [ length/2,-height/2];
    xyArray(4,:) = [-length/2,-height/2];
    
    xyArray = xyArray * [cos(theta), sin(theta); -sin(theta), cos(theta)];
    xyArray = xyArray + [x y];
    xy = {xyArray};
end