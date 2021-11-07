function xy = transAxisReflection(object, axisType, axisPara )
% This code is used to generate Axis reflected gds pattern of a given gds
% pattern.
% 
% Parameters:
%   object: cell of arrays containing 'xy' positions of shapes.
%   axisType: String 'x', 'y', or 'arbi'.
%   axisPara: meaning depends on axisType
%       if axisType=='x' or 'y': axisPara is a single number specifing axis
%           is 'x=axisPara' or 'y=axisPara'.
%       if axisType=='arbi': axisPara is a 2*2 array, (1,1:2) and (2,2:2)
%           are two points specify a straight line.

xy = cell( 1,length(object) );
switch upper(axisType)
    case 'X'
        for ii = 1:length(object)
            xyArray = object{ii};
            xyArray(:,1) = 2*axisPara - xyArray(:,1);
            xy{ii} = xyArray;
        end
    case 'Y'
        for ii = 1:length(object)
            xyArray = object{ii};
            xyArray(:,2) = 2*axisPara - xyArray(:,2);
            xy{ii} = xyArray;
        end
    case 'ARBI'
        % First get Line parameter Ax+By+C=0
        A = axisPara(2,2)-axisPara(1,2); % A = y2-y1
        B = axisPara(1,1)-axisPara(2,1); % B = x1-x2
        C = axisPara(2,1)*axisPara(1,2) - axisPara(1,1)*axisPara(2,2);% C = x2*y1-x1*y2
        if A==0&&B==0
            error('arbitary line not specified correctly. Should give two different points to specify a line.')
        end
        % Use ((x+x`)/2,(y+y`)/2) on the line, and k1*k2=-1, solve the point.
        for ii = 1:length(object)
            xyArray_old = object{ii};
            xyArray = zeros(size(xyArray_old));
            xyArray(:,1) = ( (B*B-A*A)*xyArray_old(:,1)-2*A*B*xyArray_old(:,2) - 2*A*C )/(A*A+B*B);
            xyArray(:,2) = ( (A*A-B*B)*xyArray_old(:,2)-2*A*B*xyArray_old(:,1) - 2*B*C )/(A*A+B*B);
            xy{ii} = xyArray;
        end
    otherwise
        error("Specified Reflection line not recoginized, should be x|y|arbi")
end

end