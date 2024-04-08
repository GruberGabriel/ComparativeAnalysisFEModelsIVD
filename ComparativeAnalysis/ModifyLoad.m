function ModifyLoad(InputFile_0, InputFile_1, load_axis, new_value)
    % Open the default inp-file and read all lines
    fid = fopen(InputFile_0, 'r');
    if fid == -1
        error(['Unable to open file: ', InputFile_0]);
    end
    lines = textscan(fid, '%s', 'Delimiter', '\n');
    lines = lines{1};
    fclose(fid);

    % Adapting line with load-information by running through the whole file
    previous_line = "";
    modified_lines = {};
    for i = 1:numel(lines)
        line = lines{i};
        if startsWith(previous_line, '*Cload') % Trigger: string starting load declaration
            load_info = strsplit(line, ',');
            load_info{end-1} = [' ', num2str(load_axis)]; % Second entry from right = load axis
            load_info{end} = [' ', num2str(new_value)];
            modified_lines{end+1} = strjoin(load_info, ',');
        else
            modified_lines{end+1} = line;
        end
        previous_line = line;
    end

    % Write the specified file with adapted load-information
    fid = fopen(InputFile_1, 'w');
    fprintf(fid, '%s\n', modified_lines{:});
    fclose(fid);

    % Write the specified file with adapted load-information
    fid = fopen(InputFile_1, 'w');
    if fid == -1
        error(['Unable to open file for writing: ', InputFile_1]);
    end
    fprintf(fid, '%s\n', modified_lines{:});
    fclose(fid);
end
