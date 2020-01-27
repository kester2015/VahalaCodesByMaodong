function xy = DrawTaper(x,y,w,h1,h2,coord_type)
% 
% Function DrawTaper outputs a taper/triangle shape.
%
% x: x coordinate.
% y: center y coordinate.
% w: width.
% h1: height @ left.
% h2: height @ left.
% coord_type: {'c'}|'l'|'r' determines how to interpret x.
switch coord_type
    case 'l'
        x = x + w/2;
    case 'r'
        x = x - w/2;
    otherwise
end
w = w/2;
h1 = h1/2;
h2 = h2/2;
xy = {[x-w, y-h1; x-w, y+h1; x+w, y+h2; x+w, y-h2]};
end