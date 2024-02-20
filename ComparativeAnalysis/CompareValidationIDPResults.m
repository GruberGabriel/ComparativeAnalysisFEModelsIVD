function CompareValidationIDPResults()

    % Loading experimental data    
    fid=fopen('./ExperimentalData/ExperimentalResultsHeuerIVDL4L5IDPMinMax_7-5Nm.txt');
    ExpResultsData=textscan(fid,'%f%f%f%f%f%f%f%f%f%f%f%f%f','headerlines',2);
    fclose(fid);
    % Organizing the experimental results
    ExpResults.Moment = ExpResultsData(1);
    ExpResults.FlexionMedian = ExpResultsData(2);
    ExpResults.FlexionMin = ExpResultsData(3);
    ExpResults.FlexionMax = ExpResultsData(4);
    
    ExpResults.ExtensionMedian = ExpResultsData(5);
    ExpResults.ExtensionMin = ExpResultsData(6);
    ExpResults.ExtensionMax = ExpResultsData(7);
    
    ExpResults.LateralBendingMedian = ExpResultsData(8);
    ExpResults.LateralBendingMin = ExpResultsData(9);
    ExpResults.LateralBendingMax = ExpResultsData(10);
    
    ExpResults.AxialRotationMedian = ExpResultsData(11);
    ExpResults.AxialRotationMin = ExpResultsData(12);
    ExpResults.AxialRotationMax = ExpResultsData(13);

    % Obtain the vector moment
    Moment=ExpResults.Moment{1,1};

    ModelNames = {'HGO', 'LinRebar', 'NonlinRebar'};
    LoadNames = {'Flexion', 'Extension', 'LateralBending', 'AxialRotation'};
    NumResults_temp = struct(); % Initialize struct to store results
    NumResults = cell(1, length(ModelNames));
    
    for i = 1:length(ModelNames)
        % Read the rpt files for Flexion, Extension, Axial Rotation, and Lateral Bending
        for j=1:length(LoadNames)
            LoadName = LoadNames{j};
            rptFileName = fullfile('.', 'ResultsFiles',  ['AbaqusResults', ModelNames{i}, LoadName, 'IDP.rpt']);
            fid = fopen(rptFileName);
            NumResults_temp.(strcat(LoadName, 'IDP')) = textscan(fid, '%f%f', 'headerlines', 2);
            fclose(fid);
        end
        NumResults{i} = ProcessNumResults(NumResults_temp,Moment);        
    end

    %% Plot ROM-moment curves for different loading directions
    lineStyles = {'-.', '--', ':'}; % Define linestyles
    lineColors = {'black', '#EE0000' ,'#00CD00', '#0000FF'}; % Define line colors: dark-red, dark-green, blue
    FontSizeTitle = 14;
    FontSizeAxLabel = 12;
    FontSizeLegend = 10;
    FontSizeTicks = 10;

    % Plot ROM-moment curves for different loading directions
    fig = figure('position', [0, 0, 800, 500]);

    % Flexion subplot
    subplot(2,2,1);
    h1 = plot(Moment, ExpResults.FlexionMedian{1,1}, 'LineWidth', 2,'Color', lineColors{1});
    hold on;
    % Create an array to store handles for legend
    legendHandles = h1;
    for i=1:length(ModelNames)
        h = plot(Moment, NumResults{i}(:,1), 'LineWidth', 2,'LineStyle', lineStyles{i}, 'Color', lineColors{i+1});
        legendHandles = [legendHandles, h];
        hold on;
    end
    errorbar(Moment,ExpResults.FlexionMedian{1,1},min(ExpResults.FlexionMin{1,1},ExpResults.ExtensionMedian{1,1}-0.01),...
        ExpResults.FlexionMax{1,1}, 'LineWidth', 1,'Color', lineColors{1});
    title('Flexion', 'FontSize',FontSizeTitle);
    n = round((max(Moment) + abs(min(Moment))) / 2.5) + 1;
    xlim([min(Moment) max(Moment)]);
    ylim([0 0.6]);
    xticks(linspace(min(Moment), max(Moment), n));
    ax = gca;
    ax.XAxis.FontSize = FontSizeTicks; 
    ax.YAxis.FontSize = FontSizeTicks; 
    ylabel('IDP (MPa)','FontSize',FontSizeAxLabel); % axis-labels after ticks to change the FontSize
    xlabel('Moment (Nm)','FontSize',FontSizeAxLabel);
    hold off;
    
    % Extension subplot
    subplot(2,2,3);
    plot(Moment, ExpResults.ExtensionMedian{1,1}, 'LineWidth', 2,'Color', lineColors{1});
    hold on;
    for i=1:length(ModelNames)
        plot(Moment, NumResults{i}(:,2), 'LineWidth', 2,'LineStyle', lineStyles{i}, 'Color', lineColors{i+1});
        hold on;
    end
    errorbar(Moment,ExpResults.ExtensionMedian{1,1},min(ExpResults.ExtensionMin{1,1},ExpResults.ExtensionMedian{1,1}),...
        ExpResults.ExtensionMax{1,1}, 'LineWidth', 1, 'Color', lineColors{1});
    title('Extension', 'FontSize',FontSizeTitle);
    xlim([min(Moment) max(Moment)]);
    n = round((max(Moment) + abs(min(Moment))) / 2.5) + 1;
    xticks(linspace(min(Moment), max(Moment), n));
    ax = gca;
    ax.XAxis.FontSize = FontSizeTicks; 
    ax.YAxis.FontSize = FontSizeTicks; 
    ylabel('IDP (MPa)','FontSize',FontSizeAxLabel);
    xlabel('Moment (Nm)','FontSize',FontSizeAxLabel);
    hold off;    

    % LateralBending subplot
    subplot(2,2,2);
    plot(Moment, ExpResults.LateralBendingMedian{1,1}, 'LineWidth', 2,'Color', lineColors{1});
    hold on;
    for i=1:length(ModelNames)
        plot(Moment, NumResults{i}(:,3), 'LineWidth', 2,'LineStyle', lineStyles{i}, 'Color', lineColors{i+1});
        hold on;
    end
    errorbar(Moment,ExpResults.LateralBendingMedian{1,1},min(ExpResults.LateralBendingMin{1,1},ExpResults.LateralBendingMedian{1,1}),...
        ExpResults.LateralBendingMax{1,1}, 'LineWidth', 1, 'Color', lineColors{1});
    title('Lateral Bending', 'FontSize',FontSizeTitle);
    xlim([min(Moment) max(Moment)]);
    ylim([0 0.4]);
    n = round((max(Moment) + abs(min(Moment))) / 2.5) + 1;
    xticks(linspace(min(Moment), max(Moment), n));
    ax = gca;
    ax.XAxis.FontSize = FontSizeTicks; 
    ax.YAxis.FontSize = FontSizeTicks; 
    ylabel('IDP (MPa)','FontSize',FontSizeAxLabel);
    xlabel('Moment (Nm)','FontSize',FontSizeAxLabel);
    hold off;  

    % AxialRotation subplot
    subplot(2,2,4);
    plot(Moment, ExpResults.AxialRotationMedian{1,1}, 'LineWidth', 2,'Color', lineColors{1});
    hold on;
    for i=1:length(ModelNames)
        plot(Moment, NumResults{i}(:,4), 'LineWidth', 2,'LineStyle', lineStyles{i}, 'Color', lineColors{i+1});
        hold on;
    end
    errorbar(Moment,ExpResults.AxialRotationMedian{1,1},min(ExpResults.AxialRotationMin{1,1},ExpResults.AxialRotationMedian{1,1}),...
        ExpResults.AxialRotationMax{1,1}, 'LineWidth', 1, 'Color', lineColors{1});
    title('Axial Rotation', 'FontSize',FontSizeTitle);
    xlim([min(Moment) max(Moment)]);
    n = round((max(Moment) + abs(min(Moment))) / 2.5) + 1;
    xticks(linspace(min(Moment), max(Moment), n));
    ax = gca;
    ax.XAxis.FontSize = FontSizeTicks; 
    ax.YAxis.FontSize = FontSizeTicks; 
    ylabel('IDP (MPa)','FontSize',FontSizeAxLabel);
    xlabel('Moment (Nm)','FontSize',FontSizeAxLabel);
    hold off;  
    
    % Construct a legend with the data from the subplots
    legendLocation = 'northwest';
    LegendStrings = 'Exp. (w Min&Max)';
    ModelNamesLegend = {'HGO', 'lin. Rebar', 'nonlin. Rebar'};
    LegendStrings = cat(2, LegendStrings, ModelNamesLegend );
    legend(legendHandles, LegendStrings, 'Location', legendLocation,'FontSize',FontSizeLegend);
   
    % Save the figure
    figName = fullfile(pwd, '.', 'ResultsGraphs',  'Validation', ['ValidationIDPModelComparison', '.png']);
    saveas(fig, figName);
    close all;
end