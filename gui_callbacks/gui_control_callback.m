function h = gui_control_callback

h.load_data = @butt_load_Callback;
h.run_sim = @run_sim_Callback;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User control callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function butt_load_Callback(hObject, eventdata)

% retrieve GUI data fields
GUI = guidata(hObject);

% load time series input file and save path
%if eventdata
%    file = get(GUI.handles.tab1.input.file_name,'String');
%else
    cwd = pwd;                          % save current path
    cd('../biscat_signals');            % set path to signals directory (hardcoded path for now, should be set in config)
    [filename, pathname] = uigetfile( { '*.mat;*.wav;*.au', 'Time Series Input Files (*.mat, *.wav, *.au)'; ...
                                    '*.*','All Files (*.*)'}, ...
                                    'Select a Time-Series Input File');
    cd(cwd);
    if ~filename, return, end
    file = fullfile(pathname,filename);
    set(GUI.handles.tab1.input.file_name,'String',sprintf('%s',file));
%end

% Load data from file if it exists
if exist(file,'file')
    ts = GUI.callbacks.help.load_data(file);
    if length(ts.data) > 1
        GUI.data.timeseries = ts;
        guidata(hObject, GUI);
        GUI.callbacks.help.set_status(GUI.handles,'Successfully loaded signal from "%s"',filename);
    else
        msg = sprintf('Could not load time series data from file "%s"', file);
        warndlg(msg,'Warning')
        warning('BISCAT:FileSystem', msg)
    end
else
    msg = sprintf('Invalid file path or name: "%s"', file);
    warndlg(msg,'Warning')
    warning('BISCAT:InputParameters', msg)
end


function run_sim_Callback(hObject, eventdata, panelNum)
% launch the simulation using current settings

tic         % time execution

% access and reset global sim variable (NOT SURE IF THIS IS NECESSARY IF WE USE ASSIGNIN()
%global sim
%sim = struct;

% retrieve GUI data fields
GUI = guidata(hObject);

% update status
msg1 = sprintf('Running simulation...');
GUI.callbacks.help.set_status(GUI.handles,msg1);
disp(msg1);

% attempt to load input file if not already in memory
if ~isfield(GUI,'data') || isempty(GUI.data.timeseries)
    file = get(GUI.handles.tab1.input.file_name,'String');       % get filename from text box
    if exist(file,'file')
        ts = GUI.callbacks.help.load_data(file);
        if length(ts.data) > 1
            GUI.data.timeseries = ts;
            guidata(hObject, GUI);
            set(GUI.handles.tab1.input.file_name,'String',sprintf('%s',file));
            GUI.callbacks.help.set_status(GUI.handles,'Successfully loaded input signal');
        else
            msg = sprintf('Could not load time series data from file "%s"', file);
            warndlg(msg,'Warning')
            warning('BISCAT:FileSystem', msg)
        end
    else
        msg = sprintf('Invalid file path or name: "%s"', file);
        warndlg(msg,'Warning')
        warning('BISCAT:InputParameters', msg)
        return
    end
end

cfg = GUI.callbacks.help.get_config(GUI.handles);

% execute simulation program here
% try
    sim = runBiscatMain(cfg, GUI.data.timeseries, panelNum);
    msg2 = sprintf('Completed simulation in %.3f seconds', toc);
    disp(msg2);
    GUI.callbacks.help.set_status(GUI.handles,msg2);
    
    assignin('base','sim',sim); % assign sim to base workspace

% catch
%     msg3 = 'Simulation failed to run...';
%     GUI.callbacks.help.set_status(GUI.handles,msg3);
%     rethrow(lasterror)
% end

