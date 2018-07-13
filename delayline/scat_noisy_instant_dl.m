function [activation_snapshot] = scat_noisy_instant_dl(final_acoustic_data, sample_pt,num_ch,jitter_band_model,offset_cmf)
% INPUT:
%
%
% OUTPUT:
%  
%
% DESCRIPTION:
% Run this every time unit so get an updated delay line activation tracker
% updates snapshot of what has been heard so it can be ran by model at
% every sample point processing resolution 


% For every freq channel
activation_snapshot = zeros(num_ch,jitter_band_model);
for k = 1:num_ch
    %% grab random noise from desired cmf
    cmf_index    = randi([1 size(offset_cmf,1)],1); % generate 1 random number from 1 to 100
    noise_offset = offset_cmf(cmf_index);
    noise_offset = 0; % rn no noise yeah 
    
    %% add noise as off set 
    activation_snapshot(k,1+noise_offset) = final_acoustic_data(k,sample_pt); % this is indexing first of spectral array since that is where I am encoding the gnd truth
end

activation_snapshot;
end

