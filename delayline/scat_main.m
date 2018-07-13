function scat_main(creature_mode,creature_file,creature_file_directory,run_biscat_opt,save_gif_opt)
% INPUT:
% Takes wav
%
% OUTPUT:
% Makes bmm file, transduced file, delay estimate file, intereference file
%
% DESCRIPTION:
% GND TRUTH ACOUSTIC DATA -> NEURAL DELAY LINE INTERFACE -> SCAT BIOSONAR PROCESSOR
%

%% DO SOME PRE-PROCESSING SO ITS 1/2 RECTIFIED AND GAIN IS ALTERED
file_raw = strcat(creature_file,'_bmm');

% run_biscat_opt = 0;
perf_plot_opt  = 1;  % shows tiem domain signal

file = strcat(file_raw,'.mat');
file_main = strcat(file_raw,'_transduced','.mat');

if run_biscat_opt == 1
    %Take WAV and run through Jason's cochlea bank script
    scat_cochlea_stage(creature_mode,creature_file,creature_file_directory);
    
    % ##### REMEMBER TO CHANGE WIPE OPTION FREQ RANGE WHEN DOING DOPHIN ####
    wipe_opt = 1;
    wipe_ch_hz = (10^3)*[20,25;95,100];
    %    wipe_ch_hz = (10^3)*[0,40;190,200];
    scat_pre_plot_opt = 0;
    [standard_time, final_acoustic_data, fs,f_max, f_min,raw_data,alt_band_model,vertical_offset] = scat_pre_dl_activation(wipe_opt,wipe_ch_hz,file,scat_pre_plot_opt);
    
    %%  perform Ground Truth Cross Correlation of Chirp-Echo Pair
%     [gnd_truth_delay] = performance_eval(standard_time, final_acoustic_data, fs,f_max, f_min,raw_data,perf_plot_opt);
%     time_stamp = datetime('now');
%     
    
    save(file_main)
else
    load(file_main)
end

%% PLOTTING OPTIONS ARE ALL HERE
eval_opt =1 ;
if eval_opt == 0
    scat_pre_plot_opt =0; % shows transduction panel
    
    plot_opt_cross = 0;
    panel_axis_setup = 1; % sets up 9 subplot panel interface and names subplot sand axis
    scat_main_plot_hard_opt = 0; % tells sample pt loop to listen
else % this option does gifs
    close all
    scat_pre_plot_opt = 1; % shows transduction panel
    
    plot_opt_cross = 1;
    panel_axis_setup = 1; % sets up 9 subplot panel interface and names subplot sand axis
    scat_main_plot_hard_opt = 1; % tells sample pt loop to listen
end

speed_demon = 1;
plot_update_rate = 400;
%% Model General Parameters:
num_ch          = size(final_acoustic_data,1);
line_length     = size(standard_time,1)-1;

debug_downscale = 1; % over haul processing so it uses this downscael as a downscale in processing sampling
proc_spacing    = 50;%50; % sampling rate of pre processing

delay_line_length_real             = standard_time(end);
delay_line_length_model        = line_length/debug_downscale; % is .1msec

delay_line_res_real             = delay_line_length_real/(delay_line_length_model); % 10sec
delay_line_res_model         = (delay_line_res_real/delay_line_length_real)*delay_line_length_model;

gnd_res_real        = delay_line_res_real; % this should be 2usec come on
gnd_res_model    = (gnd_res_real/delay_line_length_real)*delay_line_length_model;

% Defining center freqeuncies on log scale
% this now is tied to coch.Fc

% Baseline Delay ID Parameters
critical_band_khz = 40e3;
[a crit_band_index] = min(abs(vertical_offset-critical_band_khz));
critical_band = vertical_offset(crit_band_index); % real_freq_res*(num_ch+1-critical_band_khz); % NEED TO DEFINE THIS ONCE I GET TO BASELINE ID

% Jitter Parameters
jitter_band_real           = 2*gnd_res_real; % 2 taps ahead max jitter
jitter_band_model       = ceil((jitter_band_real /delay_line_length_real)*delay_line_length_model); % this is  noise margin in terms of element number

