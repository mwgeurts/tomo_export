function info = MemInfo()
%MEMINFO  return system physical memory information
%
%   info = MEMINFO() returns a structure containing various bits of
%   information about the system memory. This information includes:
%     * TOTAL Memory in bytes
%     * USED Memory in bytes
%     * UNUSED Memory in bytes
%
%   See also: COMPUTER, ISUNIX, ISMAC

info = struct();

if isunix
    if ismac
        [~, text] = unix('top -l 1');
        fields = textscan(text, '%s', 'Delimiter', '\n' ); 
        fields = fields{1};
        fields( cellfun( 'isempty', fields ) ) = [];
        for i = 1:length(fields)
            tokens = regexp(fields{i}, ['^PhysMem[^0-9]+([0-9]+)([MGk]) used', ...
                '[^0-9]+([0-9]+)([MGk]) wired[^0-9]+([0-9]+)([MGk]) unused'], ...
                'tokens');
            if ~isempty(tokens)
                if strcmp(tokens{1}{2}, 'G') 
                    tokens{1}{1} = str2double(tokens{1}{1})*1024^3;
                elseif strcmp(tokens{1}{2}, 'M') 
                    tokens{1}{1} = str2double(tokens{1}{1})*1024^2;
                elseif strcmp(tokens{1}{2}, 'k') 
                    tokens{1}{1} = str2double(tokens{1}{1})*1024;
                end
                if strcmp(tokens{1}{4}, 'G') 
                    tokens{1}{3} = str2double(tokens{1}{3})*1024^3;
                elseif strcmp(tokens{1}{4}, 'M') 
                    tokens{1}{3} = str2double(tokens{1}{3})*1024^2;
                elseif strcmp(tokens{1}{4}, 'k') 
                    tokens{1}{3} = str2double(tokens{1}{3})*1024;
                end
                if strcmp(tokens{1}{6}, 'G') 
                    tokens{1}{5} = str2double(tokens{1}{5})*1024^3;
                elseif strcmp(tokens{1}{6}, 'M') 
                    tokens{1}{5} = str2double(tokens{1}{5})*1024^2;
                elseif strcmp(tokens{1}{6}, 'k') 
                    tokens{1}{5} = str2double(tokens{1}{5})*1024;
                end
                info = struct('Used', tokens{1}{1}, ...
                    'Wired', tokens{1}{3}, ...
                    'Unused', tokens{1}{5}, ...
                    'Total', tokens{1}{1} + tokens{1}{3});
                break;
            end
        end
    else
        [~, text] = unix('top -n 1');
        fields = textscan(text, '%s', 'Delimiter', '\n' ); 
        fields = fields{1};
        fields( cellfun( 'isempty', fields ) ) = [];
        for i = 1:length(fields)
            tokens = regexp(fields{i}, ['^Mem[^0-9]+([0-9]+)([MGk]) total', ...
                '[^0-9]+([0-9]+)([MGk]) used[^0-9]+([0-9]+)([MGk]) free'], ...
                'tokens');
            if ~isempty(tokens)
                if strcmp(tokens{1}{2}, 'G') 
                    tokens{1}{1} = str2double(tokens{1}{1})*1024^3;
                elseif strcmp(tokens{1}{2}, 'M') 
                    tokens{1}{1} = str2double(tokens{1}{1})*1024^2;
                elseif strcmp(tokens{1}{2}, 'k') 
                    tokens{1}{1} = str2double(tokens{1}{1})*1024;
                end
                if strcmp(tokens{1}{4}, 'G') 
                    tokens{1}{3} = str2double(tokens{1}{3})*1024^3;
                elseif strcmp(tokens{1}{4}, 'M') 
                    tokens{1}{3} = str2double(tokens{1}{3})*1024^2;
                elseif strcmp(tokens{1}{4}, 'k') 
                    tokens{1}{3} = str2double(tokens{1}{3})*1024;
                end
                if strcmp(tokens{1}{6}, 'G') 
                    tokens{1}{5} = str2double(tokens{1}{5})*1024^3;
                elseif strcmp(tokens{1}{6}, 'M') 
                    tokens{1}{5} = str2double(tokens{1}{5})*1024^2;
                elseif strcmp(tokens{1}{6}, 'k') 
                    tokens{1}{5} = str2double(tokens{1}{5})*1024;
                end
                info = struct('Total', tokens{1}{1}, ...
                    'Used', tokens{1}{3}, ...
                    'Unused', tokens{1}{5});
                break;
            end
        end
    end
else
    [~, sys] = memory;
    info = struct('Total', sys.PhysicalMemory.Total, 'Used', ...
        sys.PhysicalMemory.Total - sys.PhysicalMemory.Available, ...
        'Unused', sys.PhysicalMemory.Available);
end