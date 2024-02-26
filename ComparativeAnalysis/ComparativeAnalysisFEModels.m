clc;
clear all;
close all;

%% Start by updating the model-geometry
% Define initial geometry-dimension-->average values from literature
DiscHeight = 14;
LateralWidth = 49;
SagittalWidth = 33.4;
% Update model-geometry based on the inital dimensions
UpdateDimensions(DiscHeight, LateralWidth, SagittalWidth, 1); % HGO model
UpdateDimensions(DiscHeight, LateralWidth, SagittalWidth, 2); % rebar-models 


%% Sensitivity Analysis
% perform sensitivity analyses of the different models and store the
% parameters to be calibrated
SensitivityLimit = 0.1;
% HGO model
CalibrationParametersHGO = SensitivityAnalysis(1, SensitivityLimit);
% Rebar model --> using only the linear rebar model
CalibrationParametersRebar = SensitivityAnalysis(2, SensitivityLimit);


%% Calibration of the different models
% define calibration-settings
RsquaredThreshold_1 = 0.85;
RsquaredThreshold_2 = 0.9;
MaxNGenerations_1 = 20;
MaxNGenerations_2 = 10;
% Calibration of the HGO-model
% 1st step: all parameters except fiber angle variation
Step = 1;
CalParameters = 1:10;
CalParameters = intersect(CalParameters, CalibrationParametersHGO);
[BestRsquared_HGO1, HGOConfiguration_1] = CalibrationMaterialParameters(1, [], MaxNGenerations_1, 20, RsquaredThreshold_1, CalParameters, Step);
% 2nd step: fiber angle variation
Step = 2;
CalParameters = 11:13;
CalParameters = intersect(CalParameters, CalibrationParametersHGO);
[BestRsquared_HGO2, HGOConfiguration_2] = CalibrationMaterialParameters(1, HGOConfiguration_1, MaxNGenerations_2, 20, RsquaredThreshold_2, CalParameters, Step);

% Calibration of the linear Rebar model
% 1st step: all parameters except fiber angle variation
Step = 1;
CalParameters = 3:7; % NP-definition from the first model
CalParameters = intersect(CalParameters, CalibrationParametersRebar);
StartConfiguration = zeros(1,11);
StartConfiguration(1:2) = HGOConfiguration_2(1:2);
[BestRsquared_LinReb1, LinRebConfiguration_1] = CalibrationMaterialParameters(2, StartConfiguration, MaxNGenerations_1, 20, RsquaredThreshold_1, CalParameters, Step);

% 2nd step: fiber angle variation
Step = 2;
CalParameters = 9:11;
CalParameters = intersect(CalParameters, CalibrationParametersRebar);
[BestRsquared_LinReb2, LinRebConfiguration_2] = CalibrationMaterialParameters(2, LinRebConfiguration_1, MaxNGenerations_2, 20, RsquaredThreshold_2, CalParameters, Step);

% Calibration of the non-linear Rebar model
% 1st step: all parameters except fiber angle variation
Step = 1;
CalParameters = 5:7; % NP-definition from the first model & af-groundsubstance from the second model
CalParameters = intersect(CalParameters, CalibrationParametersRebar);
StartConfiguration = zeros(1,11);
StartConfiguration(1:4) = LinRebConfiguration_2(1:4);
[BestRsquared_NonLinReb1, NonLinRebConfiguration_1] = CalibrationMaterialParameters(3, StartConfiguration, MaxNGenerations_2, 20, RsquaredThreshold_1, CalParameters, Step);
% 2nd step: fiber angle variation
Step = 2;
CalParameters = 9:11;
CalParameters = intersect(CalParameters, CalibrationParametersRebar);
[BestRsquared_NonLinReb2, NonLinRebConfiguration_2] = CalibrationMaterialParameters(3, NonLinRebConfiguration_1, MaxNGenerations_2, 20, RsquaredThreshold_2, CalParameters, Step);


