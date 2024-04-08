function ToBeCalibrated = SensitivityAnalysis(Modeltype, SensitivityLimit)

    % Sets a breakpoint if there is an error
    dbstop if error;
    
    % Select list of parameter-labels based on the modeltype
    if Modeltype == 1 % HGO
        ParameterLabels = {'C10Nucleus','C01Nucleus','C10AnnulusHGO','K1Annulus','K2Annulus','Kappa',...
            'K1Circ','K2Circ','K1Rad','K2Rad','FiberAngle','FiberAngleCirc','FiberAngleRad'};
        InputFile_0 = 'JobHGO.inp';
        Modelname = 'HGO';
    else % Rebar
        ParameterLabels = {'C10Nucleus','C01Nucleus','C10Annulus','C01Annulus','Lambda','LambdaCirc',...
            'LambdaRad','FiberPoissonRate' ,'FiberAngle','FiberAngleCirc','FiberAngleRad'};
        InputFile_0 = 'JobLinRebar.inp';
        Modelname = 'LinRebar';
    end
    
    % Define Material-Parameters
    NVariations = 4; % define number of variations for each parameter
    RangeWidth = 0.5; % define outermost scaling-factor for parameter-variations
    MatParameters = arrayfun(@(x) CalculateMaterialParameters(ParameterLabels{x}, NVariations, RangeWidth), 1:numel(ParameterLabels), 'UniformOutput', false);
    MatParameters = vertcat(MatParameters{:});

    % Initialize arrays for ROM and IDP results
    ROMFlexion = zeros(numel(ParameterLabels), NVariations+1);
    ROMExtension = zeros(numel(ParameterLabels), NVariations+1);
    ROMLateralBending = zeros(numel(ParameterLabels), NVariations+1);
    ROMAxialRotation = zeros(numel(ParameterLabels), NVariations+1);    
    IDPFlexion = zeros(numel(ParameterLabels), NVariations+1);
    IDPExtension = zeros(numel(ParameterLabels), NVariations+1);
    IDPLateralBending = zeros(numel(ParameterLabels), NVariations+1);
    IDPAxialRotation = zeros(numel(ParameterLabels), NVariations+1);
    
    % Defining the loading
    MaxMoment = 5; % declaration of the moment-loading in Nm    
    LoadNames = {'Flexion', 'Extension', 'LateralBending', 'AxialRotation'};
    LoadAxis = [4, 4, 6, 5];

    for j = 1:length(LoadNames)        
        InputFile_1 = ['Job', Modelname, LoadNames{j}, '.inp'];
        MomentValue = (strcmp(LoadNames{j}, 'Extension') * -1 + ~strcmp(LoadNames{j}, 'Extension')) * MaxMoment * 1000;
        ModifyLoad(InputFile_0, InputFile_1, LoadAxis(j), MomentValue);
    end 
    
    %% Simulate LoadCases with median-configuration
    UpdatePropertiesIVD(Modeltype, MatParameters(:,1));
    ResultsType = {'ROM', 'IDP'};
    RunProcessSimulations(Modelname, LoadNames, 1); % run simulation & process results
    % Read the rpt files that contain the ROM- and IDP-results  
    [NumResultsROM, NumResultsIDP] = ReadResults(Modelname, LoadNames, ResultsType);

    % Evaluating the ROM-data from simulations
    [ROMFlexion(:,1),ROMExtension(:,1),ROMLateralBending(:,1),ROMAxialRotation(:,1)]=EvaluateFunctionSensitivity(NumResultsROM,MaxMoment);
    close all;    
    % Evaluating the IDP-data from simulations
    [IDPFlexion(:,1),IDPExtension(:,1),IDPLateralBending(:,1),IDPAxialRotation(:,1)]=EvaluateFunctionSensitivity(NumResultsIDP,MaxMoment);
    close all;    
    

    %% Starting the simulation & processing loop for max & min parameter-values
    % (OFAT)
    for l=1:size(MatParameters,1)        
        for k=1:size(MatParameters,2)-1                 
            % Define the material configuration by changing the value of the current
            % parameter
            MatConfiguration = MatParameters(:,1);
            MatConfiguration(l) = MatParameters(l,k+1);          
            % Update mechanical properties of the model
            UpdatePropertiesIVD(Modeltype, MatConfiguration);                    
            % Run Abaqus for different loading directions & Generate the rpt files from Abaqus by running the python macro
            LoadNames = {'Flexion', 'Extension', 'LateralBending', 'AxialRotation'};
            RunProcessSimulations(Modelname, LoadNames, 1);    
            % Read the rpt files that contain the ROM-results of Abaqus simulation
            [NumResultsROM, NumResultsIDP] = ReadResults(Modelname, LoadNames, ResultsType);
            % Evaluating the ROM-data from simulations
            [ROMFlexion(l,k+1),ROMExtension(l,k+1),ROMLateralBending(l,k+1),ROMAxialRotation(l,k+1)]=...
                EvaluateFunctionSensitivity(NumResultsROM,MaxMoment);   
            % Evaluating the IDP-data from simulations
            [IDPFlexion(l,k+1),IDPExtension(l,k+1),IDPLateralBending(l,k+1),IDPAxialRotation(l,k+1)]=...
                EvaluateFunctionSensitivity(NumResultsIDP,MaxMoment);
        end       
    end    
    % Write Results-Arrays to Excel files
    for i = 1:length(ResultsType)
        for j = 1:length(LoadNames)
            % Construct the variable name dynamically
            variableName = strcat(ResultsType{i}, LoadNames{j});            
            % Construct the file name dynamically
            FileName = fullfile('.', 'ExcelFiles', 'SensitivityAnalysis', [ Modelname, ResultsType{i}, LoadNames{j}, '.xlsx']);       
            % Write the array to Excel file
            writetable(array2table(eval(variableName)), FileName, 'Sheet', 'Sheet1', 'WriteVariableNames', false);
        end
    end    
    
    %% Results-Analysis
    ResultsType = {'ROM', 'IDP'}; % define types of results -->required for visualization 
    ResultsData = cell(size(LoadNames));
    CalibrationParameters = struct();
    ToBeCalibrated = [];
    
    for i=1:length(ResultsType)
        for j=1:length(LoadNames)
            % Construct the variable name dynamically
            variableName = strcat(ResultsType{i}, LoadNames{j});
            Data = eval(variableName);
            ResultsData{j} = Data;
        end
        CalibrationParameters.(ResultsType{i}) =...
            ResultsAnalysis(Modeltype, ResultsData, MatParameters, LoadNames, ResultsType{i}, SensitivityLimit);
        ToBeCalibrated = [ToBeCalibrated, CalibrationParameters.(ResultsType{i})];
    end
    ToBeCalibrated = sort(unique(ToBeCalibrated),'ascend');    
