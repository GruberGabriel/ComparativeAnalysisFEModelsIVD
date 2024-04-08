function RunProcessSimulations(ModelName, LoadNames, IncludeIDP)    

    %% Check for .lck-files
    folderPath = '.\'; 
    % Get a list of all files in the folder
    files = dir(fullfile(folderPath, '*.lck'));    
    % Check if there are any .lck files
    if ~isempty(files)
        % Loop through each file and delete it
        for i = 1:numel(files)
            filePath = fullfile(folderPath, files(i).name);
            delete(filePath);
        end    
    end

    %% run simulations
    for i=1:length(LoadNames)
        LoadName = LoadNames{i};
        JobName = ['Job', ModelName, LoadName];
        cmd = ['abaqus job=', JobName , ' interactive cpus=8 gpus=1 ask_delete=OFF']; % Adapt the number of cpus and the activation of gpu-support if required
        dos(cmd);
    end

    %% Write rpt-files         
    for i=1:length(LoadNames)
        LoadName = LoadNames{i};
        ODBName = [ModelName, LoadName];
        command = ['abaqus cae noGUI=ReadODBFileROM.py -- ', ODBName];
        dos(command);
        if IncludeIDP == 1
            command = ['abaqus cae noGUI=ReadODBFileIDP.py -- ', ODBName];
            dos(command);
        end
    end

    %% Delete not-required simulation-files
    FileEndings = {'.env', '.com', '.prt', '.msg'};
    for i=1:length(LoadNames)
        for j=1:length(FileEndings)
            filePath = ['.\Job',ModelName,LoadNames{i}, FileEndings{j}];
            if exist(filePath, 'file')
                delete(filePath);
            end
        end
    end

    %% Move remaining simulation-files to defined destination
    FileEndings = {'.dat', '.odb', '.sta'};
    for i=1:length(LoadNames)
        for j=1:length(FileEndings)
            currentFilePath = ['.\Job',ModelName,LoadNames{i}, FileEndings{j}];
            destinationFilePath = ['.\SimulationFiles\Job',ModelName,LoadNames{i}, FileEndings{j}];
            if exist(currentFilePath, 'file')
                movefile(currentFilePath, destinationFilePath)
            end
        end
    end
end