%% final calibration results
% run & evaluate simulations with final cal-configurations
RsquaredValuesCalibration = zeros(3,5);
TimeValuesCalibration = zeros(3,4);
[RsquaredValuesCalibration(1,:), TimeValuesCalibration(1,:)] = ProcessCalibrationConfiguration(HGOConfiguration_2, 1);
[RsquaredValuesCalibration(2,:), TimeValuesCalibration(2,:)] = ProcessCalibrationConfiguration(LinRebConfiguration_2, 2);
[RsquaredValuesCalibration(3,:), TimeValuesCalibration(3,:)] = ProcessCalibrationConfiguration(NonLinRebConfiguration_2, 3);

%Create .xlsx-file for results final calibrated-configurations
ResultsLabels = {'Rsquared','RsquaredFlex', 'RsquaredExt', 'RsquaredLB', 'RsquaredAR','TimeFlex','TimeExt','TimeLB','TimeAR'};
Results = [RsquaredValuesCalibration, TimeValuesCalibration];
Results = array2table(Results,'VariableNames',ResultsLabels);
% Write the table to an Excel file
excelFileName = fullfile('.', 'ExcelFiles', 'Calibration', ['CalibratedModelsComparison', '.xlsx']);
writetable(Results, excelFileName, 'Sheet', 'Sheet1', 'WriteVariableNames', true);

% compare the results from the final cal-configurations
CompareCalibrationResults;

%% validation using IDP-data from Heuer et al.
% evaluate simulations with final cal-configurations: IDP-Data from Heuer et al.
RsquaredValuesValidationIDP = zeros(3,5);
RsquaredValuesValidationIDP(1,:) = ProcessIDPResults(HGOConfiguration_2, 1);
RsquaredValuesValidationIDP(2,:) = ProcessIDPResults(LinRebConfiguration_2, 2);
RsquaredValuesValidationIDP(3,:) = ProcessIDPResults(NonLinRebConfiguration_2, 3);

%Create .xlsx-file for results validation IDP
ResultsLabels = {'Rsquared','RsquaredFlex', 'RsquaredExt', 'RsquaredLB', 'RsquaredAR'};
Results = RsquaredValuesValidationIDP;
Results = array2table(Results,'VariableNames',ResultsLabels);
% Write the table to an Excel file
excelFileName = fullfile('.', 'ExcelFiles', 'Validation', ['CalibratedModelsValidationIDP', '.xlsx']);
writetable(Results, excelFileName, 'Sheet', 'Sheet1', 'WriteVariableNames', true);

% compare the IDP-results of the different models
CompareValidationIDPResults;

%% validation using ROM-data from Jaramillo et al.
% run & evaluate simulations with final ROM data from Jaramillo et al.
RsquaredValuesValidationROMJaramillo = zeros(3,5);
TimeValuesValidation = zeros(3,4);
[RsquaredValuesValidationROMJaramillo(1,:), TimeValuesValidation(1,:)] = ProcessValidationConfigurationROM(HGOConfiguration_2, 1);
[RsquaredValuesValidationROMJaramillo(2,:), TimeValuesValidation(2,:)] = ProcessValidationConfigurationROM(LinRebConfiguration_2, 2);
[RsquaredValuesValidationROMJaramillo(3,:), TimeValuesValidation(3,:)] = ProcessValidationConfigurationROM(NonLinRebConfiguration_2, 3);

%Create .xlsx-file for results validation IDP
ResultsLabels = {'Rsquared','RsquaredFlex', 'RsquaredExt', 'RsquaredLB', 'RsquaredAR','TimeFlex','TimeExt','TimeLB','TimeAR'};
Results = [RsquaredValuesValidationROMJaramillo, TimeValuesValidation];
Results = array2table(Results,'VariableNames',ResultsLabels);
% Write the table to an Excel file
excelFileName = fullfile('.', 'ExcelFiles',  'Validation', ['CalibratedModelsValidationROM', '.xlsx']);
writetable(Results, excelFileName, 'Sheet', 'Sheet1', 'WriteVariableNames', true);

% compare the IDP-results of the different models
CompareValidationROMResults;
