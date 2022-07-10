function derlegval = derivativeLegendreSimple( n , x )
%% legendreSimple returns values of derivative of Legendre polynomial of order n
% This function provides values of derivative of Legendre polynomial 
% of order n
%
%  INPUTS
%   n: order of Legendre polynomial, integer (1,2,...)
%   x: point of evaluation, [1 x N] double from interval (-1,1)
%
%  OUTPUTS
%   derlegval: values of derivative of Legendre polynomial , double [1 x n]
%
%  SYNTAX
%
%  derlegval = derivativeLegendreSimple( n , x )
%
% Default syntax, all input arguments must be set.
%
% Included in AToM, info@antennatoolbox.com
% © 2019, Lukas Jelinek, CTU in Prague, lukas.jelinek@antennatoolbox.com

if n == 0
    derlegval = 0;
else
    derlegval = n * ( x .* quadrature.legendreSimple( n , x ) - ...
        quadrature.legendreSimple( n-1 , x ) ) ./ ( x.^2 - 1 );
end

end