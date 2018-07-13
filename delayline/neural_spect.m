function [spect_array] =  neural_spect(onset_times_vector, sweep_dur_vector,sweep_freq_vector, num_ch, line_length,real_freq_res,...
    glint_info_vector,delay_line_res_real,alt_band_model,null_buff )
% neural_spect(sweep_dur, delay, glint_delay)
% neural_spect(20, [0,10])
% INPUT:
% delay - take in vector of neural cell delay seperation b/t broadcast and
% echo. first element neeeds to be zero if you want braodcast to start at
% beginning
% glint_delay - array that has glint seperation in terms of time, and its
% index in vector will be indicative of which echo should have the delay
%
% OUTPUT:
% vector that mimics spectrogram activated freq and times, time is index,
% ch (row) is the frequency res
%
% DESCRIPTION: Ideally take in delay and glint speration delay and turn
% that into a spectrogram. This function outputs neural spectogram until
% Jason's filterbank comes in

%%  Generate continuous spectrogram an then later on, sample it:
clf
hold on
cont_spect            =  zeros(100,line_length); % as continuous of an artificial spectrogram we are working with
discrete_freq = [100:-real_freq_res:real_freq_res]; % discrete freq ch res, dependent on how many channels user wants to work with

onset_times_model = onset_times_vector/delay_line_res_real;
sweep_dur_times_model = sweep_dur_vector/delay_line_res_real;


for s = 1:size(onset_times_model,1)
    ch_flagger = zeros(num_ch,1);
    % Deal with swep duration &  onset time
    cont_time_pts   = [onset_times_model(s):onset_times_model(s)+sweep_dur_times_model(s)];
    sweep_slope     = -(sweep_freq_vector(s,1) - sweep_freq_vector(s,2))/sweep_dur_times_model(s);
    cont_sweep       = sweep_slope.*(cont_time_pts-onset_times_model(s))+sweep_freq_vector(s,1);
    
    % Deal with glint intereference
    nulls = [];
    if glint_info_vector(s) ~=0
        delta_f = 1/(glint_info_vector(s))*10^-3;
        disp(sprintf('NEURAL SPECT SAYS: FM#%d - delta_f is %d', s,delta_f))
        
        nulls = [.5*delta_f:delta_f:num_ch];
    end
    
    
    % Snap Calculated nulls to All ready freq ch sampled data so you darn see it
    null_index = [];
    if any(nulls>cont_sweep(end)) & any(nulls<cont_sweep(1))
        [~,i] = min(abs(bsxfun(@minus,nulls,discrete_freq')));
        null_index  = discrete_freq(i);
        null_index = null_index(null_index>=20); % we only want it to exist abpve 20khz
    end
    
    % Make null CH LOCATIONS SUPER GENEROUS
    generous_null_index = [];
    if ~isempty(null_index)
        for j = 1:size(null_index,2)
            generous_null_index = [generous_null_index, null_index(j)-null_buff:null_index(j)+null_buff];
        end
    end
    gg= sprintf('%d, ',generous_null_index);
    disp(sprintf('NEURAL SPECT SAYS: FM#%d - Generous Nulls are %s', s,gg))
    
    % Update Sweep Logical
    hold on
    for i = 2:size(cont_sweep,2)
        freq_pt = cont_sweep(i);
        if ch_flagger(ceil(freq_pt)) == 0
            ch_flagger(ceil(freq_pt)) = 1;
            if any(ceil(freq_pt)== generous_null_index)  
                %             j =  cont_sweep(i) ;
                %             disp(sprintf('FM#%d : Logical Index Found %f', s,j))
                cont_spect(ceil(freq_pt),cont_time_pts(i)+alt_band_model) = 1;
            else
                cont_spect(ceil(freq_pt),cont_time_pts(i)) = 1;
            end
        end
    end
    
    
    % Plot this baby
    %plot(cont_time_pts, cont_sweep,'r.');
end




%% Sample continous-like sweep and assign to number of freq channels model is alotting:
spect_array    = zeros(num_ch,line_length);

for t = 1:1:line_length % sample at 1, 21, 41, etc based on gnd_truth_width
    for k = 1:num_ch-1% sample the continuous freq sweep and put into 20 channels
        if any(cont_spect(discrete_freq(k),t) ==1) %real_freq_res*(num_ch+1-k)
            spect_array(k,t) = 1; % check this with plot
        end
    end
end



spect_array = logical(spect_array);
end