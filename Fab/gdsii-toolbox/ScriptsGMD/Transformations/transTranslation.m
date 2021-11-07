function xy = transTranslation(object, x,y )
% This code is used to generate translational esult gds pattern of a given gds
% pattern.
% 
% Parameters:
%   object: cell of arrays containing 'xy' positions of shapes.
%   (x,y): translation length in x and y direction
xy = cell( 1,length(object) );
for ii = 1:length(object)
    xyArray = object{ii};
    xyArray = xyArray + [x,y];
    xy{ii} = xyArray;
end

end