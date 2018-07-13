function signal_maker
%%  send in the jim modified singal into coch bank after saving it as wav



% ts.timestamp = datetime('now');
% ts.fs = fs;
% ts.time =  (1/fs)*[1:length(time_signal)]';
% ts.data = time_signal;

% save('smoothed_3_echoes.mat','ts')

%% turn the non-modified ts.data into wav and then send to coch bank
% raw_ts = load('prejim_3_echoes.mat')
% prejim_data = raw_ts.ts.data;
% prejim_fs = raw_ts.ts.fs;
% audiowrite('prejim_3_echoes.wav',prejim_data,prejim_fs) % data clipped warning
% clf
%% 2 HARMONICS BABY

[raw_signal, fs]  = audioread('bat_single_harm_list.wav');
% name = strcat('forward_right_ear.mat');

%plot(broad_signal)
% [echo_signal, fs]  = audioread('dolph_2h_echoes.wav');
% plot(signal)
% shg

%[time_signal, fs_h]  = audioread('bat_3glint_b.wav');
%
broad_signal = raw_signal([1:1712]);

%% Single harmonics

%  Single harmonic bat sounds
index = [1970	4308
    4308	6450
    6450	8.81E+03
    8.81E+03	1.08E+04
    1.08E+04	1.31E+04
    1.31E+04	1.53E+04
    1.53E+04	1.78E+04
    1.78E+04	2.06E+04
    2.06E+04	2.32E+04
    2.32E+04	length(raw_signal)];


% ts.data = [broad_signal;zeros(ceil(.3*length(signal)),1)];  % time_signal(1:10000); % padded_time_signal;
% ts.time =  (1/fs)*[1:length(ts.data)]';
% ts.timestamp = datetime('now');
% ts.fs = fs;

%save(name ,'ts')
% pause(.1)

hz_name = [9,18,26,35,70,100,200,300,500,700];
for iji = 1:length(hz_name)
    hz_name(iji)
    signal = [broad_signal;raw_signal(index(iji,1):index(iji,2))];
    padded_time_signal = [signal;zeros(7000-size(signal,1),1)];
    ts.data = padded_time_signal; % time_signal(1:10000); % padded_time_signal;
    ts.time =  (1/fs)*[1:length(ts.data)]';
    
    ts.timestamp = datetime('now');
    ts.fs = fs;
    plot(padded_time_signal)
    shg
    
    % save .mat
    %     name = strcat('bat_1h_',num2str(hz_name(iji)),'.mat');
    % save(name,'ts')
    
   %  save .wav
        name = strcat('bat_1h_',num2str(hz_name(iji)),'.wav');
        audiowrite(name ,padded_time_signal,fs)
    
    close all
    
end
end

% % % %%  Bat sounds
% % % % index = [2601,4936;...
% % % %     4936,	7588;...
% % % %     7588,	1.01E+04;...
% % % %     1.01E+04,	1.26E+04;...
% % % %     1.26E+04,	1.51E+04;...
% % % %     1.51E+04,	1.76E+04;...
% % % %     1.76E+04,	2.03E+04;...
% % % %     2.03E+04,	2.29E+04;...
% % % %     2.29E+04,	2.57E+04;...
% % % %     2.57E+04,	length(echo_signal)];
% % %
% % % %%  Dolphin sounds
% % % % index = [1983,	4646;...
% % % % 4646,	7434;...
% % % % 7434,	9.74E+03;...
% % % % 9.74E+03,	1.23E+04;...
% % % % 1.23E+04,	1.46E+04;...
% % % % 1.46E+04,	1.74E+04;...
% % % % 1.74E+04,	2.01E+04;...
% % % % 2.01E+04,	2.26E+04;...
% % % % 2.26E+04,	2.55E+04;...
% % % % 2.55E+04,	length(echo_signal)];
% % %
% % %
% % % %% BAT SPECIAL
% % % % index = [2097	4493
% % % % 4493	6843
% % % % 6843	9194
% % % % 9194	1.11E+04
% % % % 1.11E+04	1.27E+04
% % % % 1.27E+04	1.50E+0495
% % % % 1.50E+04	length(signal)];
% % %
% % % %% Bat Doppler Special
% % % index = [2081	4274
% % %     4274	6427
% % %     6427	8553
% % %     8553	1.11E+04];
% % %
% % % %%
% list_name = [''w_lpf '', 's_lpf';'6us';'w_uw_dop';'s_uw_dop';'1000us';'2000us']);