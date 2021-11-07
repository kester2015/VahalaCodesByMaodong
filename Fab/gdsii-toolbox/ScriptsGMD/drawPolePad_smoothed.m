function xy = drawPolePad_smoothed(x,y, length, height, padDepth, teethHeight, smoothFun, dutyCycle)
% The code is used to generate modulation pad in "E" shape. If you want to
% generate a pad in "$\exist$" shape, you can use this code together with a mirror
% transformation operation. Also a rotation operation is applicable if ”\mountainInChinese"
% needed.
%
% Parameters:
%   (x,y): In unit of um. Pad center position. 
%   length: In unit of um. Total length along the horizontal direction of the "E". 
%   height: In unit of um. Total height along the vertical direction of the "E".
%   padDepth: <1 and >0, the percentile depth of the teeth.
%   teethHeight: In unit of um. The height(vertical direction of the "E") of the teeth.
%   smoothFun: a function handle defined on [0,1]. This defines the curve
%              of the teeth.
%   dutyCycle: 0.5 by default. dutyCycle of the teeth.'
%
% Version 0.0 by Maodong Gao, 08-27-2021. Original developed for LN PPLN
% waveguide.
if nargin == 7
    dutyCycle = 0.5;
end
if dutyCycle>1 || dutyCycle<0
    error("Duty Cycle should be >0 and <1")
end

modulationPeriod = teethHeight/dutyCycle;
fprintf("Generating poleing pad with modulation period %.4f um\n", modulationPeriod);

% Convention: length in horizontial direction, height in vertical
% direction. Horiztontial and vertical refer to "E" shaped pad.
teethLength = length*padDepth;
gumHeight = modulationPeriod - teethHeight;
gumLength = length - teethLength;

% Calculate Num of teeths
numTeeth = floor(height/modulationPeriod);
% Calculate teeth smooth curve
global resolution
res = resolution;
pointsPerTeeth = ceil(teethHeight/res);
pointsPerTeeth = min(100,pointsPerTeeth);

teethCurve = zeros(pointsPerTeeth,2);
teethCurve(:,2) = linspace(teethHeight/2,-teethHeight/2,pointsPerTeeth)';
teethCurve(:,1) = arrayfun(smoothFun, linspace(0,1,pointsPerTeeth)' );

xyArray = zeros((pointsPerTeeth+2)*numTeeth+4 ,2); % 4 points per teeth plus 4 points of left pad

% start with "E" whose leftLower corner is at (0,0)
% First element is the upperleft corner of the "E" pad.
xyArray(1,:)   = [0        , height];
xyArray(2,:)   = [gumLength, height ];
xyArray(end-1,:) = [gumLength, 0];
xyArray(end,:)   = [0        , 0];

% Add teeth corners
startTeethUL_y = height - ((height - numTeeth*modulationPeriod)/2 + gumHeight/2);
% All upperLeft corners
xyArray(3:(pointsPerTeeth+2):end-2, 1) = gumLength;
xyArray(3:(pointsPerTeeth+2):end-2, 2) = startTeethUL_y - (0:numTeeth-1)*modulationPeriod;
% Add teeth curve
for ii = 1:numTeeth
    xyArray((4+(pointsPerTeeth+2)*(ii-1)):(4+(pointsPerTeeth+2)*(ii-1)+pointsPerTeeth-1) ,:) = teethCurve + [length,startTeethUL_y-teethHeight/2-modulationPeriod*(ii-1)];
end
% All lowerLeft corners
xyArray((3+pointsPerTeeth+1):(pointsPerTeeth+2):end-2, 1) = gumLength;
xyArray((3+pointsPerTeeth+1):(pointsPerTeeth+2):end-2, 2) = startTeethUL_y - (0:numTeeth-1)*modulationPeriod - teethHeight;



% make sure each segement is <8192
totalNumPoints = ((pointsPerTeeth+2)*numTeeth+4);
if totalNumPoints<8000
    % Final Translational move
    xyArray = xyArray + [x - length/2, y - height/2];
    xy = {xyArray};
else
    numSeg = ceil(totalNumPoints/8000)+1;
    teethPerSeg = floor(numTeeth/numSeg);
    numSeg = max(numSeg, ceil(numTeeth/teethPerSeg) );
    cutHeight = zeros(numSeg-1,1);
    for ii = 1:numSeg-1
        cutHeight(ii) = startTeethUL_y - modulationPeriod * teethPerSeg * ii + gumHeight/2 ;
    end
    
    xy = cell(1,numSeg);
    for ii = 1:numSeg     
        switch ii
            case 1
                xyArray_temp = [xyArray(1:(2+(pointsPerTeeth+2)*teethPerSeg),:); ...
                    gumLength, cutHeight(ii); 0,cutHeight(ii)];
                xy{ii} = xyArray_temp;
            case numSeg
                xyArray_temp = [0,cutHeight(ii-1);gumLength, cutHeight(ii-1); ...
                                xyArray((2+(pointsPerTeeth+2)*teethPerSeg*(ii-1)+1):end,:)];
                xy{ii} = xyArray_temp;
            otherwise
                xyArray_temp = [0,cutHeight(ii-1);gumLength, cutHeight(ii-1); ...
                        xyArray( (2+(pointsPerTeeth+2)*teethPerSeg*(ii-1)+1):(2+(pointsPerTeeth+2)*teethPerSeg*ii),: );...
                        gumLength, cutHeight(ii); 0,cutHeight(ii)];
                xy{ii} = xyArray_temp;       
        end
    end
    xy = transTranslation(xy, x - length/2, y - height/2 );
end

end