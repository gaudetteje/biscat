function h = gui_helper_callback

h.load_data = @LoadInputFile;
h.get_config = @getConfigSettings;
h.set_config = @setConfigSettings;
h.set_status = @setStatusBarString;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Helper functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ts = LoadInputFile(file)
% Load signal input file and return time series struct

% preload header info
ts.timestamp = datestr(now());
ts.filename = file;

% load data and misc info from data file
try
    if strcmp('.wav',file(end-3:end))
        [ts.data, ts.fs, ts.nBits] = wavread(file);
    elseif strcmp('.au',file(end-2:end))
        [ts.data, ts.fs, ts.nBits] = auread(file);
    elseif strcmp('.mat',file(end-3:end))
        load(file, 'ts');
    else
        error(' ')      % force into catch statement
    end
catch
    ts.data = [];
    warning('Failed to load time series data from file: "%s"',file)
    return
end

% force time series into column vectors
if isfield(ts,'data')
    if size(ts.data,2) > size(ts.data,1)
        ts.data = ts.data';
    end
end
if isfield(ts,'time')
    if size(ts.time,2) > size(ts.time,1)
        ts.time = ts.time';
    end
end



function cfg = getConfigSettings(handles, varargin)
% Retrieve current user settings from GUI handle objects
%
% The algorithm recursively iterates through the handle structure looking for
% uiobjects containing populated Tag strings.  The value is retrieved
% (depending on the type of uiobject) and then saved to cfg.(tag)

if nargin > 1
    cfg = varargin{1};              % continue populating existing struct
else
    cfg = [];                       % init return structure
end

% get list of handle names in current struct
hname = fieldnames(handles);

% recursively iterate over handle structure, looking for matching fields
for n = 1:numel(hname)
    
    % retreive handle or struct of handles
    cur_handle = handles.(hname{n});
    
    % call recursively on structures; concatenate when finished
    if isstruct(cur_handle)
        cfg = getConfigSettings(cur_handle, cfg);
    
    % otherwise look for valid Tag strings
    else
        
        % ignore unused or absent handles
        cur_tag = get(cur_handle,'Tag');
        if cur_tag
            
            try
                
                % retrieve uiobject structure from handle
                cur_struct = get(cur_handle);
                
                % parse structure to determine uiobject type
                if isfield(cur_struct, 'Style')
                    style = cur_struct.Style;
                    switch style
                        case {'edit'}
                            num = str2num(cur_struct.String);
                            if num
                                value = num;
                            else
                                value = cur_struct.String;
                            end
                        case {'radiobutton', 'checkbox', 'popupmenu'}
                            value = cur_struct.Value;
                        otherwise
                            msg = 'Unknown style type';
                            warning('BISCAT:GUIhandles', msg);
                    end
                elseif isfield(cur_struct, 'SelectedObject')
                    sel_struct = get(cur_struct.SelectedObject);
                    value = sel_struct.UserData;
                elseif isfield(cur_struct, 'Data')
                    value = get(cur_handle,'Data');
                else
                    msg = 'Cannot get data from struct';
                    warning('BISCAT:GUIhandles', msg);
                end
                
                % assign read value
                cfg.(cur_tag) = value;
                
            catch
                warning(sprintf('Failed to read GUI object: %s with Tag "%s"', hname{n}, cur_tag))
                
            end
        end
    end
end



function setConfigSettings(handles, cfg)
% Set GUI handle objects to the specified configuration

% get list of handle names in current struct
hname = fieldnames(handles);

% recursively iterate over handle structure, looking for matching fields
for n = 1:numel(hname)
    
    % retreive handle or struct of handles
    cur_handle = handles.(hname{n});
    
    % call recursively on structures
    if isstruct(cur_handle)
        setConfigSettings(cur_handle, cfg)
    
    % otherwise look for valid Tag strings
    else
        
        % ignore unused or absent handles
        cur_tag = get(cur_handle,'Tag');
        if cur_tag
            
            try
                
                % retrieve current value from config structure
                value = cfg.(cur_tag);
                cur_struct = get(cur_handle);

                % set appropriate field in uicontrol
                if isfield(cur_struct, 'Style')
                    style = cur_struct.Style;
                    switch style
                        case 'edit'
                            set(cur_handle,'String',num2str(value));
                        case {'radiobutton', 'checkbox', 'popupmenu'}
                            set(cur_handle,'Value',value);
                        otherwise
                            msg = 'Unknown style type';
                            warning('BISCAT:GUIhandles', msg);
                    end
                elseif isfield(cur_struct, 'SelectedObject')
                    set(cur_handle,'SelectedObject',handles.(value));
                elseif isfield(cur_struct, 'Data')
                    % ensure table gets fully populated
                    s1 = size(get(cur_handle,'Data'));
                    s2 = size(value);
                    if s1 ~= s2
                        new_value = zeros(s1);
                        new_value(1:s2(1),1:s2(2)) = value;
                        value = new_value;
                    end
                    set(cur_handle,'Data',value);
                else
                    msg = sprintf('Cannot get data from struct using fieldname: "%s"',hname{n});
                    warning('BISCAT:GUIhandles', msg)
                end
                
            catch
                disp(sprintf('Failed to set GUI object: %s with Tag "%s"', hname{n}, cur_tag))
                
            end
        end
    end
end



function setStatusBarString(handles, string, varargin)
% generic function to write status bar messages

if nargin>2
    set(handles.main.status_bar,'String',sprintf(string,varargin{:}));
else
    set(handles.main.status_bar,'String',string);
end
