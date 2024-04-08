function ProcessSimulationsIDP(ModelName, LoadNames)

    %% Write rpt-files         
    for i=1:length(LoadNames)
        LoadName = LoadNames{i};
        ODBName = [ModelName, LoadName];
        command = ['abaqus cae noGUI=ReadODBFileIDP.py -- ', ODBName];
        dos(command);
    end

end