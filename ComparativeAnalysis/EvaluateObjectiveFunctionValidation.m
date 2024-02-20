function [Rsquared, Rsquared_Flex, Rsquared_Ext, Rsquared_LB, Rsquared_AR]=EvaluateObjectiveFunctionValidation(NumResults_temp,ExpResults,ParameterLabels,MatConfiguration,Modelname,Section,ExpResultsStd)
    
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
    if Section == "Calibration"
        stepsize = max(Moment)/3; % define stepsize for xticks
        figName = fullfile(pwd, '.', 'ResultsGraphs', 'Calibration', ['Configuration', Modelname, 'Calibration','.png']);
    elseif Section == "Validation"
        stepsize = max(Moment)/4; % define stepsize for xticks
        figName = fullfile(pwd, '.', 'ResultsGraphs', 'Validation', ['Configuration', Modelname, 'ValidationROM','.png']);
    end
    % Plot ROM-moment curves for different loading directions
    fig = figure('position', [0, 0, 800, 500]);
    
    % Combined Flexion and Extension subplot
    subplot(2,3,[1,4]);
    MomentFlexExt = [sort(-Moment); Moment(2:end)];
    ROMFlexExtNum = [sort(-NumResults(:,2)); NumResults(2:end,1)];
    ROMFlexExtExp = [sort(-ExpResults.Extension{1,1}); ExpResults.Flexion{1,1}(2:end)];
    h1 = plot(MomentFlexExt, ROMFlexExtNum, MomentFlexExt, ROMFlexExtExp, 'LineWidth', 2);
    if Section == "Validation"
        hold on;
        errorbar(Moment(2:end),ExpResults.Flexion{1,1}(2:end),ExpResultsStd.Flexion{1,1}(2:end),ExpResultsStd.Flexion{1,1}(2:end), 'Color', 'red');
        hold on;
        errorbar(sort(-Moment(2:end)),sort(-ExpResults.Extension{1,1}(2:end)),ExpResultsStd.Extension{1,1}(2:end),ExpResultsStd.Extension{1,1}(2:end), 'Color', 'red');
        hold off;
    end
    title('Flexion and Extension');
    ylabel('Range of Motion (deg.)');
    xlabel('Moment (Nm)');
    n = round((max(MomentFlexExt) + abs(min(MomentFlexExt))) / stepsize) + 1;
    xlim([min(MomentFlexExt) max(MomentFlexExt)]);
    xticks(linspace(min(MomentFlexExt), max(MomentFlexExt), n));
    
    % Lateral Bending subplot
    subplot(2,3,2);
    plot(Moment, NumResults(:,3),Moment, ExpResults.LateralBending{1,1}, 'LineWidth', 2);
    if Section == "Validation"
        hold on;
        errorbar(Moment(2:end),ExpResults.LateralBending{1,1}(2:end),ExpResultsStd.LateralBending{1,1}(2:end),ExpResultsStd.LateralBending{1,1}(2:end), 'Color', 'red');
        hold off;
    end
    title('Lateral Bending');
    ylabel('Range of Motion (deg.)');
    xlabel('Moment (Nm)');
    xlim([0 max(Moment)]);
    n = round((max(Moment)) / stepsize) + 1;
    xticks(linspace(0, max(Moment), n));
    
    % Axial Rotation subplot
    subplot(2,3,5);
    plot(Moment, NumResults(:,4), Moment, ExpResults.AxialRotation{1,1}, 'LineWidth', 2);
    if Section == "Validation"
        hold on;
        errorbar(Moment(2:end),ExpResults.AxialRotation{1,1}(2:end),ExpResultsStd.AxialRotation{1,1}(2:end),ExpResultsStd.AxialRotation{1,1}(2:end), 'Color', 'red');
        hold off;
    end
    title('Axial Rotation');
    ylabel('Range of Motion (deg.)');
    xlabel('Moment (Nm)');
    xlim([0 max(Moment)]);
    n = round((max(Moment)) / stepsize) + 1;
    xticks(linspace(0, max(Moment), n));
    
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
    annotation('textbox',[.75 .8 .13 .2],'String', Modelname, 'FontSize', 14,'FontWeight','bold','EdgeColor','none');
    % Annotate Rsquared values
    annotation('textbox',[.65 .7 .13 .2],'String',{'R²: ';'R²-flex: ';'R²-ext: ';'R²-LB: ';'R²-AR: '},'EdgeColor','none');
    annotation('textbox',[.8 .7 .35 .2],'String',{num2str(round(Rsquared,2));num2str(round(Rsquared_Flex,2));num2str(round(Rsquared_Ext,2));...
        num2str(round(Rsquared_LB,2));num2str(round(Rsquared_AR,2))},'EdgeColor','none');
    % Annotate Parameter Labels and MatConfiguration
    annotation('textbox',[.65 .5 .1 .2],'String',annotationStrings,'EdgeColor','none');
    annotation('textbox',[.8 .5 .1 .2],'String',num2str(round(MatConfiguration,2)),'EdgeColor','none');
    
    % Save the figure
    saveas(fig, figName);
    close all;
end