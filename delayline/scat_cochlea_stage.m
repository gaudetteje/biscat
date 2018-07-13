function scat_cochlea_stage(creature_mode,creature_file,creature_file_directory)

% INPUT:
% creature_mode = type 'bat' or 'dolph',  this tells script which freq band
% to use for coch filter bank and rest f model 
% creature_file = file name for wav
% creature_file_directory = location for file name
% 
% OUTPUT:
% creates .mat file that contains "coch_steps" AKA that number of channels
% by length of signal array that is used for processing 
%
% DESCRIPTION:
% Takes GND TRUTH ACOUSTIC DATA and the bat or dolphin config file used in
% Jason's biscar cochlea module tand creates data that would be propogating
% through parallel delay lines 

% addpath( genpath ( pwd ) )
% 1)  run biscat, let it use its interface for file selection, the .mat is
% overwritten here and data is pulled out of his model at appropriate
% location

%% Make .ts
wav_file = strcat(creature_file_directory,'.wav');
[signal, fs]  = audioread(wav_file);

ts_name = strcat(creature_file,'.mat');
ts.data = [signal;zeros(ceil(.3*length(signal)),1)];  % time_signal(1:10000); % padded_time_signal;
ts.time =  (1/fs)*[1:length(ts.data)]';
ts.timestamp = datetime('now');
ts.fs = fs;

save(ts_name ,'ts')

%% Run Jason's Script
% Chose correct paramters for BMM analysis, specifically Freq Range
% to look inside of this Matlab structure data type, type 
% >> load('bat_config.mat')
% >> cfg 

if strcmp(creature_mode,'bat')
    load('bat_config.mat')
elseif strcmp(creature_mode,'dolph')
    load('dolph_config.mat') 
end

cfg.file_name = creature_file_directory;
runBiscatMain(cfg,ts);
end