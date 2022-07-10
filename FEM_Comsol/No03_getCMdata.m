%% get characteristic mode data

%% transition matrix
% uncomment to load the precalculated results
% load([pwd,'\results\TmatComsolJiAxisymCpxCpx-30-Jun-2022_8_35_27.159.mat']);

% calculate characteristic modes
[tCell, fCell] = utilities.calculateCMfromTmat(TCell);

% track modes
[tTracked, fTracked] = utilities.CMTtracking(tCell, fCell, 30);