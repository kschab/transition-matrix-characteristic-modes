%% prepare and check excitation to get characteristic field
% Axisymmetric solver is used

%% load model
model = mphload('dielCylinderHuWangSWMatlabJiAxisymLoadAinc');

%% load the precalculated results
load([pwd,'\results\TmatComsolJiAxisymCpxCpx-30-Jun-2022_8_35_27.159.mat']);

%% calculate characteristic modes
[tCell, fCell] = utilities.calculateCMfromTmat(TCell);

ika = 81; % 17, 53, 59, 81

tVal = tCell{1,ika};
fMat = fCell{1,ika};

%% select mode to be used
iCM = 1;
aIncVec = fMat(:,iCM).'/tVal(iCM,1);

% see parameters of the model
param = mphgetexpressions(model.param);
param

%% Numerical quadrature for Integrate[f(theta)*sin(theta),{theta,0,pi}]
nQuad = 40; % quadrature order (1-40);
% points and weights on interval (0,1)
[points, weights] = quadrature.gaussQuadLine(nQuad);
% points and weights on interval (0,pi) including sin(theta) factor
thetaPoints = points*pi;
thetaWeights = pi*weights.*sin(thetaPoints);

%% setup of the solver
ka = kaVec(1,ika); % electric size

% set electric size
model.param.set('ka',num2str(ka));
param = mphgetexpressions(model.param);

a = param{7,4} % circumscribing radius
param{7,3}

tAir = param{1,4}
param{1,3}

scattRadius = a + 0.7*tAir; % radius of the measurement sphere

% maximum degree of spherical waves
iota = 2;
lMax(1,ika) = ceil(ka + iota*(ka)^(1/3) + 3);

k0 = param{8,4} % wavenumber
param{8,3}

f0 = param{10,4} % frequency
param{10,3}

% number of spherical waves
indexMatrix = ...
    sphericalVectorWaves.indexMatrix(lMax(1,ika));
nSW = size(indexMatrix,2);

%% run solver

% get the most significant SWindex and evaluate SW indices allowed by axial symmetry
SWindex = find(abs(aIncVec) == max(abs(aIncVec)));
columnInd = find(indexMatrix(5,:) == SWindex, 1);
m = indexMatrix(2,columnInd);
sigma = indexMatrix(3,columnInd);
allowedSWindices = (indexMatrix(2,:) == m) & (indexMatrix(3,:) == sigma);
allowedSWindices = indexMatrix(5,allowedSWindices);

% filter out not-allowed SW indices
tmp = aIncVec;
aIncVec = zeros(1,nSW);
aIncVec(1,allowedSWindices) = tmp(1,allowedSWindices);

if max(abs(tmp - aIncVec)/norm(tmp)) > 1e-5
    warning('important filering of the input vector')
end
save('aInc.mat','aIncVec')

% set leadind SW index in solver
model.param.set('sWind',num2str(SWindex));

% run given study
model.study('std1').run

%% evaluate scattered field, phi = 0
rho = scattRadius*sin(thetaPoints);
z = scattRadius*cos(thetaPoints);

[EsrhoRe, EsphiRe, EszRe] = mphinterp(model,{'real(emw.Er)',...
    'real(emw.Ephi)','real(emw.Ez)'},'coord',[rho;z]);
[EsrhoIm, EsphiIm, EszIm] = mphinterp(model,{'imag(emw.Er)',...
    'imag(emw.Ephi)','imag(emw.Ez)'},'coord',[rho;z]);
EsRho = (EsrhoRe + 1i*EsrhoIm).';
EsPhi = (EsphiRe + 1i*EsphiIm).';
EsZ = (EszRe + 1i*EszIm).';

% transform to Cartesian coordinates, phi = 0
EsCart = [EsRho , EsPhi, EsZ];

%% get f-vector from Es
% get m and sigma and convert to m = -n .. n
% m > 0 are called even (sigma = 2)
% m < 0 are called odd (sigma = 1)
% m = 0 is even (sigma = 2)
columnInd = find(indexMatrix(5,:) == SWindex, 1);
m = indexMatrix(2,columnInd);
sigma = indexMatrix(3,columnInd);
if sigma == 1
    m = - m;
end

[fSW] = utilities.projectEsTofAxisym(lMax(1,ika), k0, thetaPoints, thetaWeights, ...
    EsCart, m, scattRadius);

%% If aIncVec is right, vectors fSW and fMat(:,iCM) should be the same
[fSW, fMat(:,iCM)]

figure
semilogy(abs(fSW),'x')
hold on
semilogy(abs(fMat(:,iCM)),'o')
grid on
