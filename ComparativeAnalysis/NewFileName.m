function NewFileName(Modelname, Step)

    LoadNames = {'Flexion', 'Extension', 'LateralBending', 'AxialRotation'};

    for j=1:length(LoadNames)
        %% RPT-Files
        currentFileName = ['.\ResultsFiles\AbaqusResults', Modelname, cell2mat(LoadNames(j)), 'ROM.rpt'];
        newFileName = ['.\ResultsFiles\AbaqusResults', Modelname, cell2mat(LoadNames(j)),'ROM', Step ,'.rpt'];
        % Create the full path to the source file and destination file
        sourceFullPath = fullfile(pwd, currentFileName);
        destinationFullPath = fullfile(newFileName);    
        % Use copyfile to copy the file to the destination folder
        copyfile(sourceFullPath, destinationFullPath);

        % %% ODB-Files
        % currentFileName = ['Job', Modelname, cell2mat(LoadNames(j)), '.odb'];
        % newFileName = ['Job', Modelname, cell2mat(LoadNames(j)), Step ,'.odb'];
        % % Create the full path to the source file and destination file
        % sourceFullPath = fullfile(pwd, currentFileName);
        % destinationFullPath = fullfile(newFileName);    
        % % Use copyfile to copy the file to the destination folder
        % copyfile(sourceFullPath, destinationFullPath);
    end
end