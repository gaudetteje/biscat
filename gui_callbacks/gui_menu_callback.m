function h = gui_menu_callback

h.open = @menu_open_Callback;
h.save = @menu_save_Callback;
h.about = @menu_about_Callback;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Menubar callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
% File menu

function menu_open_Callback(hObject, eventdata)
% Load saved parameter settings

% Get handles
GUI = guidata(hObject);

% Select the file to load
[filename, pathname] = uigetfile( '*.mat', 'Select a BISCAT Configuration File', 'config.mat');
if ~filename
    return
end

% Load settings from MAT file and overwrite existing config data
file = fullfile(pathname,filename);
try
    load(file, 'cfg');
    GUI.callbacks.help.set_config(GUI.handles, cfg);
    GUI.callbacks.help.set_status(GUI.handles, 'Successfully loaded settings from "%s"', file);
catch
    GUI.callbacks.help.set_status(GUI.handles, 'ERROR: Could not successfully load configuration file "%s"', file);
    rethrow(lasterror)
end


function menu_save_Callback(hObject, eventdata)
% Saves current parameter settings to file

% Get handles
GUI = guidata(hObject);

% Select the file to save
[filename, pathname] = uiputfile( '*.mat', 'Select a BISCAT Configuration File', 'config.mat');
if ~filename
    return
end
file = fullfile(pathname,filename);

% Get current configuration as structure
cfg = GUI.callbacks.help.get_config(GUI.handles);

% Save settings to MAT file
try
    save(file,'cfg');
    GUI.callbacks.help.set_status(GUI.handles,'Successfully saved settings to "%s"',file);
catch
    warning('BISCAT:FileSystem', 'Could not save configuration file "%s"', file)
    GUI.callbacks.help.set_status(GUI.handles,'ERROR: Could not save settings to "%s"',file);
end


% % --------------------------------------------------------------------
% % Edit menu
% 
% function menu_status_Callback(hObject, eventdata)
% % toggles status bar
% 
% res = get(handles.status_bar,'Visible');
% figure_pos = get(handles.figure1,'Position');
% status_pos = 0; %get(handles.status_bar,'Position')
% switch res
%     case 'on'
%         set(gcbo,'Checked','off')
%         set(handles.status_bar,'Visible','off')
%         figure_pos(4) = figure_pos(4) + status_pos;
%         set(handles.figure1,'Position',figure_pos);
%     case 'off'
%         set(gcbo,'Checked','on')
%         set(handles.status_bar,'Visible','on')
%         figure_pos(4) = figure_pos(4) - status_pos;
%         set(handles.figure1,'Position',figure_pos);
%     otherwise
%         warning('BISCAT:InputParameters', 'Assertion error in menu_status_Callback')
% end
% 

% -------------------------------------------------------------------
% Help menu

function menu_about_Callback(hObject, eventdata)
% display program contact information

msgbox({'Brown University',...
        'Dr. James Simmons Lab',...
        'Providence, RI',...
        ' ',...
        'BiSCAT v0.5',...
        'The Binaural Spectrogram Correlation and Transformation Simulator',...
        ' ',...
        'Author:',...
        'Jason Gaudette',...
        ' ',...
        'Jason_Gaudette@brown.edu',...
        'Jason.E.Gaudette@navy.mil',...
        },'About BiSCAT');

