% Trying to recreate nan problem with LIT-0.h5 and BCT-1.h5

% Occurs after calling inverseNormalizeData.m
% inverse normalize function --> out = 1 - (in - min) / (max - min)
% [lower limit, upper limit] --> [1, 0]
% *nan arises because min and max are identical*
%% LIT-0.h5
LIT0 = h5read('../Data/Zeolites/HDF5 Files/Real Zeolites/LIT-0.h5', '/CH4');
LIT0min = min(LIT0, [], 'all');  % 8.5145e+03
LIT0max = max(LIT0, [], 'all');  % 1.3221e+20
% figure; volshow(LIT0);
LIT0cap_5E3 = LIT0;
LIT0cap_5E3(LIT0cap_5E3 >= 5000) = 5000;  % upper limit used when nan occurred
LIT0cap_5E3_norm = inverseNormalizeData(LIT0cap_5E3, 5000);
fprintf('NANs at these indices: %i\n', find(isnan(LIT0cap_5E3_norm) == 1))  %#ok<COMPNOP>

% NAN comes from the capped min and max becoming the same since the global
% minimum is greater than 5000.
LIT0capmin = min(LIT0cap_5E3, [], 'all');  % 5000
LIT0capmax = max(LIT0cap_5E3, [], 'all');  % 5000


%% BCT-1.h5
BCT1 = h5read('../Data/Zeolites/HDF5 Files/Real Zeolites/BCT-1.h5', '/CH4');
BCT1min = min(BCT1, [], 'all');  % 1.0055e+04
BCT1max = max(BCT1, [], 'all');  % 1.1841e+20
% figure; volshow(BCT1);
BCT1cap_5E3 = BCT1;
BCT1cap_5E3(BCT1cap_5E3 >= 5000) = 5000;  % upper limit used when nan occurred 
fprintf('NANs at these indices: %i\n', find(isnan(BCT1cap_5E3) == 1))  %#ok<COMPNOP>

% NAN comes from the capped min and max becoming the same since the global
% minimum is greater than 5000.
BCT1capmin = min(BCT1cap_5E3, [], 'all');  % 5000
BCT1capmax = max(BCT1cap_5E3, [], 'all');  % 5000

