function RsquaredArray = CalculateRSquared(NumResults, ExpResults)
    
    % Initialize an array to store R-squared values for each loading direction
    RsquaredValues = zeros(1, size(NumResults,2));
    % ExpResults struc-array to cell-array
    ExpResults = struct2cell(ExpResults);
    % Calculate the R-squared for each loading direction
    for i = 1:size(NumResults,2)
        RsquaredValues(i) = 1 - sumsqr(ExpResults{i+1, 1}{1,1} - NumResults(:, i)) / sumsqr(ExpResults{i+1, 1}{1,1}  - mean(ExpResults{i+1, 1}{1,1} ));
    end
    % Calculate the mean of the R-squared values 
    Rsquared = mean(RsquaredValues);
    % Create the output array
    RsquaredArray = [Rsquared, RsquaredValues];
end