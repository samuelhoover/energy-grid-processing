%% Load filtered zeolite data
load ../Data/Zeolites/'Unprocessed Data'/realZeolites.mat
zeos = keys(M);
datasets = values(M);

%% Load zeolite screening data
% Henry's constant - Kh [mol/kg/MPA]
% Energy - U [kJ/mol]
% Loading - Q [mol/kg]
% Molecules of adsorbate per unit cell - N [molec/uc]
% Selectivity - S [dimensionless]
% Performance - P [dimensionless]
someReal_Ex = readtable('../Data/Zeolites/PB Screening/HC-IZASC.txt', 'Delimiter', ' ');  % all IZA examples
% someHypo_Ex = readtable('../Data/Zeolites/PB Screening/HC-SLC.txt', 'Delimiter', ' ');  % only hypothetical examples with all information
% allHypo_Ex = readtable('../Data/Zeolites/PB Screening/HC-SLC-short.txt', 'Delimiter', ' ');  % all hypothetical examples

%% Extracting data from .txt files
% Zeolites
someReal_Zeos = someReal_Ex.IZA_SC;
% someHypo_Zeos = someHypo_Ex.PCOD;
% allHypo_Zeos = allHypo_Ex.PCOD;

% Henry's constant data
someReal_kH_C18 = someReal_Ex.kH_C18;
someReal_kH_C24 = someReal_Ex.kH_C24;
someReal_kH_C30 = someReal_Ex.kH_C30;
someReal_kH_2C17 = someReal_Ex.kH_2C17;
someReal_kH_4C17 = someReal_Ex.kH_4C17;
someReal_kH_22C16 = someReal_Ex.kH_22C16;
% someHypo_kH_C18 = someHypo_Ex.kH_C18;
% allHypo_kH_C18 = allHypo_Ex.kH_C18;

%% Look at distribution of Henry's constants
% figure;
% histogram(someHypo_kH_C18, 1000);
% set(gca, 'Yscale', 'log')
% title('Hypothetical zeolites')
% xlabel('Henry''s constant [mol/kg/MPa]')
% ylabel('Frequency')
% 
% figure;
% histogram(someReal_kH_C18, 100);
% set(gca, 'Yscale', 'log')
% title('Real zeolites')
% xlabel('Henry''s constant [mol/kg/MPa]')
% ylabel('Frequency')

%% Find which zeolites from filtered list are in HC_IZASC.txt and extract Henry's constant data
% Find index in someReal_Zeos (Lia) of zeolites that are in filtered
% zeolite dataset
[Lia, Locb] = ismember(someReal_Zeos, zeos);
IZA = someReal_Zeos(Lia);
energy_grids = datasets(nonzeros(Locb))';
kH_C18 = someReal_kH_C18(Lia);
kH_C24 = someReal_kH_C24(Lia);
kH_C30 = someReal_kH_C30(Lia);
kH_2C17 = someReal_kH_2C17(Lia);
kH_4C27 = someReal_kH_4C17(Lia);
kH_22C16 = someReal_kH_22C16(Lia);

%% Export similar zeolites and Henry's constant data to .csv file
csv_header = ["IZA", "kH_C18", "kH_C24", "kH_C30", "kH_2C17", "kH_4C17", "kH_22C16"];
csv_file = [csv_header; 
           [string(IZA), kH_C18, kH_C24, kH_C30, kH_2C17, kH_4C27, kH_22C16]];
writematrix(csv_file, '/Volumes/Samuel Hoover External HDD/ML Data/Zeolites/henry_constants.csv')

%% Inverse normalize data
m = length(IZA);
for i = 1:m
    dsetNorm = inverseNormalizeData(energy_grids{i}, 8.0814e+04);
    energy_grids{i} = dsetNorm;
end

%% Save data in structure and export
field1 = 'Zeolite_structures'; value1 = IZA;
field2 = 'Energy_grids'; value2 = energy_grids;
field3 = 'Henry_constants'; value3 = num2cell(kH_C18);
zeoStruct = struct(field1, value1, field2, value2, field3, value3);
save('../Data/Zeolites/Processed Data/data_V2.mat', 'zeoStruct')
