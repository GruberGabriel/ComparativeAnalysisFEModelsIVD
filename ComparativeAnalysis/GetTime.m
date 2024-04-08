function time = GetTime(fileID)

    % Open the default inp-file and read all lines
    fid = fopen(fileID, 'r');
    lines = textscan(fid, '%s', 'Delimiter', '\n');
    lines = lines{1};
    fclose(fid);
     
    z = 0;
    for i = 1:numel(lines)
        line = lines{i};
        if startsWith(line, 'WALLCLOCK') % Trigger: string starting time declaration
            z = z + 1;
            time_info = strsplit(line, '=');
            if numel(time_info) == 2 && z == 2 % simulation time --> 2nd WALLCLOCK-time
                % Extract the integer value and assign it to the 'time' variable
                time = str2double(time_info{2});    
            end        
        end        
    end
end