alt_band_real             = 30*jitter_band_real; % Grabbed from Jason's fb_genlatency(x,fs)
%alt_band_model         = 270; % (alt_band_real/delay_line_length_real)*delay_line_length_model; %took avg of the deltau coming out of jason's per ch and then avg what we saw
% tehre were longer

x = 0:jitter_band_model-1;
off_weights   = ceil(100*poisspdf(x,1));

offset_cmf = [];
for c = 0:jitter_band_model-1
    offset_cmf     = [offset_cmf; (c)*ones(off_weights(c+1),1)];
end

%% Give birth to user interface
gifname = 'asa_panel.gif';
% main_plot_opt = 1;
if panel_axis_setup == 1
    clf
    % Birth figure for model
    fig1 = figure(1);
    set(fig1, 'Position', [20 20 1500 900]) % EDIT THIS WHEN YOU GET TO DESKTOP TOMRROW
    % set(fig1, 'Position', [-1890 117 1800 984]) % EDIT THIS WHEN YOU GET TO DESKTOP TOMRROW - 2nd screen
    fig1.Name = 'SCAT BIOSONAR PROCESSOR MAIN';
    shg
    
    % Birth Transduced gnd truth data
    s1 = subplot(2,3,1);
    cla(s1)
    s1.FontSize = 20;
    title('Neural Data Gnd Truth','FontSize', 20)
    ylabel('Frequency (kHz) ','FontSize', 20)
    xlabel('Standard Time (msec) ','FontSize', 20)
    axis([standard_time(1)*10^3 standard_time(end)*10^3 0 1.2*vertical_offset(end)/10^3])
    
    hold on
    %     filename = 'sample_trans_red.gif';
    for k = num_ch:-1:1
        if ~isempty(final_acoustic_data(k,:))
            % display(sprintf('Fc Ch  = %d',vertical_offset(k)));
            nonzero_time = standard_time(logical(final_acoustic_data(k,:)));
            h = plot(nonzero_time*10^3, vertical_offset(k)/10^3*ones(size(nonzero_time)),'ko','MarkerSize',2);
            if ~isempty(h)
                h.Color = [0.6350    0.0780    0.1840];
            end
            %             frame = getframe(1);
            %             im = frame2im(frame);
            %             [imind,cm] = rgb2ind(im,256);
            %             if k == num_ch;
            %                 imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
            %             else
            %                 imwrite(imind,cm,filename,'gif','WriteMode','append');
            %             end
        end
    end
    hold off
    
    % Birth Processed Generated Neural Spect (WILL BE UPDATED PER SAMPLE PT)
    s2 = subplot(2,3,2);
    s2.FontSize = 20;
    title('Neural Delay Line','FontSize', 20)
    xlabel('Elapsed Time (msec)','FontSize', 20)
    ylabel('Frequency (kHz) ','FontSize', 20)
    
    axis([standard_time(1)*10^3 standard_time(end)*10^3 0 1.2*vertical_offset(end)/10^3])
    
    % Birth Running Delay Estimate from Processed Data
    s3 = subplot(2,3,3);
    s3.FontSize = 16;
    title('Running Delay Estimate','FontSize', 20)
    ylabel('Delay Est. (msec)','FontSize', 20)
    xlabel('Elapsed Time (msec) ','FontSize', 20)
    axis([0 standard_time(end)*10^3 0 standard_time(end)*10^3])
    
    % Birth Dechirped Neural Data w/ ALT Detected CH
    s4 = subplot(2,3,4);
    s4.FontSize = 16;
    title('Dechirped Neural Spectrogram','FontSize', 20);
    xlabel('Elapsed Time (msec)','FontSize', 20)
    ylabel('Frequency (kHz) ','FontSize', 20)
    
    axis([standard_time(1)*10^3 standard_time(end)*10^3 0 1.2*vertical_offset(end)/10^3])
    
    % Current Echo Interference 2D Image
    s5 = subplot(2,3,5);
    cla(s5)
    hold on
    s5.LineWidth = 1.5;
    s5.FontSize = 16;
    title('Deconvolution Network','FontSize', 20)
    ylabel('Frequency (kHz) ','FontSize', 20)
    xlabel('Null Seperation (kHz)','FontSize', 20)
    
    
    
    seperation_hz = zeros(size(vertical_offset,1)-1,1);
    for u = 2:1:size(vertical_offset,1)
        seperation_hz(u-1) = (vertical_offset(u)-vertical_offset(1))/10^3;
    end
    
    axis([seperation_hz(1) seperation_hz(end) vertical_offset(1)/10^3 1.2*vertical_offset(end)/10^3])
    
    %Birth Histogram that ALT DEtection is based on
    s6 = subplot(2,3,6);
    s6.LineWidth = 1.5;
    s6.FontSize = 16;
    title('Interefence Pattern Image','FontSize', 20)
    ylabel('Image Strength','FontSize', 20)
    xlabel('Null Seperation (kHz)','FontSize', 20)
    axis([seperation_hz(1) seperation_hz(end) 0 1])
    hold off
    
