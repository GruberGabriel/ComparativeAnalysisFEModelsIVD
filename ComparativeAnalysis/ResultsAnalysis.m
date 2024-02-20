function CalibrationParameters = ResultsAnalysis(Modeltype, ResultsData, MatParameter, LoadCases, ResultsType, SensitivityLimit)
    
    if Modeltype == 1
        ParameterLabels = {'C10_{n}','C01_{n}','C10_{a}','K_{1}','K_{2}','\kappa',...
            'K_{1c}','K_{2c}','K_{1r}','K_{2r}' ,'\alpha','\alpha_{c}','\alpha_{r}'};
        Modelname = 'HGO';
    else
        ParameterLabels = {'C10_{n}','C01_{n}','C10_{a}','C01_{a}','\lambda','\lambda_{c}',...
            '\lambda_{r}','\nu_{Fibers}' ,'\alpha','\alpha_{c}','\alpha_{r}'};
        Modelname = 'Rebar';
    end    
    % Initialize array for sensitivity scores
    SensitivityArray = zeros(numel(LoadCases), numel(ParameterLabels));    
    % Calculate sensitivity and write to Excel file
    for i = 1:numel(LoadCases)
        data = cell2mat(ResultsData(1, i));      
        deltaData = (data(:, 2:end) - data(:, 1)) ./ data(:, 1);
        deltaParam = (MatParameter(:, 2:end) - MatParameter(:, 1)) ./ MatParameter(:, 1);
        SensitivityArray(i, :) = mean(transpose(deltaData ./ deltaParam)); % using mean along the first dimension
        % sensitivity = ((data(:, 2:end) - data(:, 1)) ./ data(:, 1)) ./ ((MatParameter(:, 2:end) - MatParameter(:, 1)) ./ MatParameter(:, 1));
        % SensitivityArray(i, :) = mean(transpose(sensitivity));
                
    end
    % Write sensitivity to Excel file
    sensitivityFilename = fullfile(pwd, 'ExcelFiles', 'SensitivityAnalysis', sprintf('Sensitivity%s.xlsx', ResultsType));
    writetable(array2table(SensitivityArray), sensitivityFilename, 'Sheet', 'Sheet1', 'WriteVariableNames', false);

    % Plot sensitivity results using Polar graphs
    fig = figure('Position', [100, 100, 1000, 800]);
    pax = polaraxes(fig);    
    Median = zeros(1, size(data,1)+1);
    SLimit_upper = 0.1*ones(1, size(data,1)+1);
    SLimit_lower = -0.1*ones(1, size(data,1)+1);
    theta = linspace(0, 2*pi, length(Median));
    h1 = polarplot(pax, theta, Median, 'LineWidth', 2, 'DisplayName', 'Median', 'Color', 'black');
    legendHandles = h1;
    hold on;
    h2 = polarplot(pax, theta, SLimit_upper, 'LineWidth', 1, 'LineStyle', '--' , 'Color', 'black','DisplayName', 'Threshold');
    legendHandles = [legendHandles, h2];
    hold on;
    polarplot(pax, theta, SLimit_lower, 'LineWidth', 1, 'LineStyle', '--' , 'Color', 'black');
    hold on;

    % Plot sensitivity for each load case
    % Define a set of distinct colors
    LoadcaseColors = [
        255, 140, 0; % Orange 
        139, 0, 0;   % DarkRed       
        0, 100, 0;        % DarkGreen
        79, 148, 205; % SteelBlue
    ];
    LoadcaseColors = LoadcaseColors ./ 255;
    
    LineStyles = {'-','--','-','--'};

    for i = 1:numel(LoadCases)
        PlotData = [SensitivityArray(i, :), SensitivityArray(i, 1)];
        h = polarplot(pax, theta, PlotData, 'LineWidth', 3, 'DisplayName', LoadCases{i}, 'Color', LoadcaseColors(i, :), 'Linestyle', LineStyles{i});
        legendHandles = [legendHandles, h];
        hold on;
    end

    thetaticks(theta(1:end-1) * 180/pi);

    % Set axes properties and adjust layout
    pax.Position = [0, 0.1, 0.75, 0.75];
    pax.RAxisLocation = 90;
    pax.ThetaDir = "clockwise";
    pax.ThetaZeroLocation = 'top';
    ALim_max_0 = max(SensitivityArray, [], "all");
    ALim_min_0 = min(min(SensitivityArray, [], "all"),0);
    ALim_max = round(ALim_max_0, 1);
    ALim_min = round(ALim_min_0, 1);
    if (ALim_max - ALim_max_0) < 0.05
        ALim_max = ALim_max + 0.2;
    end
    if ALim_min > ALim_min_0 || (ALim_min- ALim_min_0) > -0.05
        ALim_min = ALim_min - 0.2;
    end
    if round(mod(ALim_max/0.1, 2), 3)%abs(mod(ALim_max/0.1,2) - round(mod(ALim_max/0.1,2))) < eps
        ALim_max = ALim_max + 0.1;
    end
    if round(mod(ALim_min/0.1, 2), 3)%abs(mod(ALim_min/0.1,2) - round(mod(ALim_min/0.1,2))) < eps
        ALim_min = ALim_min - 0.1;
    end
     
    if ALim_max > 2
        ALim_max = 2;
    end
    rlim([ALim_min, ALim_max]);
    n = round((ALim_max - ALim_min) / 0.2) + 1;
    rticks(linspace(ALim_min, ALim_max, n));
    set(gca, 'FontSize', 14); % set fontsize for rticks
    pax.GridAlpha = 0.5; % Set the transparency of the grid lines

    % Add legend with increased space
    lgd = legend(pax,legendHandles, 'Location', 'eastoutside', 'Fontsize', 18);
    % Adjust the position of the legend to increase space
    lgd.Position(1) = lgd.Position(1) * 1.4; % Adjust the value as needed

    % Customize figure-properties
    ax = gca;
    rruler = ax.RAxis;
    rruler.Label.String = sprintf('S_{R,P}');
    PositionScaling = (ALim_max + abs(ALim_min))*0.9+ALim_min;
    rruler.Label.Position = [-7.5, PositionScaling, 5]; % position the label of the axis
    set(rruler.Label, 'Fontsize', 16); % set fontsize for axis-label
    pax.ThetaTickLabel = [];
    
    % Add parameter labels around the plot
    for i = 1:numel(theta)-1
        PositionScaling = (ALim_max + abs(ALim_min))*1.1+ALim_min;
        thetaTickLabel = text(theta(i), PositionScaling, ParameterLabels{i});
        thetaTickLabel.FontSize = 18;
        thetaTickLabel.FontWeight = 'bold';
        thetaTickLabel.HorizontalAlignment = 'center';
    end

    % Export the figure
    FigureFileName = fullfile(pwd,'.', 'ResultsGraphs', 'SensitivityAnalysis', [Modelname, ResultsType, '.png']);
    saveas(fig, FigureFileName);
    close all;

    % Determine parameters for calibration based on sensitivity scores
    ParameterCheck = 1:numel(ParameterLabels);
    CalibrationParameters = ParameterCheck(max(abs(SensitivityArray) >= SensitivityLimit));
end