function ParameterArray = CalculateMaterialParameters(ParameterName, NVariations, RangeWidth)

    % Define predefined median values
    predefinedMedians = struct('Kappa', 0.15, 'K1Circ', -0.1, 'K2Circ', -0.1, 'K1Rad', -0.1, 'K2Rad', -0.1, ...
                               'Lambda', 1, 'LambdaRad', -0.1, 'LambdaCirc', -0.1, 'FiberAngleRad', 0.1, ...
                               'FiberAngleCirc', 0.15, 'FiberPoissonRate', 0.45);

    % Check if the ParameterName is predefined and get the median value
    if isfield(predefinedMedians, ParameterName)
        ParameterMedian = predefinedMedians.(ParameterName);
    else
        % Read values from the txt file and calculate median
        filename = ['./MaterialParameter/', ParameterName, '.txt'];
        fid = fopen(filename);
        ParameterData = textscan(fid, '%f # %[^\n]', 'HeaderLines', 0);
        fclose(fid);
        ParameterMedian = round(median(ParameterData{1}), 2);
    end

    % Initialize ParameterArray
    ParameterArray = zeros(1, NVariations + 1);
    ParameterArray(1) = ParameterMedian;

    % Special handling for FiberPoissonRate
    if strcmp(ParameterName, "FiberPoissonRate")
        ParameterArray(2:end) = [0.3, 0.375, 0.475, 0.49];
    else
        % Calculate range for variation-scaling
        Range = linspace(1 - RangeWidth, 1 + RangeWidth, NVariations + 1);
        Range(ceil(NVariations / 2) + 1) = []; % remove the middle element
        ParameterArray(2:end) = Range * ParameterMedian;
    end
end

% 
% 
% function ParameterArray = CalculateMaterialParameters(ParameterName, NVariations, RangeWidth)
% 
%     % Check if the ParameterName matches predefined variables
%     predefinedParameters = {'Kappa','K1Circ', 'K2Circ', 'K1Rad', 'K2Rad','Lambda', 'LambdaRad', 'LambdaCirc','FiberPoissonRate' ,'FiberAngleRad', 'FiberAngleCirc'};
% 
%     isPredefined = ismember(ParameterName, predefinedParameters);
% 
%     if isPredefined
%         % Use predefined values
%         switch ParameterName
%             case 'Kappa'
%                 ParameterMedian = 0.15;
%             case 'K1Circ'
%                 ParameterMedian = -0.1;
%             case 'K2Circ'
%                 ParameterMedian = -0.1;
%             case 'K1Rad'
%                 ParameterMedian = -0.1;
%             case 'K2Rad'
%                 ParameterMedian = -0.1;
%             case 'Lambda'
%                 ParameterMedian = 1;
%             case 'LambdaRad'
%                 ParameterMedian = -0.1;
%             case 'LambdaCirc'
%                 ParameterMedian = -0.1;
%             case 'FiberAngleRad'
%                 ParameterMedian = 0.1;
%             case 'FiberAngleCirc'
%                 ParameterMedian = 0.15;
%             case 'FiberPoissonRate'
%                 ParameterMedian = 0.45;
%         end
%     else
%         % Read values from the txt file
%         filename = ['./MaterialParameter/',ParameterName, '.txt'];
%         fid = fopen(filename);
%         ParameterData = textscan(fid, '%f # %[^\n]', 'HeaderLines', 0);
%         fclose(fid);
%         % Extract the parameter values
%         ParameterValues = ParameterData{1};
%         % Calculate sensitivity parameters
%         ParameterMedian = round(median(ParameterValues), 2);
%     end
% 
%     Range = linspace(1-RangeWidth,1+RangeWidth,NVariations+1); % range for variation-scaling
%     ParameterArray = zeros(1,NVariations+1);
%     ParameterArray(1) = ParameterMedian;
%     if ParameterName == "FiberPoissonRate"
%         ParameterArray(2:end) = [0.3, 0.375, 0.475, 0.49];
%     else
%         j = 1; % counter-variable for range-values
%         for i=2:NVariations+1
%             ParameterArray(i) = Range(j) * ParameterMedian;
%             if j == NVariations / 2
%                 j = j + 2;
%             else
%                 j = j + 1;
%             end
%         end
%     end
% 
% end