function nodes = ReadNodes(filePath)
    % Open the file for reading
    fid = fopen(filePath, 'r');
    
    % Check if the file is opened successfully
    if fid == -1
        error('Failed to open the .inp file.');
    end
    
    nodes = []; % Initialize an empty array to store node data
    readNodes = false; % Flag to indicate if node data is being read
    
    % Loop through the file until the end
    while ~feof(fid)
        line = fgetl(fid); % Read a line from the file
        
        % Check if line contains '*Node', start reading node data
        if contains(line, '*Node')
            readNodes = true; % Set flag to start reading node data
            continue; % Skip to the next iteration
        end
        

        
        % If reading node data, process the line
        if readNodes
            % Split the line and convert the data to numeric values
            nodeData = str2double(strsplit(line));
            
            % Check if the first element is NaN and remove it if so
            if isnan(nodeData(1))
                nodeData = nodeData(2:end);
            end
            
            nodeID = nodeData(1); % First value is the node ID
            coordinates = nodeData(2:end); % Remaining values are the node coordinates
            
            % Append the current node data to the 'nodes' array
            nodes = [nodes; nodeID, coordinates];
        end

        % If the end of the file is reached or a new section starting with '*' is found, stop reading node data        
        if readNodes && (feof(fid) || contains(line, '*'))
            readNodes = false; % Set flag to stop reading node data
        end
    end
    
    % Close the file
    fclose(fid);
end