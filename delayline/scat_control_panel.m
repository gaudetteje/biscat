function scat_control_panel(creature_mode,run_biscat_opt,save_gif_opt)
% INPUT:
% scat_control_panel('bat',1,0)
% WAV file 
% creature_mode = type 'bat' or 'dolph',  this tells script which freq band
% to use for coch filter bank and rest f model 
% run_biscat_opt = 1 or 0, this tells model whether it needs to spend time
% sending wav into Jason's coch filter bank and then save .mat which is
% used for rest of model 
% save_gif_opt = 1 or 0, tells you whether to save panel frames as gif,
% makes processing go really really SLOW, only turn on if you need gif for
% JIm or ppt or lab  meeintg once you debugged what you wanted to change 
%
% OUTPUT:
% All the intermediary files that the SCAT Main processor makes
%
% DESCRIPTION:
% Select 1 to many wav files you would like process

%% Select the files you want to process
function_path = pwd;
addpath(genpath(strcat(function_path,filesep,'jason_code')));

[FileName_list,PathName] = uigetfile('*.wav','MultiSelect', 'on','Select the wav file you would like to send through processor');

%cd(PathName)
addpath(function_path)
addpath(PathName)




%%  Run SCAT Main for each wav
if ischar(FileName_list)
    [~, creature_file,~]= fileparts(FileName_list);
    creature_file_directory = strcat(PathName,creature_file);
    scat_main(creature_mode,creature_file,creature_file_directory,run_biscat_opt,save_gif_opt);
else
    for f = 1:length(FileName_list)
        [~, creature_file,~]= fileparts(FileName_list{f});
        creature_file_directory = strcat(PathName,creature_file);
        scat_main(creature_mode,creature_file,creature_file_directory,run_biscat_opt,save_gif_opt);
    end
end

end