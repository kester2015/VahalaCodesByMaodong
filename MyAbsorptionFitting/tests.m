plot(x_freq,abs(cavitytransT(x_freq,5,6,kappa0,kappae,fp_fit ) ).^2)

%% optimization related codes

function dd = modtrans(A0,r,x1,T,k0,ke,x0,alpha,x)
    fit_fp   = fittype(' A0   /     ( 1-B*cos( (x-x1)/T*2*pi) )','coefficients',{'A0','B','x1','T'});
    fp_fit = cfit(fit_fp,0,0,0,0);
    fp_fit.A0 = A0/(1+r^2);
    fp_fit.B = 2*r/(1+r^2);
    fp_fit.x1 = x1;
    fp_fit.T = T;
    k = k0 + ke;
    dd = transOutput(x, x0, alpha, k, ke, fp_fit);
%     dd=( A0*abs((1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2)).^2 )./ (abs(1-r*( (1i*(x-x0)+(k0-ke)/2)./(1i*(x-x0)+(k0+ke)/2) ).^2 .* exp(-1i*2*pi*(x-x1)/T) ).^2);
end

function res = modtrans_residual(A0,r,x1,T,k0,ke,x0,alpha,  x,   trans)
    % trans is the real transmission. calculate residual
    res = trans - modtrans(A0,r,x1,T,k0,ke,x0,alpha, x);
end

function loss = QLF(rr,weight) %Quadratic Loss Function
    if nargin == 1
        weight = ones(size(rr));
    end
    loss = sum( weight.*(rr.^2) )/length(rr);
end

function loss = LCL(rr,weight) % Log-Cosh Loss
    if nargin == 1
        weight = ones(size(rr));
    end
    loss = sum( weight .* log(cosh(rr)) ) / length(rr);
end

%% Interactivity power
function a2 = interCavityP(x, x0, alpha, k, ke, fp_fit)
    ss = size(x);
    if ss(1) < ss(2)
        x = x.';
    end % make sure column vector
    para1 = alpha^2 * ones(size(x));
    para2 = -2*(x-x0)*alpha;
    para3 = (x-x0).^2 + (k/2)^2;
    para4 = -ke * fp_fit(x);
    if alpha == 0
        a2 = -para4./para3;
        return 
    end
    solution_quartic = CardanRoots([para1 para2 para3 para4]);
    solution_quartic(imag(solution_quartic)~=0) = -Inf; % remove imaginary solutions
    a2 = max(solution_quartic,[],2);
end

%% Cavity Transmission function
function T = cavitytransT(x, x0, alpha, k, ke, fp_fit)
k0 = k - ke;
a2 = interCavityP(x, x0,alpha, k, ke, fp_fit);
T = (1i*(x-x0-alpha*a2)+(k0-ke)/2)./(1i*(x-x0-alpha*a2)+(k0+ke)/2);
end

%% On waveguide output function
function output = transOutput(x, x0, alpha, k, ke, fp_fit)
Tran = cavitytransT(x, x0, alpha, k, ke, fp_fit);
r1r2 = ( 1-sqrt(1-fp_fit.B^2) )/fp_fit.B ;
output = fp_fit(x).* abs( Tran./(1 - r1r2*Tran.^2.*exp(-1i*2*pi*(x-fp_fit.x1)/fp_fit.T)) ).^2;
end

%% MZI to Phase function
function phase = MZI2Phase(trace_MZI)
    trace_length = length(trace_MZI);
    trace_MZI_tofit = trace_MZI;
    % trace_MZI_tofit = sgolayfilt(trace_MZI, 1, 11);
    Base = (max(trace_MZI_tofit) + min(trace_MZI_tofit))/2;
    trace_MZI_phasor = hilbert(trace_MZI_tofit - Base); % use phasor for non-parametric fit

    trace_MZI_phase = [0; cumsum(mod(diff(angle(trace_MZI_phasor))+pi, 2*pi) - pi)] + angle(trace_MZI_phasor(1));
    % trace_MZI_phase = sgolayfilt(trace_MZI_phase, 1, 11);
    phase = sgolayfilt(trace_MZI_phase, 2, round(trace_length/40)*2 + 1);
    % phase = trace_MZI_phase;
end