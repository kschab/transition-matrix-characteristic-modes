function [points, weights] = gaussQuadLine(nQuad)
%% gaussQuadLine returns Gauss-Legendre quadrature points and weights for a line
% This function provides points and weights for a Gauss-Legendre quadrature
%
%  Integrate[f(t),{t,0,1}] ==> sum( f(points) .* weights )
% 
%  INPUTS
%   nQuad: the order of the Gaussian quadrature
%
%  OUTPUTS
%   points: points on interval (0,1) , double [N x 3]
%   weights: quadrature weights, double [N x 1]
%
%  SYNTAX
%
%  gaussQuadLine(nQuad)
%
% Default syntax, all input arguments must be set.
%
% Included in AToM, info@antennatoolbox.com
% © 2019, Lukas Jelinek, CTU in Prague, lukas.jelinek@antennatoolbox.com

nQuad = abs(ceil(nQuad)); % positive integer

if nQuad > 40
    nQuad=40;
    warning('Quadrature order is too large');
end

% roots of legendre polynomial with a given precision
points = quadrature.legendreRoots(nQuad,1e-14);
% weights of 1D Gauss-Legendre Quadrature
weights = 2 ./ ( ( 1 - points .^ 2 ) .* ...
    ( ( quadrature.derivativeLegendreSimple( nQuad , points )).^2 ) );
[~,ind] = sort(points);
% interval shift (-1,1)-->(0,1)
points = ( 0.5 * points(ind) + 0.5 );
weights = ( weights(ind) / 2 );

end

