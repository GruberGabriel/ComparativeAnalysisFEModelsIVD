function ScaledNodesToFile(array, filename)
    % check if file ends with .inp
    if ~endsWith(filename, '.inp')
        filename = strcat(filename, '.inp');
    end
    
    % open the file 
    fileID = fopen(filename, 'w');
    
    % check if the files was opened successfully
    if fileID == -1
        error('Fehler beim Öffnen der Datei.');
    end
    
    % first line of the file --> starting with "*Node"
    fprintf(fileID, '*Node\n');
    
    % write array to file
    for i = 1:size(array, 1)
        if i == size(array,1)
            fprintf(fileID, '%.1d, %.6f, %.6f, %.6f', array(i, 1), array(i, 2), array(i, 3), array(i, 4));
        else
            fprintf(fileID, '%.1d, %.6f, %.6f, %.6f\n', array(i, 1), array(i, 2), array(i, 3), array(i, 4));
        end
    end
    
    % Schließen der Datei
    fclose(fileID);
end
