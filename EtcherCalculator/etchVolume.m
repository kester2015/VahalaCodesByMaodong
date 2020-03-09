function [totalVol,boundaryVol,bareVol,ucVol] = etchVolume(varargin)
    % all length except for undercut is in unit of mm!
    
    ip = inputParser;
    ip.addParameter('size', [0 0], @isnumeric); 
    % width and length of the chip, in unit of mm, boundary length times pi*uc^2/4 later.
    
    ip.addParameter('bareArea', 0, @isnumeric); 
    % area of exposed Si, in unit of mm^2, times uc later
    
    ip.addParameter('etchPerimeter', 0, @isnumeric); 
    % perimeter of undercut boundarys, in unit of mm, times pi*uc^2/4 later!
    % adjacent two boundaries should be counted twice here.
    
    ip.addParameter('uc', 0, @isnumeric); 
    % undercut, in unit of um!
    
    ip.parse(varargin{:});
    size          = ip.Results.size;
    bareArea      = ip.Results.bareArea;
    etchPerimeter = ip.Results.etchPerimeter;
    uc            = ip.Results.uc * 1e-3; % transfer to mm, do all calculations in mm.
    
    
    boundaryVol = ( sum(size)*2 ) * pi*uc^2/4;
    bareVol = bareArea * uc;
    ucVol = etchPerimeter * pi*uc^2/4;
    totalVol = boundaryVol + bareVol + ucVol;
end