function delay_baseline = scat_baseline_id(plot_opt_pre,sample_pt, critical_band,echo_count,active_chirp_channels,...
    active_chirp_times_vector,num_ch,freq_ch,pre_proc_running_act, vertical_offset,raw_running_act,speed_demon)
% INPUT:
%
%
% OUTPUT:
%
%
% DESCRIPTION:
% Look for best match of chirp at lower freq below critical band and set
% this as delay_baseline
%

instant_cell_index = sample_pt;% tap_rate*(sample_pt-1)+1:tap_rate*sample_pt;
active_channels = active_chirp_channels(active_chirp_channels~=0);

% Grab slope run spacing:
% Last active delay line
% delay_line = fliplr(pre_proc_running_act(freq_ch,1:instant_cell_index)); % this flips the array so broadcast comes first
% [delay_snapshot_vector, earliest_cell,activated_cells] =
% scat_delay_coincidence_detector(plot_opt_pre,sample_pt,delay_line, freq_ch,num_ch,vertical_offset,speed_demon);
% last_ch_on_time = max(activated_cells);
%
% % One previous from last delay line
% prev_index =  active_channels(find(active_channels==freq_ch)-1);
% delay_line = fliplr(pre_proc_running_act(prev_index ,1:instant_cell_index)); % this flips the array so broadcast comes first
% [delay_snapshot_vector, earliest_cell,activated_cells] =
% scat_delay_coincidence_detector(plot_opt_pre,sample_pt,delay_line, freq_ch,num_ch,vertical_offset,speed_demon);
% second_to_last_on_time = max(activated_cells);
%
% % the difference:
% best_interchirp =  last_ch_on_time - second_to_last_on_time; % FIX INTERCHIRP DELAY MAY BE ISSUE

% Assign best delay estimate to last CH which is this last one we flagged
delay_line = fliplr(raw_running_act(freq_ch,1:instant_cell_index)); % this flips the array so broadcast comes first
[delay_snapshot_vector, earliest_cell,activated_cells] =  scat_delay_coincidence_detector(plot_opt_pre,sample_pt,delay_line, freq_ch,num_ch,vertical_offset,speed_demon);


delay_baseline = max(delay_snapshot_vector); % i say max to get longest from chirp, makes sense once more than 1 echo
flat_khz = vertical_offset(freq_ch);
disp(sprintf('BASELINE ID SAYS: Echo #%d First delay baseline of %d GRABBED, detected at %d kHz, index of  CH #%d',echo_count,delay_baseline,flat_khz,freq_ch))


flat_index = freq_ch;
for freq_index = freq_ch:-1:critical_band
    if any(freq_index== active_channels(2:end-1)) % if the given ch is on
        
        
        % Check slope's run from previous of chirp to echo
        %         prev_index =  active_channels(find(active_channels==freq_index)-1);
        %         interchirp =  active_chirp_times_vector(freq_index) - active_chirp_times_vector(prev_index); % FIX INTERCHIRP DELAY MAY BE ISSUE
        %         disp(sprintf('checked freq index %d grabbed interchirp %d',freq_index,interchirp))
        
        
        %         if interchirp < best_interchirp % difference closer then assign as flat_index
        %             disp('BETTER DELAY DETECTED, slope based')
        %             delay_line = fliplr(pre_proc_running_act(freq_index,1:instant_cell_index)); % this flips the array so broadcast comes first
        %             [delay_snapshot_vector, earliest_cell] =  scat_delay_coincidence_detector(plot_opt_pre,sample_pt,delay_line, freq_ch,num_ch,vertical_offset,speed_demon)
        %             delay_baseline = max(delay_snapshot_vector);
        %             flat_index = freq_index;
        %         end
        
        % Try just minimizing delay
        delay_line = fliplr(raw_running_act(freq_index,1:instant_cell_index)); % this flips the array so broadcast comes first
        [delay_snapshot_vector, earliest_cell,activated_cells] =  scat_delay_coincidence_detector(plot_opt_pre,sample_pt,delay_line, freq_ch,num_ch,vertical_offset,speed_demon);
        
        % dont even check ch with ATL that hevent happened yet 
        if length(delay_snapshot_vector) == echo_count
            % Grab appropriate delay 
            if length(delay_snapshot_vector) == 1
                new_delay = delay_snapshot_vector;
            else 
                new_delay = delay_snapshot_vector(echo_count);
            end
            
            % compare delay 
            if new_delay <delay_baseline
                flat_index = freq_index;
                flat_khz = vertical_offset(flat_index);
                delay_baseline = new_delay;
                disp(sprintf('BASELINE ID SAYS: Echo #%d Better min delay-based baseline of %d DETECTED, detected at %d kHz, index of  CH #%d',echo_count,delay_baseline,flat_khz,flat_index))
            end
        end
        
    end
end


% Update User:
flat_khz = vertical_offset(flat_index);
disp(sprintf('BASELINE ID SAYS: Echo #%d Delay Baseline of %d DEFINED, detected at %d kHz, index of  CH #%d',echo_count,delay_baseline,flat_khz,flat_index))
% pause(1)

end