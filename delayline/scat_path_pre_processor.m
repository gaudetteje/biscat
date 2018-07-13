function [active_chirp_ch_vector,active_chirp_times_vector,delay_baseline,running_act_mask,echo_count,current_echo_complete,delay_data_array] = ...
    scat_path_pre_processor(plot_opt_cross,creature_file,plot_opt_pre,pre_proc_running_act,raw_running_act, sample_pt, num_ch,line_length,...
    active_chirp_ch_vector,active_chirp_times_vector,jitter_band_model,...
    alt_band_model, delay_baseline,echo_count,running_act_mask,current_echo_complete,critical_band,crit_band_index,...
    vertical_offset,standard_time,speed_demon,fs,delay_data_array)

% INPUT:
%
%
% OUTPUT:
%
%
% DESCRIPTION:
% Sweep through all freq channels and send to appropraite procesing path.
% It keeps track of elements that are part of echo, keeps track of echo
% completion, is major brains of model 


neuron_train     = [line_length:-1:1]; % goes right to left so that means indexing for cells need to go 1 to 100
whole_chirp_slope = zeros(num_ch,1);
running_delay_est_log = [];
%disp(sample_pt)
for freq_ch = num_ch:-1:1
    ch_khz =  vertical_offset(freq_ch); % this turns indexing into actually log scaled hz ticks

    %% Find Activated pts on delay line attitbuted to chirp and delays for each delay line
    instant_cell_index = sample_pt;% tap_rate*(sample_pt-1)+1:tap_rate*sample_pt;
    
    delay_line = fliplr(raw_running_act(freq_ch,1:instant_cell_index)); % this flips the array so broadcast comes first
    num_sounds = numel(delay_line(delay_line == 1));
    
    [delay_snapshot_vector, earliest_cell,activated_cells] = scat_delay_coincidence_detector(plot_opt_pre,sample_pt,delay_line,freq_ch, num_ch,vertical_offset,speed_demon);
    running_delay_est_log   = [running_delay_est_log ; max(delay_snapshot_vector)];
    
    deconv_elgibility_vector = 0;
    
    if num_sounds == 1 & ~any(freq_ch == (active_chirp_ch_vector(active_chirp_ch_vector~=0)))
        % Once first sound is registered i.e. le chirp and not already recorded, do this
        % GRAB CHIRP INFO - IF CHIRP: Grab active Ch and time information
        % this grabs our rise and run for backwards difference instantaneous derivative of braodcast chirp
        active_chirp_ch_vector(freq_ch)     = freq_ch; % Keep track of active CH in chirp sound, rise of slope for chirp
        active_chirp_times_vector(freq_ch)           = earliest_cell ;% Basis of slope, is run of slope for chirp ===
        %disp('Listening to chirp')
    end
    
    if num_sounds > 1
        if current_echo_complete == 0 % if chirp done, but echo in question is not
            active_channels = active_chirp_ch_vector(active_chirp_ch_vector~=0);
            %Keep listening for end of echo, keep sending off delays to histogram
            % 1) Update user:
            % disp(sprintf('Current %dth Echo is not complete, currently working on %d kHz, index of  %d',echo_count+1,ch_khz,freq_ch))
            
            % 2) Send all detected delays off to histogram, SPECT CROSS will deal with weighting and thresholding
            % AKA do nothing special here
            
            % 2.5) Do Clutter detection here once you revamp gnd truth neural spectogram
            
            % 3)  ECHO COMPLETION DETECTION DONE HERE
            if ~isempty(active_channels)
                %                 disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
                %  freq_ch
                %  echo_count
                %disp(sprintf('PRE-PROCESSOR SAYS: NUm Sounds is %d',num_sounds))
                %active_channels(1)
                % (length(find((freq_ch == active_channels(1:4))==1)) >=2)
                if any(freq_ch == active_channels(1:5)) & num_sounds>echo_count+1
                    % 3.A) Update echo count & flag as complete ,update user
                    echo_count = echo_count+1;
                    current_echo_complete = 1;
                    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
                    disp(sprintf('PRE-PROCESSOR SAYS: Hey, Echo #%d completed at %d kHz CH, index of  %d',echo_count,ch_khz,freq_ch))
                    
                    
                    
                    % 3.B) PLot Baseline at time 0
                    for k = num_ch:-1:1
                        act_index = find(raw_running_act(k,:)==1);
                        if ~isempty( act_index)
                            s4 = subplot(2,3,4);
                            hold on
                            plot(0, vertical_offset(k)/10^3,'go','MarkerSize',2,'LineWidth',1);
                            
                            axis([standard_time(1)*10^3 standard_time(end)*10^3 0 1.2*vertical_offset(end)/10^3])
                            s4.FontSize = 16;
                            title('Dechirped Neural Spect','FontSize', 20);
                            ylabel('Center Frequency CH (Hz)','FontSize', 20)
                            xlabel('Elapsed Time (s)','FontSize', 20)
                            hold on
                        end
                    end
                    
                    %                     % 3.C) Grab flat echo delay baseline here:
                    %                     delay_baseline = scat_baseline_id(plot_opt_pre,sample_pt, critical_band,echo_count,active_chirp_ch_vector,...
                    %                         active_chirp_times_vector,num_ch,freq_ch,pre_proc_running_act, vertical_offset,raw_running_act,speed_demon);
                    
                end
            end
            
        elseif current_echo_complete ==1 %if chirp done, and echo is question is done, determine things
           delay_file = strcat(creature_file,'_delay.mat')
            save(delay_file,'-v7.3')
            [current_echo_complete,null_ch_list] = scat_echo_processor(creature_file,echo_count,plot_opt_pre,raw_running_act,...
                num_ch,sample_pt,freq_ch,vertical_offset,speed_demon, standard_time,line_length,fs);
            
            % Save delay estimate at echo completion
            clearvars -except delay_data_array delay_file
            save(delay_file,'-v7.3','delay_data_array')
            return
        end
        % running_echo_delays = sort(delay_snapshot_vector,'descend') % sorts from high to low
        
    end
    
    
    %% Deal with Plotting & Gifs
    if plot_opt_pre == 1
        %pause(.1) %  pause so you can see s2 horixontal bar not on
        cla
        delete(cc_channel)
    end
    
    
end

% SEND APPROPRIATE TO SPECT CROSS CORRELATION

% % nonzero_running_delay_est_log = running_delay_est_log(running_delay_est_log~=0);
% % snap_hist = histogram(nonzero_running_delay_est_log,'BinLimits',[0,line_length],'BinWidth',1,'Visible','off'); % i think bins need to be width 1 to facilitate stuff
% % delay_strength = snap_hist.Values;
% % if ~isempty((find(delay_strength~=0)))
% %     delay_data_array((delay_strength~=0),sample_pt) = delay_strength(delay_strength~=0)';
% % end

% if sample_pt >= .032/(2*10^-6)
%     clearvars -except delay_data_array
%     save('current_delay_data.mat','-v7.3')
% end

scat_spect_cross(plot_opt_cross,pre_proc_running_act, sample_pt, num_ch,line_length,...
    vertical_offset, running_act_mask,echo_count,standard_time,running_delay_est_log,fs,alt_band_model)% there is pause in cross, but only done once per sample pt

end
