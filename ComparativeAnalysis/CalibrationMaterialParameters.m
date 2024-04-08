function [BestRsquared, FinalConfiguration] = CalibrationMaterialParameters(Modeltype, StartConfiguration, MaxNGenerations, Npop, Tol, CalParameters, Step)

    % Breakpoint if there is an error
    dbstop if error;

    % Select list of parameter-labels based on the modeltype
    if Modeltype == 1 % HGO
        ParameterLabels_0 = {'C10Nucleus', 'C01Nucleus', 'C10AnnulusHGO', 'K1Annulus', 'K2Annulus', 'Kappa', 'K1Circ', 'K2Circ',...
            'K1Rad', 'K2Rad', 'FiberAngle', 'FiberAngleCirc', 'FiberAngleRad'};
        InputFile_0 = 'JobHGO.inp';
        Modelname = 'HGO';
    elseif Modeltype == 2 % LinRebar
        ParameterLabels_0 = {'C10Nucleus', 'C01Nucleus', 'C10Annulus', 'C01Annulus', 'Lambda', 'LambdaCirc', 'LambdaRad', 'FiberPoissonRate',...
            'FiberAngle', 'FiberAngleCirc', 'FiberAngleRad'};
        InputFile_0 = 'JobLinRebar.inp';
        Modelname = 'LinRebar';
    else % NonlinRebar
        ParameterLabels_0 = {'C10Nucleus', 'C01Nucleus', 'C10Annulus', 'C01Annulus', 'Lambda', 'LambdaCirc', 'LambdaRad', 'FiberPoissonRate',...
            'FiberAngle', 'FiberAngleCirc', 'FiberAngleRad'};
        InputFile_0 = 'JobNonlinRebar.inp';
        Modelname = 'NonlinRebar';
    end
         
    ParameterLabels = ParameterLabels_0(CalParameters);

    % Get the ranges (upper and lower limit) for the different parameters
    ParameterRanges = cellfun(@GetParameterRanges, ParameterLabels, 'UniformOutput', false);
    % Initialize an empty matrix for bounds
    Bounds = zeros(2, length(ParameterRanges));    
    % Loop through each entry in ParameterRanges
    for i = 1:length(ParameterRanges)
        % Append each parameter range to the Bounds matrix
        Bounds(:,i) = ParameterRanges{i};
    end
    
    % Get fixed values for the remaining parameters
    FixedParameterValues = zeros(1,length(ParameterLabels_0));
    for i = 1:length(ParameterLabels_0)
        param = ParameterLabels_0{i};        
        % Check if the parameter is not in ParameterLabels
        if ~ismember(param, ParameterLabels)
            if ~isempty(StartConfiguration) && StartConfiguration(i) ~= 0
                % If parameter is in StartConfiguration, use that value
                FixedParameterValues(i) = StartConfiguration(i);
            else
                % Otherwise, use the median of the range from getParameterRanges
                range = GetParameterRanges(param);
                FixedParameterValues(i) = median(range);
            end
        end
    end

    % GA settings    
    %-- Number of individuals selected in the population and kept for the next generation
    NSelection=6/20 * Npop;
    if mod(NSelection,2) ~= 0
        NSelection = NSelection +1;
    end
    %-- Number of individuals that will be created after crossover
    NCrossover=4/20 * Npop;
    %-- Number of individuals that will be created after mutation
    NMutation = (Npop <= 10) * NSelection + (Npop > 10) * 4/20 * Npop;
    %-- Number of individuals that will migrate
    NImmigration=Npop-NSelection-NCrossover-NMutation;
    
    % Loading experimental data
    fid=fopen('./ExperimentalData/ExperimentalResultsHeuerIVDROM_7-5Nm.txt');
    ExpResultsData=textscan(fid,'%f%f%f%f%f','headerlines',2);
    fclose(fid);

    % Organizing the experimental results
    ExpResults.Moment=ExpResultsData(1);
    ExpResults.Flexion=ExpResultsData(2);
    ExpResults.Extension=ExpResultsData(3);
    ExpResults.LateralBending=ExpResultsData(4);
    ExpResults.AxialRotation=ExpResultsData(5);
    
    % Obtain max. moment to adapt .inp-file
    MaxMoment = max(cell2mat(ExpResults.Moment));
    
    LoadNames = {'Flexion', 'Extension', 'LateralBending', 'AxialRotation'};
    LoadAxis = [4, 4, 6, 5];
    for j = 1:length(LoadNames)        
        InputFile_1 = ['Job', Modelname, LoadNames{j}, '.inp'];
        MomentValue = (strcmp(LoadNames{j}, 'Extension') * -1 + ~strcmp(LoadNames{j}, 'Extension')) * MaxMoment * 1000;
        ModifyLoad(InputFile_0, InputFile_1, LoadAxis(j), MomentValue);
    end 
    
    % Creating a random initial population
    Chromosomes=zeros(Npop,size(Bounds,2));
    for h=1:size(Bounds,2)
        Chromosomes(1:end,h)=Bounds(1,h)+rand(1,Npop)*(Bounds(2,h)-Bounds(1,h));        
    end

    % Create the format string
    numFs = numel(CalParameters); 
    c = repmat('%f,', 1, numFs); % Repeat '%f,' numFs times
    c = c(1:end-1); % Remove the trailing comma

    % Obtaining the results of the previous simulations if requested
    if exist('./Chromosomes/StartingChromosomes.txt','file')
        fid=fopen('./Chromosomes/StartingChromosomes.txt');
        StartingChromosomes=textscan(fid,c,'headerlines',1); 
        fclose(fid);
        StartingChromosomes = cell2mat(StartingChromosomes);
        Chromosomes(1:size(StartingChromosomes,1),1:size(StartingChromosomes,2))= StartingChromosomes;    
    end   
    % Initialize structure for numerical results
    NumResults = struct();

    % Starting the generation loop
    for l=1:MaxNGenerations        
        % Write a table with the chromosomes
        Table = array2table(Chromosomes,'VariableNames',ParameterLabels);
        chromosomesFileName = fullfile('.', 'Chromosomes', ['MaterialChromosomes', Modelname,'_Step_', num2str(Step), '_Generation_', num2str(l), '.txt']);
        writetable(Table, chromosomesFileName);        
        % Deciding if we are working with the initial generation --> adjust
        % start of inner-loop
        if l==1 
            j=1;
        else
            j=NSelection+1;
        end
    
        for i=j:Npop   
            % Define properties-vector based on chromosomes
            x = FixedParameterValues;
            x(:, CalParameters) = Chromosomes(i, :);
            % Update mechanical properties
            UpdatePropertiesIVD(Modeltype, x);             
            % Run jobs for different loading directions & Generate the rpt files
            RunProcessSimulations(Modelname, LoadNames, 0);
            % Read the rpt files for each loading direction
            for k = 1:length(LoadNames)
                LoadName = LoadNames{k};
                rptFileName = fullfile('.', 'ResultsFiles', ['AbaqusResults', Modelname, LoadName, 'ROM.rpt']);
                fid = fopen(rptFileName);
                NumResults.(LoadName) = textscan(fid, '%f%f%f%f', 'HeaderLines', 2);
                fclose(fid);
            end
            % Evaluating the fitness score of the created individuals
            [Rsquared, Rsquared_Flex, Rsquared_Ext, Rsquared_LB, Rsquared_AR]=EvaluateObjectiveFunctionCalibration(NumResults,ExpResults,i,l,...
                Chromosomes, ParameterLabels, Modelname, Step);
            % Save the results
            clear NumResults;
            RSquaredScoreData(i,:)=[Rsquared, Rsquared_Flex, Rsquared_Ext, Rsquared_LB, Rsquared_AR, l,i];
        end        
        % Present the fitness score and the characteristics of the actual generation
        if l==1 
            ResultsOne(1:Npop,:)=[RSquaredScoreData,Chromosomes];
        else
            ResultsOne(Npop+(Npop-NSelection)*(l-2)+1:Npop+(Npop-NSelection)*(l-1),:)=[RSquaredScoreData(NSelection+1:end,:),Chromosomes(NSelection+1:end,:)];
        end        
       % Rank the individuals based on their fitness score
        [~, idx] = sort(ResultsOne(:, 1), 'descend');
        RankedResults = ResultsOne(idx, :);
        % Create Labels for .xlsx-file
        ParameterLabels_Results = {'Rsquared', 'RsquaredFlex', 'RsquaredExt', 'RsquaredLB', 'RsquaredAR', 'Generation', 'Individual'};
        ParameterLabels_Results = cat(2, ParameterLabels_Results, ParameterLabels);                
        disp('The ranked results are shown in the following table');
        Results = array2table(RankedResults,'VariableNames',ParameterLabels_Results);        
        % Write the table to an Excel file
        excelFileName = fullfile('.', 'ExcelFiles', 'Calibration', ['MaterialCalibration', Modelname,'Step', num2str(Step), 'Generation', num2str(l), '.xlsx']);
        writetable(Results, excelFileName, 'Sheet', 'Sheet1', 'WriteVariableNames', true);    
        % Select the best chromosome
        Best_chromosome = RankedResults(1,:);       
        % select return variables
        BestRsquared = RankedResults(1,1);
        FinalConfiguration = FixedParameterValues;
        FinalConfiguration(:, CalParameters) = Best_chromosome(8:end);                
        % Check GA convergence
        if round(BestRsquared,2)>=Tol
            disp('Your simulation has converged.');
            return;
        end        
        if MaxNGenerations > 1
            %% Creating a new population
            % Selecting the best parents for the next generation
            SelectedChromosomes = RankedResults(1:NSelection, 8:end); % Select chromosome-values
            % Crossover
            CrossedChrom = Crossover(SelectedChromosomes(1:NCrossover, :), Bounds, NCrossover); 
            % Mutation
            MutatedChrom = Mutation(SelectedChromosomes(1:NMutation, :), Bounds);
            % Immigration
            ImmigratedChrom = Immigration(NImmigration, Bounds);
            % Update the Chromosomes matrix by writing the new individuals
            Chromosomes = [SelectedChromosomes; CrossedChrom; MutatedChrom; ImmigratedChrom];            
            % Write a table with the chromosomes
            Table = array2table(Chromosomes,'VariableNames',ParameterLabels);
            chromosomesFileName = fullfile('.', 'Chromosomes', ['MaterialChromosomes', Modelname,'_Step_', num2str(Step), '_Generation_', num2str(l+1), '.txt']);
            writetable(Table, chromosomesFileName);
        end
    end
end