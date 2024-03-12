function UpdateDimensions(DiscHeight,LateralWidth,SagittalWidth, Modeltype)

    % Loading original nodes --> stored in .mat-file (to save some time)
    if Modeltype == 1
        % nodes = load('nodesHGOModel.mat');
        FilenameINP = 'NodesHGO.inp';
    else
        % nodes = load('nodesRebarModel.mat'); 
        FilenameINP = 'NodesRebar.inp';
    end

    nodes = ReadNodes(FilenameINP);

    % Get center point of nodes-cloud
    center = mean(nodes(:,2:end));
    % Define vector for translation to origin of global KOS
    center_diff = center - zeros(1,3);
    % Translation of nodes to origin of global KOS
    TranslatedNodes = nodes(:,2:end) - center_diff;
    TranslatedNodes = [nodes(:,1), TranslatedNodes];
    % Filter nodes --> only nodes with x=0
    RoundedNodes = round(TranslatedNodes(:,2:end),0); % rounding nodes before filtering
    FilteredNodes = TranslatedNodes(RoundedNodes(:, 1) == 0, :);
    % Identify nodes to define vector for rotation
    % Find the node with the smallest z-coordinate
    [minZ, idxMinZ] = min(FilteredNodes(:, 4));
    % Find the node with the smallest y-coordinate
    [minY, idxMinY] = min(FilteredNodes(:, 3));    
    % Select the nodes with the greatest z and y coordinates
    nodeWithMinZ = FilteredNodes(idxMinZ, :);
    nodeWithMinY = FilteredNodes(idxMinY, :);
    % Vector for rotation
    RotationVector = nodeWithMinY(2:end) - nodeWithMinZ(2:end);
    % Calculate the angle between the vector and the z-axis
    dotProduct = dot(RotationVector, [0, 0, 1]); % scalar-product
    magnitudeVector = norm(RotationVector);
    angleInRadians = acos(dotProduct / magnitudeVector);
    angleInRadians = 2*pi - angleInRadians; % rotation-vector: 360 - calculated vector
    % Create the rotation matrix around the x-axis
    theta = angleInRadians; % Use the calculated angle
    R_x = [1, 0, 0; 0, cos(theta), -sin(theta); 0, sin(theta), cos(theta)];
    
    % Create a copy of TranslatedNodes to store the rotated nodes
    RotatedNodes = TranslatedNodes(:,2:end);

    % Iterate through each node and apply the rotation
    for i = 1:size(TranslatedNodes, 1)
        node = TranslatedNodes(i, 2:end);
        
        % Apply the rotation using the rotation matrix R_x
        rotatedNode = (R_x * node')';
        
        % Store the rotated node in the RotatedNodes array
        RotatedNodes(i, :) = rotatedNode;
    end
    
    RotatedNodes = [TranslatedNodes(:,1), RotatedNodes];

    % Find lateral diametre by using the max and min x-coordinates
    [minX, idxMinX] = min(RotatedNodes(:, 2));
    [maxX, idxMaxX] = max(RotatedNodes(:, 2));    
    LateralWidth_0 = maxX + abs(minX);    
    % Find sagittal diametre by using the max and min z-coordinates
    FilteredNodes = RotatedNodes(abs(RotatedNodes(:, 2)) < 0.2, :); % filtering the nodes in the centre-plane
    [minZ, idxMinz] = min(FilteredNodes(:, 4));
    [maxZ, idxMaxz] = max(FilteredNodes(:, 4));    
    SagittalWidth_0 = maxZ + abs(minZ);        
    % Find average height by using the max and min y-coordinates in the
    % centre-plane of the geometry
    RoundedNodes = round(RotatedNodes(:,2:end),0); % rounding to filter centre-plane
    FilteredNodes = RotatedNodes(RoundedNodes(:, 1) == 0 & RoundedNodes(:, 3) == 0, :); % filter nodes with x and z = 0
    [minY, idxMinY] = min(FilteredNodes(:, 3));
    [maxY, idxMaxY] = max(FilteredNodes(:, 3));    
    AverageHeight_0 = maxY + abs(minY);

    % Scaling the ivd-geometry 
    % RotatedNodes_0  = RotatedNodes;
    RotatedNodes(:,2) = RotatedNodes(:,2) * LateralWidth / LateralWidth_0;
    RotatedNodes(:,3) = RotatedNodes(:,3) * DiscHeight / AverageHeight_0;
    RotatedNodes(:,4) = RotatedNodes(:,4) * SagittalWidth / SagittalWidth_0;
    

    % ReferencePoints: RP1 (above) & RP2 (below)
    % by using nodes with x and z = 0 in rotated configuration
    RoundedNodes = round(RotatedNodes(:,2:end),0);
    FilteredNodes = RotatedNodes(RoundedNodes(:, 1) == 0 & RoundedNodes(:, 3) == 0, :);
    [minY, idxMinY] = min(FilteredNodes(:, 3));
    [maxY, idxMaxY] = max(FilteredNodes(:, 3));
    
    nodeWithMinY_RP = FilteredNodes(idxMinY, :);
    nodeWithMaxY_RP = FilteredNodes(idxMaxY, :);
    
    RP1 = nodeWithMaxY_RP(2:end) + [0, 10, 0];
    RP2 = nodeWithMinY_RP(2:end) - [0, 10, 0];
    

    % RotateBack
    RotatedBackNodes = RotatedNodes(:,2:end);
    % Create the rotation matrix around the x-axis
    theta = 2*pi-angleInRadians; % Use the calculated angle
    R_x = [1, 0, 0; 0, cos(theta), -sin(theta); 0, sin(theta), cos(theta)];
    % Iterate through each node and apply the rotation
    for i = 1:size(RotatedBackNodes, 1)
        node = RotatedNodes(i, 2:end);
        
        % Apply the rotation using the rotation matrix R_x
        rotatedNode = (R_x * node')';
        
        % Store the rotated node in the RotatedNodes array
        RotatedBackNodes(i, :) = rotatedNode;
    end

    RotatedBackNodes = [RotatedNodes(:,1), RotatedBackNodes];
    % Rotate RP1&2
    RP1 = (R_x * RP1')';
    RP2 = (R_x * RP2')';

    % Translation of the rotated scaled nodes back to inital position
    TranslatedBackNodes = RotatedBackNodes(:,2:end);    
    TranslatedBackNodes = TranslatedBackNodes + center_diff;    
    TranslatedBackNodes = [RotatedBackNodes(:,1), TranslatedBackNodes];
    
    %  Translate RP1&2 back to initial-configuration
    RP1 = RP1 + center_diff;
    RP2 = RP2 + center_diff;

    % using customized function to write nodes into .inp-file (-->file is
    % embedded into Model-.inp-file -->parametrization of nodes
    ScaledNodesToFile(TranslatedBackNodes, FilenameINP);

    % using customized function to write coordinates for RP1 and RP2 to
    % .inp-file (-->file is embedded into Model-.inp-file)
    ReferencePointsToFile(RP1, RP2, 'ReferencePoints.inp');    
end
