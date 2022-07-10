function xroot = legendreRoots( n , precis )
%% legendreRoots returns n roots of Legendre polynomial of order n
% This function provides n roots of Legendre polynomial of order n
%
%  INPUTS
%   n: order of Legendre polynomial, integer (1,2,...)
%   precis: desired precision, double (0,1)
%
%  OUTPUTS
%   xroot: n roots , double [1 x n]
%
%  SYNTAX
%
%  xroot = legendreRoots( n , precis )
%
% Default syntax, all input arguments must be set.
%
% Included in AToM, info@antennatoolbox.com
% © 2019, Lukas Jelinek, CTU in Prague, lukas.jelinek@antennatoolbox.com

% estimation of the roots
x0vec = (1-1/(8*n^2)+1/(8*n^3))*cos(pi*(4*(1:1:n)-1)/(4*n+2));

count = 0;
while max( quadrature.legendreSimple( n , x0vec ) ) > precis || count <= 1000
 % Newton–Raphson root search
 x0vec = x0vec - quadrature.legendreSimple( n , x0vec ) ./ ...
     quadrature.derivativeLegendreSimple( n , x0vec ); 
 count = count+1;
end

if count == 1000
    warning('root precision not reached')
end

xroot = x0vec;

end