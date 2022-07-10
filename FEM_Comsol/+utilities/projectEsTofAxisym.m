function [fSW] = projectEsTofAxisym(lmax, k0, thetaPoints, thetaWeights, ...
                                    EsCart, m, r)
%% get spherical f-vectors from sampled scattered field
% Convertor transforming sampled scattered electric field to spherical 
% expansion coefficients f. The guiding relation is
% Es = k*sqrt(Z) \sum_alpha f_alpha u^(4)_alpha, where u^(4) are outgoing 
% spherical vector waves, see "G. Kristensson, Scattering of 
% Electromagnetic Waves by Obstacles, 2016". The function assumes
% axisymmetric prolem with predefined azimutal order m = (-l, ..., l).
% Scattered field is sampled in phi = 0 plane. The scattered field must 
% be sampled on a sphere circumscribing the scatterer. Time dependence 
% exp(j \omega t) is assumed. Spherical waves are ordered according to 
% indexMatrix(5,:).
% Complex spherical vector harmonics with exp(j m \phi) are used.
%
%  INPUTS
%   lMax:  maximum degree of spherical vector waves, integer [1 x 1]
%   k0: wavenumber, double [1 x 1]
%   thetaPoints, thetaWeights: quadrature points and weights for 
%   numerical quadrature of integrate[f(theta)*sin(theta),{theta,0,pi}], 
%   double [1 x Np]
%   EsCart:  Es at quadrature points, double [Np x 3]
%   m: azimutal order m = (-l, ..., l), integer [1 x 1]
%   r: radius where Es is sampled, double [1 x 1]
%
%  OUTPUTS
%   fSW: spherical expansion coefficients, double [nSW x 1]
%
%  SYNTAX
%   [fSW] = projectEsTofAxisym(lmax, k0, thetaPoints, thetaWeights, ...
%                                     EsCart, m)
%
% (c) 2022, Lukas Jelinek, CTU in Prague, lukas.jelinek@fel.cvut.cz

%% get auxiliary quantities
indexMatrix = ...
    sphericalVectorWaves.indexMatrix(lmax);

nSW = size(indexMatrix,2);

phi = zeros(size(thetaPoints));

Np = size(thetaPoints,2);

% transform E to spherical coordinates
Esph = utilities.vecCart2Sph(EsCart, thetaPoints.', phi.');

% % % %%
% % % l = 3;
% % % m = 1;
% % % 
% % % EsphX = nan(size(Esph));
% % % 
% % % for ip = 1:Np
% % % 
% % %     [Y1, Y2, ~] = sphericalVectorWaves.functionY(...
% % %         l, m, thetaPoints(1,ip), 0);
% % %     Y1 = squeeze(Y1);
% % %     Y2 = squeeze(Y2);
% % %     
% % %     % sigma,tau
% % %     Y11 = conj(Y1);
% % %     Y21 = Y1;
% % %     Y12 = conj(Y2);
% % %     Y22 = Y2;
% % % 
% % %     Esph(ip,:) = Y11;
% % %     EsphX(ip,:) = Y12;
% % % 
% % % end
% % % 
% % % sum(utilities.rowDot(conj(Esph),EsphX).*thetaWeights.')

%%

% In the case of complex Y, even means exp(j m phi) while odd means exp(- j m phi).
if m >= 0
sigma = 2; % even
else
sigma = 1; % odd
end    
m = abs(m);

%% get radial functions

[R1, R2, ~, ~] = sphericalVectorWaves.functionR(...
    indexMatrix(1,:), k0*r, 4);

R = zeros(nSW,1);
% tau = 1
ind = (indexMatrix(4, :) == 1);
R(ind, 1) = R1(ind, 1);
% tau = 2
ind = (indexMatrix(4, :) == 2);
R(ind, 1) = R2(ind, 1);

%% calculate projections

fSW = zeros(nSW,1); % spherical expansion vector

bar = waitbar(0,'projection to spherical waves');
for ip = 1:Np
    [Y1, Y2, ~] = sphericalVectorWaves.functionY(...
        indexMatrix(1,:).', indexMatrix(2,:).', thetaPoints(1,ip), phi(1,ip));
    Y1 = squeeze(Y1);
    Y2 = squeeze(Y2);
    
    % the field is projected to conj(Y) when complex Y is used
    % In the case of complex Y, even means exp(j m phi) while odd means exp(- j m phi).
    tmp11 = utilities.rowDot(Y1,repmat(Esph(ip,:),[nSW,1]));
    tmp21 = utilities.rowDot(conj(Y1),repmat(Esph(ip,:),[nSW,1]));
    tmp12 = utilities.rowDot(Y2,repmat(Esph(ip,:),[nSW,1]));
    tmp22 = utilities.rowDot(conj(Y2),repmat(Esph(ip,:),[nSW,1]));

    if sigma == 1
    % sigma = 1, tau = 1
    ind = indexMatrix(2, :) == m & indexMatrix(4, :) == 1 & indexMatrix(3, :) == 1;
    fSW(indexMatrix(5, ind),1) = fSW(indexMatrix(5, ind),1) + thetaWeights(1,ip)*tmp11(ind,1);

    % sigma = 1, tau = 2
    ind = indexMatrix(2, :) == m & indexMatrix(4, :) == 2 & indexMatrix(3, :) == 1;
    fSW(indexMatrix(5, ind),1) = fSW(indexMatrix(5, ind),1) + thetaWeights(1,ip)*tmp12(ind,1);    
    
    else
    % sigma = 2, tau = 1
    ind = indexMatrix(2, :) == m & indexMatrix(4, :) == 1 & indexMatrix(3, :) == 2;
    fSW(indexMatrix(5, ind),1) = fSW(indexMatrix(5, ind),1) + thetaWeights(1,ip)*tmp21(ind,1);
    
    % sigma = 2, tau = 2
    ind = indexMatrix(2, :) == m & indexMatrix(4, :) == 2 & indexMatrix(3, :) == 2;
    fSW(indexMatrix(5, ind),1) = fSW(indexMatrix(5, ind),1) + thetaWeights(1,ip)*tmp22(ind,1);
    end
    
waitbar(ip/Np,bar,'projection to spherical waves')
end
close(bar)

Z0 = 3.767303137706895e+02;

if m == 0
fSW = 2*pi*fSW./(k0*sqrt(Z0)*R);
else
fSW = pi*fSW./(k0*sqrt(Z0)*R);
end

% if m == 0
% fSW = fSW./(k0*sqrt(Z0)*R);
% else
% fSW = 2*fSW./(k0*sqrt(Z0)*R);
% end

end