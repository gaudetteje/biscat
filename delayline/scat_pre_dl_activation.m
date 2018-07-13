function [ts_time, final_acoustic_data, fs,f_max, f_min, raw_data,alt_band_model,vertical_offset] = scat_pre_dl_activation(wipe_opt, wipe_ch_hz,data_mat, scat_pre_plot_opt)
% INPUT:
% To see what each of the parameters are, just put break point on line
% where this function is called and then hover over vraibles in scat_main 
%
% OUTPUT:
% 
%
% DESCRIPTION:
% The main thing done here is implementation of amplitude latency trading 
% 
%% plot this raw fitlered data oh yiss
clf

% ALT ends up being computed by us
alt_rate = -40e-6; % 16usec per db

% BEFORE YOU DO THIS YOU MUST REFRESH FILE
hfm_struct  = load(data_mat);
% hfm_struct  = load('imp_100usec_wide.mat');
ts     = hfm_struct.ts;
cfg = hfm_struct.cfg;
sim = hfm_struct.sim;

fs     = ts.fs;

%ts.data = [ts.data;zeros(ceil(.25*length(ts.data)),1)];
raw_data = ts.data;
ts_time =  (1/fs)*[1:length(ts.data)]';
f_max = cfg.coch_fmax;
f_min = cfg.coch_fmin;
alt_opt = cfg.coch_mode;

sim = hfm_struct.sim;
coch = sim.coch;
filtered_data = coch.bmm; % bmm;

% Defining center freqeuncies on log scale
num_ch          = size(filtered_data,2);
% Tc = (0:1/(num_ch-1):1)' .* (1/f_max-1/f_min) + 1/f_min;
vertical_offset = coch.Fc;              % vector of center frequencies of filter


gifname = 'asa_pre_proc_3wav.gif';
if (scat_pre_plot_opt == 1 )
    fig100 = figure(100);
    set(fig100, 'Position', [65 1000 1400 1100]) % EDIT THIS WHEN YOU GET TO DESKTOP TOMRROW
    fig100.Name = 'COCH FILTER OUTPUT SIGNALS ';
    subplot(3,2,1)
    ylabel('Amplitude')
    xlabel('Time (sec)')
    title('CH Data vs Time')
    subplot(3,2,2)
    title('CH Spectrogram Log Axis')
end

