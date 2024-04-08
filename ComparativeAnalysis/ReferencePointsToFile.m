function ReferencePointsToFile(RP1, RP2, filename)
    % Check if rigth file-ending is used
    if ~endsWith(filename, '.inp')
        filename = strcat(filename, '.inp');
    end

    % Open the file
    fileID = fopen(filename, 'w');
    
    % Check if file is opened
    if fileID == -1
        error('Fehler beim Öffnen der Datei.');
    end

    % Write the lines into file using RP1 and RP2 for coordinates
    fprintf(fileID, '*Node\n');
    fprintf(fileID, '1,   %.7f,   %.7f,   %.7f\n', RP1(1), RP1(2), RP1(3));
    fprintf(fileID, '*Node\n');
    fprintf(fileID, '2,   %.7f,   %.7f,   %.7f\n', RP2(1), RP2(2), RP2(3));
    fprintf(fileID, '*Nset, nset=RP-Load\n');
    fprintf(fileID, '1,\n');
    fprintf(fileID, '*Nset, nset=RP-Encastre\n');
    fprintf(fileID, '2,\n');

    % close the file
    fclose(fileID);
end