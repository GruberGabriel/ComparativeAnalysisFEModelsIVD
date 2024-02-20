function [Rsquared, Rsquared_Flex, Rsquared_Ext, Rsquared_LB, Rsquared_AR]=EvaluateObjectiveFunctionCalibration(NumResults_temp,ExpResults,i,l,Chromosomes, ParameterLabels, Modelname, Step)
    
    % Obtain the vector moment
    Moment=ExpResults.Moment{1,1};

    % Get numerical Results & Rsquared Values
    NumResults = ProcessNumResults(NumResults_temp,Moment);
    RsquaredValues = CalculateRSquared(NumResults,ExpResults);
    Rsquared = RsquaredValues(1);
    Rsquared_Flex = RsquaredValues(2);
    Rsquared_Ext = RsquaredValues(3);
    Rsquared_LB = RsquaredValues(4);
    Rsquared_AR = RsquaredValues(5);
        
    %% Plot ROM-moment curves for different loading directions
    fig = figure('position', [0, 0, 800, 500]);
    % Flexion
    subplot(2,3,1)
    h1=plot(Moment,NumResults(:,1),Moment,ExpResults.Flexion{1,1});
    title('Flexion');
    ylabel('Range of Motion (deg.)');
    xlabel('Moment (Nm)');
    xlim([0 max(Moment)]);
    % Extension
    subplot(2,3,2);
    plot(Moment,NumResults(:,2),Moment,ExpResults.Extension{1,1});
    title('Extension');
    ylabel('Range of Motion (deg.)');
    xlabel('Moment (Nm)');
    xlim([0 max(Moment)]);
    subplot(2,3,4);
    % LateralBending
    plot(Moment,NumResults(:,3),Moment,ExpResults.LateralBending{1,1});
    title('Lateral Bending');
    ylabel('Range of Motion (deg.)');
    xlabel('Moment (Nm)');
    xlim([0 max(Moment)]);
    % AxialRotation
    subplot(2,3,5);
    plot(Moment,NumResults(:,4),Moment,ExpResults.AxialRotation{1,1})
    title('Axial Rotation');
    ylabel('Range of Motion (deg.)');
    xlabel('Moment (Nm)');
    xlim([0 max(Moment)]);

    % Construct a legend with the data from the subplots
    hL = legend(h1,{'Num.','Exp.'});
    % Programatically move the legend
    newPosition = [0.71 0.05 0.15 0.1];
    newUnits = 'normalized';
    set(hL,'Position', newPosition,'Units', newUnits);

    % Create a string cell array for annotation-parameters
    annotationStrings = cell(numel(ParameterLabels), 1);
    for p = 1:numel(ParameterLabels)
        annotationStrings{p} = [ParameterLabels{p} ':'];
    end
    annotation('textbox',[.65 .7 .13 .2],'String',{'R²: ';'R²-flex: ';'R²-ext: ';'R²-LB: ';'R²-AR: '},'EdgeColor','none');
    annotation('textbox',[.8 .7 .35 .2],'String',{num2str(round(Rsquared,2));num2str(round(Rsquared_Flex,2));num2str(round(Rsquared_Ext,2));...
        num2str(round(Rsquared_LB,2));num2str(round(Rsquared_AR,2))},'EdgeColor','none');
    annotation('textbox',[.65 .5 .1 .2],'String',annotationStrings,'EdgeColor','none');
    annotation('textbox',[.8 .5 .1 .2],'String',num2str(round(Chromosomes(i,:),2)),'EdgeColor','none');
    figName = fullfile(pwd, '.', 'ResultsGraphs', 'Calibration', Modelname,  ['Step', num2str(Step), 'Generation', num2str(l), 'Individual', num2str(i), '.png']);
    saveas(fig, figName);
    close all;
end