function [RsquaredValues,TimeValues] = ProcessValidationConfigurationROM(MatConfiguration, Modeltype)
    
    % Breakpoint if there is an error
    dbstop if error;
    
    % Select list of parameter-labels based on the modeltype
    if Modeltype == 1 % HGO
        ParameterLabels = {'C10Nucleus', 'C01Nucleus', 'C10AnnulusHGO', 'K1Annulus', 'K2Annulus', 'Kappa', 'K1Circ', 'K2Circ',...
            'K1Rad', 'K2Rad', 'FiberAngle', 'FiberAngleCirc', 'FiberAngleRad'};
        InputFile_0 = 'JobHGO.inp';
        Modelname = 'HGO';
    elseif Modeltype == 2 % LinRebar
        ParameterLabels = {'C10Nucleus', 'C01Nucleus', 'C10Annulus', 'C01Annulus', 'Lambda', 'LambdaCirc', 'LambdaRad', 'FiberPoissonRate',...
            'FiberAngle', 'FiberAngleCirc', 'FiberAngleRad'};
        InputFile_0 = 'JobLinRebar.inp';
        Modelname = 'LinRebar';
    else % NonlinRebar
        ParameterLabels = {'C10Nucleus', 'C01Nucleus', 'C10Annulus', 'C01Annulus', 'Lambda', 'LambdaCirc', 'LambdaRad', 'FiberPoissonRate',...
            'FiberAngle', 'FiberAngleCirc', 'FiberAngleRad'};
        InputFile_0 = 'JobNonlinRebar.inp';
        Modelname = 'NonlinRebar';
    end

    UpdatePropertiesIVD(Modeltype, MatConfiguration);  
    
    % Loading experimental data
    fid=fopen('./ExperimentalData/ExperimentalDataJaramilloL4L5_IVD_ROM.txt');
    ExpResultsData=textscan(fid,'%f%f%f%f%f','headerlines',1);
    fclose(fid);
    fid=fopen('./ExperimentalData/ExperimentalDataJaramilloL4L5_IVD_ROM_Std.txt');
    ExpResultsStdData=textscan(fid,'%f%f%f%f%f','headerlines',1);
    fclose(fid);

    % Organizing the experimental results
    % ROM-Median
    ExpResults.Moment=ExpResultsData(1);
    ExpResults.Flexion=ExpResultsData(2);
    ExpResults.Extension=ExpResultsData(3);
    ExpResults.LateralBending=ExpResultsData(4);
    ExpResults.AxialRotation=ExpResultsData(5);
    % ROM-Std
    ExpResultsStd.Flexion = ExpResultsStdData(2);
    ExpResultsStd.Extension = ExpResultsStdData(3);
    ExpResultsStd.LateralBending = ExpResultsStdData(4);
    ExpResultsStd.AxialRotation = ExpResultsStdData(5);
    
    % Obtain max. moment to adapt .inp-file
    MaxMoment = max(cell2mat(ExpResults.Moment));
    
    LoadNames = {'Flexion', 'Extension', 'LateralBending', 'AxialRotation'};
    LoadAxis = [4, 4, 6, 5];
    for j = 1:length(LoadNames)        
        InputFile_1 = ['Job', Modelname, LoadNames{j}, '.inp'];
        MomentValue = (strcmp(LoadNames{j}, 'Extension') * -1 + ~strcmp(LoadNames{j}, 'Extension')) * MaxMoment * 1000;
        ModifyLoad(InputFile_0, InputFile_1, LoadAxis(j), MomentValue);
    end   
    
    % Run Abaqus for different loading directions & Generate the rpt files from Abaqus by running the python macro
    RunProcessSimulations(Modelname, LoadNames, 0);

    % Read the rpt files for Flexion, Extension, Axial Rotation, and Lateral Bending
    for k = 1:length(LoadNames)
        LoadName = LoadNames{k};
        rptFileName = fullfile('.', 'ResultsFiles', ['AbaqusResults', Modelname, LoadName, 'ROM.rpt']);
        fid = fopen(rptFileName);
        NumResults.(LoadName) = textscan(fid, '%f%f%f%f', 'HeaderLines', 2);
        fclose(fid);
    end

    % Evaluating the fitness score of the created individuals
    [Rsquared, Rsquared_Flex, Rsquared_Ext, Rsquared_LB, Rsquared_AR] =...
        EvaluateObjectiveFunctionValidation(NumResults,ExpResults,ParameterLabels,MatConfiguration,Modelname,"Validation",ExpResultsStd);
    RsquaredValues = [Rsquared, Rsquared_Flex, Rsquared_Ext, Rsquared_LB, Rsquared_AR];

    % Copy odb and rpt-files with specific name
    NewFileName(Modelname, 'Validation');

    % Get time values for each load-case
    TimeValues = zeros(1, length(LoadNames));
    for j=1:length(LoadNames) 
        fileID = ['./SimulationFiles/Job', Modelname, cell2mat(LoadNames(j)), '.dat'];
        TimeValues(j) = GetTime(fileID);
    end 
end