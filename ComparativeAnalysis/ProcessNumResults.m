function NumResultsArray = ProcessNumResults(NumResults_temp, Moment)
    
    % Maximum moment applied 
    MaxMoment = Moment(end);
    
    % Delete non-converged data points
    fields = fieldnames(NumResults_temp);
    for i = 1:length(fields)
        idx = find(diff(NumResults_temp.(fields{i}){1,1}) == 0);
        NumResults_temp.(fields{i}){1,1}(idx) = [];
        NumResults_temp.(fields{i}){1,2}(idx) = [];
        if length(NumResults_temp.(fields{i})) > 2
            NumResults_temp.(fields{i}){1,3}(idx) = [];
            NumResults_temp.(fields{i}){1,4}(idx) = [];
        end
    end
    
    % Check if the simulation did not converge 80%. If so, set the range of motion to zero
    for i = 1:length(fields)
        if isempty(NumResults_temp.(fields{i}){1,1}) || NumResults_temp.(fields{i}){1,1}(end) < 0.8
            NumResults_temp.(fields{i}){1,1} = zeros(5, 1);
            if contains(fields{i},'Flexion') || contains(fields{i}, 'IDP')
                NumResults_temp.(fields{i}){1,2} = linspace(0, -10, 5)';
            elseif contains(fields{i},'Extension')  && ~contains(fields{i}, 'IDP')
                NumResults_temp.(fields{i}){1,2} = linspace(0, 10, 5)';
            elseif contains(fields{i},'LateralBending')
                NumResults_temp.(fields{i}){1,4} = linspace(0, -10, 5)';
            elseif contains(fields{i},'AxialRotation')
                NumResults_temp.(fields{i}){1,3} = linspace(0, -10, 5)';
            end
        end
    end
    
    % Convert time of Abaqus-simulation to load
    NumResults = struct;
    for i = 1:length(fields)
        NumResults.(fields{i}){1,1} = NumResults_temp.(fields{i}){1,1} * MaxMoment / NumResults_temp.(fields{i}){1,1}(end);
        NumResults.(fields{i}){1,2} = NumResults_temp.(fields{i}){1,2};
        if length(NumResults_temp.(fields{i})) > 2
            NumResults.(fields{i}){1,3} = NumResults_temp.(fields{i}){1,3};
            NumResults.(fields{i}){1,4} = NumResults_temp.(fields{i}){1,4};
        end
    end
        
    % Make a spline fit for each direction in the case of full Abaqus convergence. Otherwise, make a polynomial fit
    NumResultsArray = zeros(length(Moment), length(fields));
    for i = 1:length(fields)
        if contains(fields{i},'Flexion') || contains(fields{i}, 'IDP')
            s = 1;
            a = 2;
        elseif contains(fields{i},'Extension') && ~contains(fields{i}, 'IDP')
            s = -1;
            a = 2;
        elseif contains(fields{i},'LateralBending')
            s = 1;
            a = 4;
        elseif contains (fields{i},'AxialRotation')
            s = 1;
            a = 3;
        end
        if isnan(NumResults.(fields{i}){1,1}(end))
            NumResultsArray(:, i) = zeros(size(Moment));
        elseif 0.8 * MaxMoment < s*NumResults.(fields{i}){1,1}(end) && s*NumResults.(fields{i}){1,1}(end) < MaxMoment * 0.99999999999999
            FitFun = fit(NumResults.(fields{i}){1,1}, s*NumResults.(fields{i}){1,a}, 'poly2');
            % Extract the coefficients of the fit function
            coeffvals = coeffvalues(FitFun);
            % Obtain the ROM analytically
            if contains(fields{i}, 'IDP')
                NumResultsArray(:, i) = (coeffvals(1,1) * Moment.^2 + coeffvals(1,2) * Moment + coeffvals(1,3));
            else
                NumResultsArray(:, i) = (coeffvals(1,1) * Moment.^2 + coeffvals(1,2) * Moment + coeffvals(1,3)) * 180 / pi();
            end
        else
            FitFun = fit(NumResults.(fields{i}){1,1}, s*NumResults.(fields{i}){1,a}, 'spline');
            if contains(fields{i}, 'IDP')
                NumResultsArray(:, i) = feval(FitFun, Moment);
            else
                NumResultsArray(:, i) = feval(FitFun, Moment) * 180 / pi();
            end
        end
    end
end