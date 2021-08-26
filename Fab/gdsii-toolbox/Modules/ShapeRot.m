function xy = ShapeRot(xy,x,y,t)
% 
% Function ShapeRot rotates the shapes in xy.
%
% xy: shapes to be rotated.
% x: center x coordinate.
% y: center y coordinate.
% t: ccw rotation angle, in degrees.
xy = ShapeTrans(xy,-x,-y);
for index=1:length(xy)
    coord=xy{index};
	coord=coord*[cosd(t),sind(t);-sind(t),cosd(t)];
    xy{index}=coord;
end
xy = ShapeTrans(xy,x,y);
end