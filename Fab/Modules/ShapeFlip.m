function xy = ShapeFlip(xy,type,x)
% 
% Function ShapeFlip flips the shapes in xy.
%
% xy: shapes to be rotated.
% type: {'x'}|'y' flip in the left-right / up-down direction.
% x: coordinate of the reflection axis.
for index=1:length(xy)
    coord=xy{index};
    switch type
        case 'y'
            coord(:,2)=2*x-coord(:,2);
        otherwise
            coord(:,1)=2*x-coord(:,1);
    end
    xy{index}=coord;
end
end