final_acoustic_data = zeros(size(filtered_data));
for ch = size(filtered_data,2):-1:1
    %% Plot Filtered Data
    if scat_pre_plot_opt == 1
        cla(subplot(3,2,1))
        subplot(3,2,1)
        hold on
        for proc_ch = size(filtered_data,2):-1:ch
            plot(ts_time,filtered_data(:,proc_ch),'LineWidth',.5)
        end
        
        plot(ts_time,filtered_data(:,ch),'r')
        title({'Superimposed Acoustic Data vs Time ';sprintf('Cochlear CH centered at f_c = %d kHz',ceil(vertical_offset(ch)/10^3))})
        ylabel('Amplitude')
        xlabel('Time (sec)')
        
        cla(subplot(3,2,2))
        subplot(3,2,2)
        spectrogram(filtered_data(:,ch),blackman(256),250,256,fs,'yaxis')
        title({'Spectrogram of Acoustic Signal ';sprintf('Cochlear CH centered at f_c = %d kHz',ceil(vertical_offset(ch)/10^3))})
        
    end
    
    
    %% Neural Transduction here featuring ALT :
    % Half wave rectification on signal traveling trough this CH
    filtered_data(filtered_data(:,ch)<=0,ch) = 0;
    
    % this calls this rectified signal by another name called neural data
    neural_data = filtered_data(:,ch);
    
    % Envelope detection:
    % https://www.mathworks.com/help/signal/ref/envelope.html -> used
    % peak not anaylitical since we are interested in peaks not fine detail
    smoothness = 10;
    [rect_env,~] = envelope(neural_data,smoothness,'peak');
    
    % Local max values and location:
    %   [pks,locs] = findpeaks(rect_env);
    cla(subplot(3,2,6))
    subplot(3,2,6)
    hold on
    prom_sensitivity = .05;
    sensitivity = .05;
    % findpeaks(rect_env,'MinPeakProminence',prom_sensitivity*max(rect_env),'MinPeakHeight',sensitivity*max(rect_env));
    [pks,locs,w,prom] = findpeaks(rect_env,'MinPeakProminence',prom_sensitivity*max(rect_env),'MinPeakHeight',sensitivity*max(rect_env),'MinPeakDistance',.002*500*10^3);
    %     findpeaks(rect_env,'MinPeakProminence',2); %'MinPeakHeight',sensitivity*max(rect_env))
    %     [pks,locs]= findpeaks(rect_env,'MinPeakProminence',2);% ,'MinPeakHeight',sensitivity*max(rect_env))
    hold off
    % meaningful_pks = pks(pks>.25*max(pks));
    % meaningful_locs= locs(pks>.25*max(pks));
    
    %     [max_pks, max_pks_index] = sort(pks,'descend');
    %     max_pks_locs = locs(max_pks_index); % index loc
    %     [temporal_max_pks_locs,temporal_max_pks_index] = sort(max_pks_locs,'ascend');
    meaningful_locs =locs ;  % temporal_max_pks_locs(1:10);
    
    % chirp should be the peak that has first strong prominence
    chirp_found = 0;
    p = 0;
    chirp_sensitivity = 5*prom_sensitivity;
    while chirp_found==0
        p = p+1;
        if prom(p) > chirp_sensitivity*max(rect_env)
            rect_chirp_loc = meaningful_locs(p); % meaningful_locs(1);
            rect_chirp = rect_env(rect_chirp_loc);
            
            act_index = meaningful_locs(p);
            final_acoustic_data(act_index,ch) =  1; % this literally means lowest index is lowest freq band
            
            chirp_found = 1;
        end
    end
    
    
    
    % Get ratio of rectified amplitude differences multiply these two
    % values to get ALT representation of signal to get ALT delay
    %         rect_chirp = rect_env(max_pks_locs(1));
    %         rect_chirp_loc = max_pks_locs(1); % index loc % assumes first peak isnt garbage
    %
    
    
    inhib_time = 200; %600;  % in terms of index taps CHANGE THIS - try 150 to 200
    poss_peak_count = size(meaningful_locs,1);
    while p < poss_peak_count % this is grounded on the fact that string amplitudes will go into this process and theortetically i feel it can be implemented when sampling real world
        p = p+1;
        % Check if not closer together than an inhib_time
        % Does delay line activation flagging of data:
        
        % Implement inhibition time, dont allow peaks within inhibition time
        
        if (meaningful_locs(p) >= meaningful_locs(p-1)+inhib_time)
            %
            %             max_flag = act_index; % is an index
            %             act_index_inhib = act_index;
            %             while ~isempty(act_index)
            %                 act_index = act_index(~logical(act_index<max_flag+inhib_time));  % turn off indices that are within the inhibition time yeah
            %                 if ~isempty(act_index)
            %                     max_flag = min(act_index);
            %                     act_index_inhib = [act_index_inhib;max_flag];
            %                 end
            %             end
            
            % FInd echo peak, convert to time delay (taps)
            rect_echo = rect_env(meaningful_locs(p)); % is in dB we believe , we index as n+1 because 1st index is chirp
            rect_echo_loc = meaningful_locs(p);
            chirp_echo_amp_ratio= 20*log(rect_echo/ rect_chirp); % can you subtract db? JIM: I rectify dB, can I subtract this? is this in dB?
            alt_effect = alt_rate*chirp_echo_amp_ratio*((size(ts_time,1)-1)/ts_time(end)); % make sure this is in terms of indices not time
            act_index = meaningful_locs(p)+ceil(alt_effect);
        end
        
        final_acoustic_data(act_index,ch) =  1; % this literally means lowest index is lowest freq band
        
        
    end
    %         % Apply logarithm compression + half wave rect fication OR NOT
    %         % Does low level log cmpression
    %         gaincomp_neural_data = log(neural_data_alt);
    
    % AMPLER INFINHITO DO THE ALT
    % where does this go?  neural_data_alt(rect_echo_loc+alt_effect) = neural_data <- ASK JIM ;
    
    %     % temporary to show without inhibition
    %     final_acoustic_data(act_index,ch) =  1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %         % Birth Gnd truth on running Histogram
    %      standard_time = ts_time;
    %     s1 = subplot(3,2,5);
    %     s1.FontSize = 16;
    %     title('Acoustic Data Gnd Truth','FontSize', 20)
    %     ylabel('CH (centered at f_c) ','FontSize', 20)
    %     xlabel('Standard Time (sec) ','FontSize', 20)
    %     axis([standard_time(1) standard_time(end) 0 1.2*vertical_offset(end)])
    %
    %     hold on
    %         if ~isempty(final_acoustic_data(:,ch))
    %            display(sprintf('Fc Ch  = %d',vertical_offset(ch)));
    %             nonzero_time = standard_time(logical(final_acoustic_data(:,ch)));
    %             h = plot(nonzero_time, vertical_offset(ch)*ones(size(nonzero_time)),'ko','MarkerSize',2);
    %             if ~isempty(h)
    %                 h.Color = [0.6350    0.0780    0.1840];
    %             end
    % %             frame = getframe(1);
    % %             im = frame2im(frame);
    % %             [imind,cm] = rgb2ind(im,256);
    % %             if k == num_ch;
    % %                 imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
    % %             else
    % %                 imwrite(imind,cm,filename,'gif','WriteMode','append');
    % %             end
    %         end
    %
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if scat_pre_plot_opt == 1
        cla(subplot(3,2,3))
        subplot(3,2,3)
        plot(ts_time,neural_data,'r')
        
        title({'Rectified Acoustic Signal vs Time';sprintf('Cochlear CH centered at f_c = %d kHz',ceil(vertical_offset(ch)/10^3))})
        axis([0 0.02 0 0.5])
        ylabel('Amplitude')
        xlabel('Time (sec)')
        
        cla(subplot(3,2,4))
        subplot(3,2,4)
        plot(ts_time,rect_env,'r','LineWidth',2)
        title({sprintf('Rectified Acoustic Envelope vs Time',ch);sprintf('Cochlear CH centered at f_c = %d kHz',ceil(vertical_offset(ch)/10^3))})
        axis([0 0.02 0 0.5])
        ylabel('Amplitude')
        xlabel('Time (sec)')
        
        
    end
    
    if scat_pre_plot_opt == 1
        % Exports gif & Delete Plot Objects so they look continuous:
        frame = getframe(gcf);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if ch == size(filtered_data,2);
            imwrite(imind,cm,gifname,'gif', 'Loopcount',inf);
        else
            imwrite(imind,cm,gifname,'gif','WriteMode','append');
        end
    else
        pause(.1)
    end
    
    
    
end % end to for ch loop

final_acoustic_data = final_acoustic_data';

%% If wipe requested, wipe here
% wipe_ch_hz = (10^3)*[20,25;45,55;95,100];

wipe_ch_indices = [];
for r = 1:size(wipe_ch_hz,1)
    new_indices = [find(vertical_offset == wipe_ch_hz(r,1)):1:find(vertical_offset == wipe_ch_hz(r,2))]';
    wipe_ch_indices = [wipe_ch_indices; new_indices] ; 
end

if wipe_opt == 1
    final_acoustic_data(wipe_ch_indices,:) = 0;
end

%% LInes 157 to 168 are extracted from Jason's gen_latency code
T = 500;            % integration time of energy estimate -
win = 'hamming';    % window function to use in energy estimate

% estimate energy in each channel
for i = 1:size(final_acoustic_data,2)
    E(:,i) = scat_energy(final_acoustic_data(:,i), win, 1/T, T);
    %E(:,i) = db(E,'power');          % convert to dB
    %E(:,i) = E(:,i)./max(E(:,i));        % normalize to peak energy
end
alt_band_model = (alt_rate*fs)*db(mean(E(E>0)),'power');

end % end to function

