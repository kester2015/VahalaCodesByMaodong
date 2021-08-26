function xy = DrawRect(x,y,w,h,coord_type)
% 
% Function DrawRect outputs a rectangle shape.
%
% x: center or corner x coordinate.
% y: center or corner y coordinate.
% w: width.
% h: height.
% coord_type: {'center'}|'corner' determines how to interpret x & y.
switch coord_type
    case 'corner'
        x = x + w/2;
        y = y + h/2;
    otherwise
end
w = w/2;
h = h/2;
xy = {[x-w, y-h; x-w, y+h; x+w, y+h; x+w, y-h]};
end