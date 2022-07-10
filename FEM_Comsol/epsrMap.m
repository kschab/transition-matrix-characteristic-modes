function out = epsrMap(kx, ky, kz, k0)
%% spatial distribution of relative permittivity

% simple sphere of radius r
% r = 5.590169943749475e-02;
% ind = ((kx.^2 + ky.^2 + kz.^2) < (k0*r)^2);
% out = 0*kx + 1;
% out(ind,1) = 3;

% simple cylinder of radius r and height h
r = 5.25e-3;
h = 4.6e-3;
ind = (sqrt(kx.^2 + ky.^2) < (k0*r)) & (abs(kz) < (k0*h/2));
out = 0*kx + 1;
out(ind,1) = 38;


end