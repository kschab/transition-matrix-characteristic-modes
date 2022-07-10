function m = mSWaxisym (sWind, ka)

sWindVec = sWind(1,1); % Comsol make it as long as kx

lmax = ceil(ka + 7*(ka)^(1/3) + 3);

indexMatrix = ...
    sphericalVectorWaves.indexMatrix(lmax);

% calculate which column of indexMatrix is used
columnInd = find(indexMatrix(5,:) == sWindVec(1,1), 1);

m = indexMatrix(2,columnInd);
end    