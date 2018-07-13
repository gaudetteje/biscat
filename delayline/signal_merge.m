function signal_merge() % make a .mat in the format that his are in

files = ['hfm_40dB_15us';'hfm_40dB_30us';'hfm_40dB_60us'];
for i = 1:3
    hfm_struct  = load(files(i,:));
    ts     = hfm_struct.ts;
    cfg = hfm_struct.cfg;
 
    
    fs     = ts.fs;
    f_max = cfg.coch_fmax;
    f_min = cfg.coch_fmin;
    alt_opt = cfg.coch_mode;
    
    sim = hfm_struct.sim;
    coch = sim.coch;
    
    delay0 = .0001;
    delay1 = .00010;
    delay3 = .002;
    if i == 1
        filtered_data1 = coch.bmm;
        raw1 = ts.data;
        time1 = ts.time;
        chirp1 = find(time1 == .002498); % min(time1 -.002498);
        chirp1stop = find(time1 ==.0065+delay1);
        
        echo1  = find(time1 == .008972);
        echo1stop = find(time1 ==.013+delay1);
        hfm_index_1 = [chirp1:chirp1stop,echo1:echo1stop];
        
        chirp_signal = zeros(size(raw1));
        chirp_signal = raw1([chirp1:chirp1stop],:);
        
        comp1 = zeros(size(raw1));
        comp1 =  [zeros(size(chirp_signal));raw1([echo1:echo1stop],:)];
    elseif i ==2
        filtered_data2 = coch.bmm;
        raw2 = ts.data;
        time2 = ts.time;
        echo2 = find(time2==.008952);
        echo2stop  = find(time2==.013+delay1);
        hfm_index_2 = [echo2:echo2stop];
        
        comp2= zeros(size(raw2));
        comp1 = [comp1; raw2(hfm_index_2,:)];
    else
        filtered_data3 = coch.bmm;
        raw3 = ts.data;
        time3 = ts.time;
        echo3  = find(time3== .00893);
        echo3stop = find(time3== .013);
        hfm_index_3 = [echo3:echo3stop];
        
        comp3 = zeros(size(raw3));
        comp1 = [comp1; raw3(hfm_index_3,:)];
    end
    
    
    
end

merged_x = vertcat(filtered_data1,filtered_data2, filtered_data3);
merged_time =  (1/fs)*[1:length(merged_x)]';
final_merged_x = vertcat(filtered_data1(hfm_index_1,:),filtered_data2(hfm_index_2,:), filtered_data3(hfm_index_3,:));
final_time =  (1/fs)*[1:length(final_merged_x)]';

ts.data = vertcat(raw1(hfm_index_1),raw2(hfm_index_2),raw3(hfm_index_3));
% ts.data = final_merged_x;
figure(1)
subplot(5,1,1)
plot(merged_time,merged_x)
subplot(5,1,2)
plot(final_time,final_merged_x)
subplot(5,1,3)
plot(time1,filtered_data1)
subplot(5,1,4)
plot(time2,filtered_data2)
% plot(((1/fs)*[1:length(filtered_data2([echo2:echo2stop],:))]'),filtered_data2([echo2:echo2stop],:))
subplot(5,1,5)
plot(time3,filtered_data3)

sim.coch.bmm = final_merged_x;
ts.time = final_time;

% Cross corr

%%  Plot Orginal Sound
% cutoff = .0036;
% chirp = [raw_data(1:find(standard_time == cutoff));zeros(size(raw_data(find(standard_time == cutoff)+1:end)))];
% echo = [zeros(size(raw_data(1:find(standard_time == cutoff))));raw_data(find(standard_time ==cutoff)+1:end)];

[gnd_corr, lags] = xcorr(chirp_signal,comp1);
[~,I] = max(abs(gnd_corr>0));
gnd_delay = lags(I);


figure(400)
chirp_signal_padded = padarray(chirp_signal,length(comp1)-length(chirp_signal), 0,'post'); 
subplot(2,1,1)
plot(final_time/fs,chirp_signal_padded,'r')
subplot(2,1,2)
plot(final_time/fs,comp1,'b')

legend('Original Broadcast','Echo')
title('40dB HFM Simulated Acoustic Signal with 30탎, 45탎, and 60탎 Spatial Glint Separation')
xlabel('Time (s)')
ylabel('Acoustic Sound Pressure (Pa)')

figure(401)
plot(-lags(lags<0)/fs,fliplr(gnd_corr(lags<0)),'Color',[0.4660    0.6740    0.1880])
gnd_truth_corr = max(gnd_corr(gnd_corr>0));
title({'40dB HFM Signal Cross Correlation with 40dB HFM Echoes',' with 30탎, 45탎, and 60탎 Spatial Glint Separation'})
xlabel('Time (s)')
ylabel('Amplitude')
%     corr_time = lags(lag>0)*fs;
%     plot(core_time*ones()), gnd_truth_corr);
shg


%% Save stuff
save('3_echoes.mat','ts','cfg','sim');
end
