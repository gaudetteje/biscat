function  [gnd_corr] = performance_eval(standard_time, final_acoustic_data, fs,f_max, f_min,raw_data, perf_plot_opt)
% Compare matlab cross correlation to our output's final 2d image of delay_est and interference locations

%Matlab https://www.mathworks.com/help/signal/ref/xcorr.html

% % Look for quiet areas to distinguish sounds from each other
% initialization_indices = [0];
% silence_thres = []; % silence across all ch
% while
%
% end

% Plot Orginal Sound
cutoff = .0036;
chirp = [raw_data(1:find(standard_time == cutoff));zeros(size(raw_data(find(standard_time == cutoff)+1:end)))];
echo = [zeros(size(raw_data(1:find(standard_time == cutoff))));raw_data(find(standard_time ==cutoff)+1:end)];

[gnd_corr, lags] = xcorr(raw_data);
[~,I] = max(abs(gnd_corr>0));
gnd_delay = lags(I); 

if perf_plot_opt == 1
    figure(400)
    plot(standard_time/fs,raw_data)
   % plot(standard_time/fs,[chirp echo])
    %legend('Original Broadcast','Echo')
   % title('40dB HFM Simulated Acoustic Signal with 30µs, 45µs, and 60µs Spatial Glint Separation')
   title ('Dolphin Click Signal Containing Broadcast w/ 3 Echoes')
    xlabel('Time (s)')
    ylabel('Acoustic Sound Pressure (Pa)')
    
    figure(401)
    plot(lags/fs,gnd_corr)
    gnd_truth_corr = max(gnd_corr(gnd_corr>0)); 
%     corr_time = lags(lag>0)*fs; 
%     plot(core_time*ones()), gnd_truth_corr); 
    shg
end



end