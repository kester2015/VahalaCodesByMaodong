function res_error = get_kappa_error(kappa_t)
load('Parameters.mat');
load('alpha.mat');
for m = 1 : N
    filename = strcat('D', num2str(m), '_1.mat');
    [delta_p1, P_out1, v(m)] = Get_delta(filename);
    [~, FWHM1(m)] = Get_FWHM(filename);
    FWHM1(m) = FWHM1(m)*FSR;
    [delta_p2, P_out2, FWHM2(m)] = Get_dynamics(kappa_t, v(m));
    %%
    [dip_y1, dip_x1] = min(P_out1);
    delta_p1 = delta_p1 - delta_p1(dip_x1);
    [dip_y2, dip_x2] = min(P_out2);
    delta_p2 = delta_p2 - delta_p2(dip_x2);
end
res_error = norm(FWHM1 - FWHM2)^2;
end