end


%% NOW IMPLEMENT SAMPLING TIME:
% Freq Tuned Delay Line Arrays? whut does this mean stephanie??
raw_running_act          = zeros(num_ch,line_length); % raw activation
pre_proc_running_act = zeros(num_ch,line_length); % raw activation
running_act_mask       =  zeros(num_ch,line_length); % raw activation

active_chirp_ch_vector = zeros(num_ch,1);
active_chirp_times_vector = zeros(num_ch,1);
delay_data_array = zeros(line_length,line_length);
current_echo_complete = 0;
echo_count = 0;
delay_baseline = 0;
running_delay_est_log = [];
% TURN ON / OFF PLOTTING SO IT GOES FASTER


scat_main_plot_opt = 0; % dont change this ever
for sample_pt = 1:1:line_length-jitter_band_model  % ok ok so grad world every t but only process in debug res
    % sample_pt
    if mod(sample_pt,plot_update_rate) == 0 & scat_main_plot_hard_opt == 1
        scat_main_plot_opt = 1; % at the beginning of the "100*n"-th sample pt, turn ON plotting option
    end
    
    %% UPDATE ACTIVATION SNAPSHOT OF REAL WORLD
    % Add a time slider in gnd truth to show what temporal frame we have send into neural processing
    if scat_main_plot_opt == 1 & scat_main_plot_hard_opt == 1
        subplot(2,3,1);
        hold on
        slider1 = plot(standard_time(sample_pt)*ones(num_ch,1)*10^3,vertical_offset/10^3,'b','LineWidth',1);
        hold off
    end
    
    % Generate intitial spike activation - needs to be totally replotted every time sample frame since it was erased to demo progression:
    [activation_snapshot] = scat_noisy_instant_dl(final_acoustic_data, sample_pt,num_ch,jitter_band_model,offset_cmf); % this is sample+pt+noise up 1-10, 11-20 its coming out like that is good
    
    % Progress snapshot in time  so newer is located on left and older on right (VERY IMPORTANT)
    temp_raw_sum = raw_running_act(:,1:jitter_band_model) +  fliplr(activation_snapshot); % this flips it
    raw_running_act(:,1:jitter_band_model) = temp_raw_sum;
    raw_running_act = logical(raw_running_act);
    
    temp_pre_proc_sum = raw_running_act(:,1:jitter_band_model) +  fliplr(activation_snapshot); % this flips it
    pre_proc_running_act(:,1:jitter_band_model) = temp_pre_proc_sum;
    pre_proc_running_act = logical(pre_proc_running_act);
    
    % Update S4
    if scat_main_plot_opt == 1 & scat_main_plot_hard_opt == 1
        for k = num_ch:-1:1
            act_index = find(raw_running_act(k,:)==1);
            if ~isempty( act_index)
                s2 = subplot(2,3,2);
                hold on
                plot(standard_time(act_index)*10^3, vertical_offset(k)/10^3*ones(size(standard_time(act_index))),'bo','MarkerSize',2,'LineWidth',1);
                title({'Neural Delay Line';sprintf( ' Time Elapsed = %s (msec)', num2str((sample_pt/fs)*10^3))},'FontSize', 20)
                xlabel('Elapsed Time (msec)','FontSize', 20)
                ylabel('Frequency (kHz) ','FontSize', 20)
                axis([standard_time(1)*10^3 standard_time(end)*10^3 0 1.2*vertical_offset(end)/10^3])
                
                hold off
            end
        end
    end
    
    
    %
    %     %     % NEURAL SCAT INTERFACE - outputs flipped backward array
    %     %     % Freq Tuned Delay Line Arrays
    %     %     instant_spect_array = scat_dl_activation(final_acoustic_data);
    %     %     plot(instant_spect_array)
    %     %
    %     %     %  Perform SCATBiosonar Process on data flowing through delay lines
    %     %     [delay_estimates, target_perception] = scat_biosonar_processor(instant_spect_array);
    %
    
    %% PREPROCESS EVERY SNAPSHOT TO FIND OUT WHICH SCAT PATH TO SEND IT TO
    proc_pt_vector = [proc_spacing:proc_spacing:line_length -jitter_band_model-proc_spacing];
    if any(sample_pt == proc_pt_vector)
        plot_opt_pre = 0; % <- this turns on coidincicdence detectors on later on, so dont plot dis
        [active_chirp_ch_vector,active_chirp_times_vector,delay_baseline,running_act_mask,echo_count,current_echo_complete,delay_data_array] = ...
            scat_path_pre_processor(plot_opt_cross,creature_file,plot_opt_pre,pre_proc_running_act,raw_running_act, sample_pt, num_ch,line_length,...
            active_chirp_ch_vector,active_chirp_times_vector,jitter_band_model,...
            alt_band_model, delay_baseline,echo_count,running_act_mask,current_echo_complete,critical_band,crit_band_index,...
            vertical_offset,standard_time,speed_demon,fs,delay_data_array);
    end
    
    %% Take care of progression from right to left and then sample next standard time sound (VERY IMPORTANT)
    running_cell_index = 1:sample_pt;
    shifted_cell_index   = running_cell_index+1; % gnd_truth_width+1:sample_pt+1*gnd_truth_width;
    
    pre_proc_running_act = raw_running_act.*~running_act_mask; % running mask has 1 as a flag for ALT points, and i only want to pass non-ALT, right?
    pre_proc_running_act(:,shifted_cell_index) = pre_proc_running_act(:,running_cell_index);
    
    raw_running_act(:,shifted_cell_index)     = raw_running_act(:,running_cell_index);
    running_act_mask(:,shifted_cell_index) = running_act_mask(:,running_cell_index);
    
    
    
    %% HOUSE KEEPING
    % Every 100 sample pts
    if mod(sample_pt,plot_update_rate) == 0
        %         % Update User
        % %         display(sprintf('Sample Pt #%d',sample_pt))
        % %         display(sprintf('Standard Time Elapsed #%d',standard_time(sample_pt)))
        
        %pause(.05)
        
        %
        if save_gif_opt ==1
            % Exports gif & Delete Plot Objects so they look continuous:
            frame = getframe(1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            if sample_pt == plot_update_rate;
                imwrite(imind,cm,gifname,'gif', 'Loopcount',inf);
            else
                imwrite(imind,cm,gifname,'gif','WriteMode','append');
            end
            %
            save('gif_plot.mat','gifname','cm','imind','sample_pt','plot_update_rate','im','frame')
        end
        
        
        %   load('gif_plot.mat')
        % Delete some things to refresh plots
        if scat_main_plot_opt == 1 & scat_main_plot_hard_opt == 1
            if sample_pt < line_length-1
                delete(slider1)
                cla(s2);
            end
        end
        
        scat_main_plot_opt = 0; % at the end of the "100*n"-th sample pt, turn OFF plotting option
    elseif sample_pt > ceil(.9*length(standard_time))
        pp = 0;
    end
    
    
end % end of time sampling loop

end % end of function