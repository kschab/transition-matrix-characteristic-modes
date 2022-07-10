function legval = legendreSimple ( n , x )
%% legendreSimple returns values of Legendre polynomial of order n
% This function provides values of Legendre polynomial of order n
%
%  INPUTS
%   n: order of Legendre polynomial, integer (1,2,...)
%   x: point of evaluation, [1 x N] double from interval (-1,1)
%
%  OUTPUTS
%   legval: values of Legendre polynomial , double [1 x n]
%
%  SYNTAX
%
%  legval = legendreSimple ( n , x )
%
% Default syntax, all input arguments must be set.
%
% Included in AToM, info@antennatoolbox.com
% © 2019, Lukas Jelinek, CTU in Prague, lukas.jelinek@antennatoolbox.com

tmp=legendre(n,x);
legval=tmp(1,:);

end