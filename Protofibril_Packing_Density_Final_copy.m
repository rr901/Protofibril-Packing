clear all;
close all;

RawData = xlsread('Insert file');
%% 
Wavelength = RawData(:, 1);
WavelengthNew = Wavelength * 10^-7;
Background = RawData(:, 2);  % Assuming the data format in the Excel file is consistent
FibrinogenConcentration = 0.0007; % 0.0001 g/mL or 0.70 mg/mL
Pathlength = 0.24; %Change if path length is altered
% Define concentrations
conditions = [1:6];  % Add other concentrations here if needed

% Initialize an empty table to store the results
data = table();

for concentration_index = 1:length(conditions)
    TotalConditions = conditions(concentration_index);

    % Extract data for the current concentration
    Average = RawData(:, concentration_index + 2);  % Assuming the data format in the Excel file is consistent

    % Perform calculations for the current concentration
    Normalize = Average - Background;
    Turbidity = (Normalize / Pathlength) * log(10);
    tlambda = Turbidity .* WavelengthNew.^5;

    n = 1.327 + ((3.06 * 10.^3) / (Wavelength.^2));
    dndc = 0.1863 + (1169.9 / (Wavelength.^2));

    y = tlambda;
    x = WavelengthNew.^2;

    % Linear Regression
    mdl = fitlm(x, y);

    % y-intercept
    yint = mdl.Coefficients.Estimate(1);

    % slope
    slope = mdl.Coefficients.Estimate(2);

    % Calculate diameter and other values
    diameter = (2 * sqrt(-yint / (slope * (184 / 231) * pi^2 * n(1)^2)))*10000000;
    masslengthratio = slope / ((88 / 15) * (pi^3) * (1 / (6.022 * 10^23)) * (FibrinogenConcentration) * n(1) * (dndc(1)^2));
    Protofibrilpackingdensity = masslengthratio / 144000000000;

    % Add a row for the current concentration to the table
    newRow = table(TotalConditions, diameter, Protofibrilpackingdensity, masslengthratio,'VariableNames', {'Conditions', 'Diameter', 'ProtofibrilPackingDensity','masslengthratio'});
    data = [data; newRow];
end

% Create the uitable for the table body
uitable('Data', table2cell(data), 'ColumnName', data.Properties.VariableNames, 'Position', [100, 100, 350, 600]);
