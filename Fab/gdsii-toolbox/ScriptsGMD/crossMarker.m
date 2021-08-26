function xy = crossMarker(x,y,size,width,varargin)
%
% Function CrossMarker outputs a cross shaped marker
%
% x,y -- marker center position;
% size -- marker length along long axis
% width -- marker width along short axis
    ip = inputParser;
    ip.addParameter('angle', 0, @isnumeric); % rotate angle
    ip.parse(varargin{:});
    theta = ip.Results.angle * pi / 180;
    
    xyArray = zeros(12,2);
    xyArray(1,:) = [-width/2, width/2];
    xyArray(2,:) = [-width/2, size/2];
    xyArray(3,:) = [ width/2, size/2];
    xyArray(4,:) = [ width/2, width/2];
    xyArray(5,:) = [ size/2 , width/2];
    xyArray(6,:) = [ size/2 , -width/2];
    xyArray(7,:) = [ width/2, -width/2];
    xyArray(8,:) = [ width/2, -size/2];
    xyArray(9,:) = [-width/2, -size/2];
    xyArray(10,:) = [-width/2, -width/2];
    xyArray(11,:) = [-size/2 , -width/2];
    xyArray(12,:) = [-size/2 ,  width/2];
    
    xyArray = xyArray * [cos(theta), sin(theta); -sin(theta), cos(theta)];
    xyArray = xyArray + [x y];
    xy = {xyArray};
end