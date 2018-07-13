
function [running_act_mask, null_ch_list] = scat_null_id(plot_opt_pre,delay_baseline, active_chirp_channels,active_chirp_times_vector,num_ch, ...
    pre_proc_running_act,sample_pt, vertical_offset,running_act_mask,echo_count,raw_running_act,alt_band_model,freq_ch,speed_demon)
% INPUT:
%
%
% OUTPUT:
%
%
% DESCRIPTION:
%
%

instant_cell_index = sample_pt;% tap_rate*(sample_pt-1)+1:tap_rate*sample_pt;
% only look at activated channels, use most updated delay line but disreguard (n+1)th  activated pts
active_channels = active_chirp_channels(active_chirp_channels~=0); % grab the ch that are on and out in vector ====
null_ch_list = [];

for freq_index =  num_ch:-1:1
    if any(freq_index == active_channels(2:end)) % if the given ch is on
        % Look at every active delay line
        delay_line = fliplr(raw_running_act(freq_index,1:instant_cell_index)); % this flips the array so broadcast comes first
        [delay_snapshot_vector, earliest_cell,activated_cells] =  scat_delay_coincidence_detector(plot_opt_pre,sample_pt,delay_line, freq_ch,num_ch,vertical_offset,speed_demon);
        num_sounds = numel(delay_line(delay_line == 1));
        
        
        % Assign new delay but in smart way
        freq_index;
        if length(delay_snapshot_vector) >= echo_count
            new_delay = delay_snapshot_vector(echo_count);
            % Calculate where acceptable non-ALT should lie (slope-esque)
            prev_index =  active_channels(find(active_channels==freq_index)-1);
            expected_interchirp_delay =  active_chirp_times_vector(freq_index) - active_chirp_times_vector(prev_index); % FIX INTERCHIRP DELAY MAY BE ISSUE
            
            if abs(expected_interchirp_delay) >alt_band_model% bigger than ALT plus gnd res spacing, then don't consider it as continuous FM harmonic
               % prev_index =  active_channels(find(active_channels==freq_index-1)-1);
                expected_interchirp_delay = abs(expected_interchirp_delay);  % this happens at end of harmonics, so must let it be in abs form, so huge, wont be flagged 
%                 disp('fix this harmonic discontinuty problem now')
            end
            
            ch_khz = vertical_offset(freq_index);
            %disp(sprintf('NULL ID SAYS: Expected Interchirp of %d  grabbed at %d kHz, index of %d',expected_interchirp_delay,ch_khz,freq_index))
            
            % Check if new delay is greater than flat delay then oh lord, protest as ALT
            if new_delay > delay_baseline+expected_interchirp_delay
                null_ch_list = [null_ch_list;freq_index];
                disp(sprintf('NULL ID SAYS: Echo #%d Baaahhhdd CH NULL, detected at %d kHz, index of %d = %d',echo_count,ch_khz,freq_index,new_delay))
                
                
                % Flag ALT POINTS ON PLOT attempt 2, need to send out for plotting
                running_act_mask(freq_index,find(raw_running_act(freq_index,1:instant_cell_index)==1,1,'first')) = 1;
                % running_act_mask =  fliplr(running_act_mask(freq_index,1:instant_cell_index)); % even if you made the given pts logical, it was based on fliplr delay line not the indexing of running
                
                %running_act_mask(freq_index,find(pre_proc_running_act(freq_index,:)==1,1,'first')) ; % the first ten, where 1 is newest and gnd_res_model is latest
                
                
                %             %  Flag ALT pts in logical Vector
                %             deconv_elgibility_vector = 1; % the most recently added pt should nto be added
                
            end %end to ALT check
        else
            null_ch_list = [null_ch_list;freq_index];
            disp(sprintf('NULL ID SAYS: Echo #%d Baaahhhdd CH NULL, ALT happening, detected at %d kHz, index of %d = %d',echo_count,ch_khz,freq_index,new_delay))
            % running_act_mask(freq_index,find(raw_running_act(freq_index,1:instant_cell_index)==1,echo_count,'first')) = 1;
            
        end
        
        
        
    end % end to if an echo
end

end
