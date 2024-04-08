function RsquaredValues = ProcessIDPResults(MatConfiguration, Modeltype)

    % Select list of parameter-labels based on the modeltype
    if Modeltype == 1 % HGO
        ParameterLabels = {'C10Nucleus', 'C01Nucleus', 'C10AnnulusHGO', 'K1Annulus', 'K2Annulus', 'Kappa', 'K1Circ', 'K2Circ',...
            'K1Rad', 'K2Rad', 'FiberAngle', 'FiberAngleCirc', 'FiberAngleRad'};
    elseif Modeltype == 2 % LinRebar
        ParameterLabels = {'C10Nucleus', 'C01Nucleus', 'C10Annulus', 'C01Annulus', 'Lambda', 'LambdaCirc', 'LambdaRad', 'FiberPoissonRate',...
            'FiberAngle', 'FiberAngleCirc', 'FiberAngleRad'};
    else % NonlinRebar
        ParameterLabels = {'C10Nucleus', 'C01Nucleus', 'C10Annulus', 'C01Annulus', 'Lambda', 'LambdaCirc', 'LambdaRad', 'FiberPoissonRate',...
            'FiberAngle', 'FiberAngleCirc', 'FiberAngleRad'};
    end

    % Loading experimental data
    fid=fopen('./ExperimentalData/ExperimentalResultsHeuerIVDL4L5IDPMinMax_7-5Nm.txt');
    ExpResultsData=textscan(fid,'%f%f%f%f%f%f%f%f%f%f%f%f%f','headerlines',2);
    fclose(fid);
    % Organizing the experimental results
    ExpResults.Moment = ExpResultsData(1);
    ExpResultsMedian.Moment= ExpResultsData(1);
    ExpResults.FlexionMedian = ExpResultsData(2);
    ExpResultsMedian.Flexion = ExpResultsData(2);
    ExpResults.FlexionMin = ExpResultsData(3);
    ExpResults.FlexionMax = ExpResultsData(4);
    
    ExpResults.ExtensionMedian = ExpResultsData(5);
    ExpResultsMedian.Extension = ExpResultsData(5);
    ExpResults.ExtensionMin = ExpResultsData(6);
    ExpResults.ExtensionMax = ExpResultsData(7);
    
    ExpResults.LateralBendingMedian = ExpResultsData(8);
    ExpResultsMedian.LateralBending = ExpResultsData(8);
    ExpResults.LateralBendingMin = ExpResultsData(9);
    ExpResults.LateralBendingMax = ExpResultsData(10);
    
    ExpResults.AxialRotationMedian = ExpResultsData(11);
    ExpResultsMedian.AxialRotation = ExpResultsData(11);
    ExpResults.AxialRotationMin = ExpResultsData(12);
    ExpResults.AxialRotationMax = ExpResultsData(13);

    % Obtain the vector moment
    Moment=ExpResults.Moment{1,1};

    ModelNames = {'HGO','LinRebar', 'NonlinRebar'};
    LoadNames = {'Flexion', 'Extension', 'LateralBending', 'AxialRotation'};
    NumResults_temp = struct(); % Initialize struct to store results
        
    % Optional: process IDP-results
    % ProcessSimulationsIDP(ModelNames{Modeltype}, LoadNames);   

    % Read the rpt files for Flexion, Extension, Axial Rotation, and Lateral Bending
    for j = 1:length(LoadNames)
        LoadName = LoadNames{j};
        rptFileName = fullfile('.', 'ResultsFiles', ['AbaqusResults', ModelNames{Modeltype}, LoadName, 'IDP.rpt']);
        fid = fopen(rptFileName);
        NumResults_temp.(strcat(LoadName, 'IDP')) = textscan(fid, '%f%f', 'headerlines', 2);
        fclose(fid);
    end
    NumResults = ProcessNumResults(NumResults_temp,Moment);
    RsquaredValues = CalculateRSquared(NumResults,ExpResultsMedian);    
    
    %% Plot ROM-moment curves for different loading directions
    fig = figure('position', [0, 0, 800, 500]);
    
    % Flexion
    subplot(2,3,1);
    h1 = plot(Moment, NumResults(:,1), Moment, ExpResults.FlexionMedian{1,1}, 'LineWidth', 2);
    hold on;
    errorbar(Moment,ExpResults.FlexionMedian{1,1},min(ExpResults.FlexionMin{1,1},ExpResults.ExtensionMedian{1,1}),...
        ExpResults.FlexionMax{1,1}, 'Color', 'red');
    hold off;
    title('Flexion');
    ylabel('IDP (MPa)');
    xlabel('Moment (Nm)');
    n = round((max(Moment) + abs(min(Moment))) / 2.5) + 1;
    xlim([min(Moment) max(Moment)]);
    xticks(linspace(min(Moment), max(Moment), n));
    
    % Extension
    subplot(2,3,4);
    plot(Moment, NumResults(:,2), Moment, ExpResults.ExtensionMedian{1,1}, 'LineWidth', 2);
    hold on;
    errorbar(Moment,ExpResults.ExtensionMedian{1,1},min(ExpResults.ExtensionMin{1,1},ExpResults.ExtensionMedian{1,1}),...
        ExpResults.ExtensionMax{1,1}, 'Color', 'red');
    hold off;
    title('Extension');
    ylabel('IDP (MPa)');
    xlabel('Moment (Nm)');
    n = round((max(Moment) + abs(min(Moment))) / 2.5) + 1;
    xlim([min(Moment) max(Moment)]);
    xticks(linspace(min(Moment), max(Moment), n));    

    % LateralBending
    subplot(2,3,2);
    plot(Moment, NumResults(:,3), Moment, ExpResults.LateralBendingMedian{1,1}, 'LineWidth', 2);
    hold on;
    errorbar(Moment,ExpResults.LateralBendingMedian{1,1},min(ExpResults.LateralBendingMin{1,1},ExpResults.LateralBendingMedian{1,1}),...
        ExpResults.LateralBendingMax{1,1}, 'Color', 'red');
    hold off;
    title('Lateral Bending');
    ylabel('IDP (MPa)');
    xlabel('Moment (Nm)');
    n = round((max(Moment) + abs(min(Moment))) / 2.5) + 1;
    xlim([min(Moment) max(Moment)]);
    xticks(linspace(min(Moment), max(Moment), n));
    
    % AxialRotation
    subplot(2,3,5);
    plot(Moment, NumResults(:,4), Moment, ExpResults.AxialRotationMedian{1,1}, 'LineWidth', 2);
    hold on;
    errorbar(Moment,ExpResults.AxialRotationMedian{1,1},min(ExpResults.AxialRotationMin{1,1},ExpResults.AxialRotationMedian{1,1}),...
        ExpResults.AxialRotationMax{1,1}, 'Color', 'red');
    hold off;
    title('Axial Rotation');
    ylabel('IDP (MPa)');
    xlabel('Moment (Nm)');
    n = round((max(Moment) + abs(min(Moment))) / 2.5) + 1;
    xlim([min(Moment) max(Moment)]);
    xticks(linspace(min(Moment), max(Moment), n)); 
    
    % Construct a legend with the data from the subplots
    legendLocation = 'northwest';
    legendStrings = {'Num.','Exp.'};
    legend(h1, legendStrings, 'Location', legendLocation);

    % Create a string cell array for annotation-parameters
    annotationStrings = cell(numel(ParameterLabels), 1);
    for p = 1:numel(ParameterLabels)
        annotationStrings{p} = [ParameterLabels{p} ':'];
    end
    
    % Annotate model name
    annotation('textbox',[.65 .8 .13 .2],'String', {'Model: '}, 'FontSize', 14,'FontWeight','bold','EdgeColor','none');
    annotation('textbox',[.75 .8 .13 .2],'String', ModelNames{Modeltype}, 'FontSize', 14,'FontWeight','bold','EdgeColor','none');
    % Annotate Rsquared values
    annotation('textbox',[.65 .7 .13 .2],'String',{'R²: ';'R²-flex: ';'R²-ext: ';'R²-LB: ';'R²-AR: '},'EdgeColor','none');
    annotation('textbox',[.8 .7 .35 .2],'String',{num2str(round(RsquaredValues(1),2));num2str(round(RsquaredValues(2),2));...
        num2str(round(RsquaredValues(3),2));num2str(round(RsquaredValues(4),2));num2str(round(RsquaredValues(5),2))},'EdgeColor','none');
    % Annotate Parameter Labels and MatConfiguration
    annotation('textbox',[.65 .5 .1 .2],'String',annotationStrings,'EdgeColor','none');
    annotation('textbox',[.8 .5 .1 .2],'String',num2str(MatConfiguration),'EdgeColor','none');
    
    % Save the figure
    figName = fullfile(pwd, '.', 'ResultsGraphs', 'Validation', ['Configuration', ModelNames{Modeltype}, 'ValidationIDP.png']);
    saveas(fig, figName);
    close all;
end 