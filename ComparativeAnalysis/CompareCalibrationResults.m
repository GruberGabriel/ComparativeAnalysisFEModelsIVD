function CompareCalibrationResults()

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

    % Obtain the vector moment
    Moment=ExpResults.Moment{1,1};

    ModelNames = {'HGO', 'LinRebar', 'NonlinRebar'};
    LoadNames = {'Flexion', 'Extension', 'LateralBending', 'AxialRotation'};
    NumResults_temp = struct(); % Initialize struct to store results
    NumResults = cell(1, length(ModelNames));
    
    % Read and process the rpt files for different loading directions and models
    for i = 1:length(ModelNames)
        % Read the rpt files for each loading direction
        for j = 1:length(LoadNames)
            LoadName = LoadNames{j};
            rptFileName = fullfile('.', 'ResultsFiles', ['AbaqusResults', ModelNames{i}, LoadName, 'ROMCalibration.rpt']);
            fid = fopen(rptFileName);
            NumResults_temp.(LoadName) = textscan(fid, '%f%f%f%f', 'HeaderLines', 2);
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

    % Combined Flexion and Extension subplot
    subplot(2,2,[1,3]);
    MomentFlexExt = [sort(-Moment); Moment(2:end)];
    ROMFlexExtExp = [sort(-ExpResults.Extension{1,1}); ExpResults.Flexion{1,1}(2:end)];
    h1 = plot(MomentFlexExt, ROMFlexExtExp, 'LineWidth', 2,'Color', lineColors{1});
    hold on;
    % Create an array to store handles for legend
    legendHandles = h1;
    for i=1:length(ModelNames)
        ROMFlexExtNum = [sort(-NumResults{i}(:,2)); NumResults{i}(2:end,1)];
        h = plot(MomentFlexExt, ROMFlexExtNum, 'LineWidth', 2,'LineStyle', lineStyles{i}, 'Color', lineColors{i+1});
        legendHandles = [legendHandles, h];
        hold on;
    end
    title('Flexion and Extension', 'FontSize',FontSizeTitle);
    n = round((max(MomentFlexExt) + abs(min(MomentFlexExt))) / 2.5) + 1;
    xlim([min(MomentFlexExt) max(MomentFlexExt)]);
    ylim([-15 15]);
    xticks(linspace(min(MomentFlexExt), max(MomentFlexExt), n));
    ax = gca;
    ax.XAxis.FontSize = FontSizeTicks; 
    ax.YAxis.FontSize = FontSizeTicks; 
    ylabel('RoM (deg.)','FontSize',FontSizeAxLabel); 
    xlabel('Moment (Nm)','FontSize',FontSizeAxLabel);
    hold off;
    
    % Lateral Bending subplot
    subplot(2,2,2);
    plot(Moment, ExpResults.LateralBending{1,1}, 'LineWidth', 2,'Color', lineColors{1});
    hold on;
    for i=1:length(ModelNames)
        plot(Moment, NumResults{i}(:,3), 'LineWidth', 2,'LineStyle', lineStyles{i}, 'Color', lineColors{i+1});
        hold on;
    end
    title('Lateral Bending', 'FontSize',FontSizeTitle);
    xlim([0 max(Moment)]);
    ylim([0 8]);
    n = round((max(Moment)) / 2.5) + 1;
    xticks(linspace(0, max(Moment), n));
    ax = gca;
    ax.XAxis.FontSize = FontSizeTicks; 
    ax.YAxis.FontSize = FontSizeTicks; 
    ylabel('RoM (deg.)','FontSize',FontSizeAxLabel);
    xlabel('Moment (Nm)','FontSize',FontSizeAxLabel);
    hold off;
    
    % Axial Rotation subplot
    subplot(2,2,4);
    plot(Moment, ExpResults.AxialRotation{1,1}, 'LineWidth', 2,'Color', lineColors{1});
    hold on;
    for i=1:length(ModelNames)
        plot(Moment, NumResults{i}(:,4), 'LineWidth', 2,'LineStyle', lineStyles{i}, 'Color', lineColors{i+1});
        hold on;
    end
    title('Axial Rotation', 'FontSize',FontSizeTitle);
    xlim([0 max(Moment)]);
    ylim([0 8]);
    n = round((max(Moment)) / 2.5) + 1;
    xticks(linspace(0, max(Moment), n));
    ax = gca;
    ax.XAxis.FontSize = FontSizeTicks; 
    ax.YAxis.FontSize = FontSizeTicks; 
    ylabel('RoM (deg.)','FontSize',FontSizeAxLabel);
    xlabel('Moment (Nm)','FontSize',FontSizeAxLabel);
    hold off;
    
    % Construct a legend with the data from the subplots
    legendLocation = 'northwest';
    LegendStrings = 'Exp.';
    ModelNamesLegend = {'HGO', 'lin. Rebar', 'nonlin. Rebar'};
    LegendStrings = cat(2, LegendStrings, ModelNamesLegend);
    legend(legendHandles, LegendStrings, 'Location', legendLocation,'FontSize',FontSizeLegend);

    % Save the figure
    figName = fullfile(pwd, '.', 'ResultsGraphs', 'Calibration', ['CalibratedModelsComparison', '.png']);
    saveas(fig, figName);
    close all;
end