%% Get transition matrix (complex Y -> complex Y) from Comsol
% Axisymmetric solver is used

%% load model
model = mphload('dielCylinderHuWangSWMatlabJiAxisym');

% show model
% mphgeom(model)

% show mesh
% mphmesh(model,'mesh1')

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

%% loop over frequency

Nka = 100; % number of frequencies
% kaVec = linspace(0.2,3.5,Nka); % electrical size (dielSphereSWMatlabJiAxisym)
kaVec = linspace(0.5,1,Nka); % electrical size (dielCylinderHuWangSWMatlabJiAxisym)
TCell = cell(1,Nka);
lMax = nan(1,Nka);

for ika = 1:Nka
    
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
    
    
    %% loop over spherical waves
    Tmat = [];
    for SWindex = 1:nSW
        tic
        
        % set parameters
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
        
        Tmat = [Tmat, fSW(:,1)];
        save([pwd,'\results\tmpTmatJiAxisymCpxCpx.mat'],'Tmat');
        
        disp(['SW index ',num2str(SWindex),', duration ',num2str(toc),' s', ...
            ' frequency sample: ',num2str(ika)])
    end
    
    TCell{1,ika} = Tmat;
end

t1 = datetime;
label = 'cylinderEpsr38';
save([pwd,'\results\TmatComsolJiAxisymCpxCpx-',date,'_',...
    num2str(hour(t1)),'_',num2str(minute(t1)),'_',num2str(second(t1)),'.mat'],...
    'TCell','kaVec','lMax','label');