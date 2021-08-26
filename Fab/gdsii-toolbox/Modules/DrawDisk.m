function xy = DrawDisk(x,y,rout,rin,t1,t2)
% 
% Function DrawTaper outputs a taper/triangle shape.
%
% x: center x coordinate.
% y: center y coordinate.
% rout: outer radius.
% rin: inner radius.
% t1: start angle, in degrees.
% t2: end angle, in degrees.
global resolution;
nptsout = ceil(abs(t1-t2)/180*pi*rout/resolution)+1;
nptsin = ceil(abs(t1-t2)/180*pi*rin/resolution)+1;
nseg = ceil((nptsout+nptsin)/8000);
if nseg>2 && abs(t1-t2)==360 % force dividing at quadrants for full circles
    nseg=4*ceil(nseg/4);
end
theta = linspace(t1,t2,nseg+1);

xy={};
while length(theta)>=2
    thetaout=linspace(theta(1),theta(2),ceil(nptsout/nseg)).';
    ptsout=[x+rout*cosd(thetaout),y+rout*sind(thetaout)];
    thetain=linspace(theta(1),theta(2),ceil(nptsin/nseg)).';
    if rin~=0
        ptsin=[x+rin*cosd(thetain),y+rin*sind(thetain)];
    else
        ptsin=[x,y];
    end
    xy{end+1}=[ptsout;flipud(ptsin)];
    theta=theta(2:end);
end
end