end

function [NumResultsROM, NumResultsIDP] = ReadResults(Modelname, LoadNames, ResultsType)
    % Read the rpt files that contain the ROM-results of Abaqus simulation    
    for i = 1:length(ResultsType)
        for j = 1:length(LoadNames)
            % Construct the file name dynamically
            rptFileName = fullfile('.', 'ResultsFiles', ['AbaqusResults', Modelname, LoadNames{j}, ResultsType{i}, '.rpt']);
            % Read the rpt file and store results in the structure
            fid = fopen(rptFileName);
            if ResultsType{i} == "IDP"
                NumResultsIDP.(strcat(LoadNames{j}, ResultsType{i})) = textscan(fid, '%f%f', 'headerlines', 2);
            else
                NumResultsROM.(strcat(LoadNames{j}, ResultsType{i})) = textscan(fid, '%f%f%f%f', 'headerlines', 2);
            end
            fclose(fid);
        end
    end   
end

function [Result_Flex,Result_Ext,Result_LB,Result_AR]=EvaluateFunctionSensitivity(NumResults_temp,MaxMoment)
    % Get numerical Results
    Moment = linspace(0,MaxMoment,MaxMoment+1);
    NumResults = ProcessNumResults(NumResults_temp,Moment);        
    % Select the result in the end-position for each loading direction
    Result_Flex = NumResults(end,1);
    Result_Ext = NumResults(end,2);
    Result_LB = NumResults(end,3);
    Result_AR = NumResults(end,4);
end
