function xy = ShapeTrans(xy,x,y)
% 
% Function ShapeTrans translates the shapes in xy.
%
% xy: shapes to be translated.
% x: translation x coordinate.
% y: translation y coordinate.
for index=1:length(xy)
    coord=xy{index};
	coord(:,1)=coord(:,1)+x;
    coord(:,2)=coord(:,2)+y;
    xy{index}=coord;
end
end