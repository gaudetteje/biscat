function [current_echo_complete,null_ch_list] = scat_echo_processor(creature_file,echo_count,plot_opt_pre,raw_running_act,...
    num_ch,sample_pt,freq_ch,vertical_offset,speed_demon, standard_time,line_length,fs)
%AN ENTIRE ECHO HAS BEEN REGISTERED: Compare to Chirp NOW
%% 1) Update User:
disp(sprintf('PRE-PROCESSOR SAYS: Echo #%d COMPLETE',echo_count))

%% 1.5) Find Nonzero data alogn channels
echo_delay_est_list = [];
null_ch_list = [];
for k = num_ch:-1:1
    act_index = find(raw_running_act(k,:)==1);
    if ~isempty( act_index)
        % Only for active channels, find delays:
        delay_line = fliplr(raw_running_act(k,1:sample_pt)); % this flips the array so broadcast comes first
        [echo_delay_snapshot_vector, ~,~] = scat_delay_coincidence_detector(plot_opt_pre,sample_pt,delay_line,freq_ch, num_ch,vertical_offset,speed_demon);
        newest_echo_delay_est = max(echo_delay_snapshot_vector);
        echo_delay_est_list = [echo_delay_est_list;newest_echo_delay_est];
    end
end

%% 3) PLOT DECONVOLUTION TO S4:
%2) Do kmeans to ID skirts
gifname = 'int_animation.gif'

[~, thresholds ] = kmeans(echo_delay_est_list,2);
flat_bin_thres = max(thresholds);

skirt_vector = zeros(num_ch,1) ;
skirt_logical = zeros(num_ch,1) ;
for k = 1:1:num_ch
    act_index = find(raw_running_act(k,:)==1);
    if ~isempty( act_index)
        % Only for active channels, find delays:
        delay_line = fliplr(raw_running_act(k,1:sample_pt)); % this flips the array so broadcast comes first
        [semi_delay_vector, ~,~] = scat_delay_coincidence_detector(plot_opt_pre,sample_pt,delay_line,freq_ch, num_ch,vertical_offset,speed_demon);
        newest_echo_delay_est = max(semi_delay_vector);
        
        % PLot these on deconv plot:
        s4 = subplot(2,3,4);
        hold on
        
        if (newest_echo_delay_est<=flat_bin_thres)
            color_mark = 'bo';
        else
            color_mark = 'go';
            skirt_vector(k) = newest_echo_delay_est;
            skirt_logical(k) = 1;
        end
        
        plot(newest_echo_delay_est/fs*10^3, vertical_offset(k)/10^3,color_mark,'MarkerSize',2,'LineWidth',1);
        
        axis([standard_time(1)*10^3 standard_time(end)*10^3 0 1.2*vertical_offset(end)/10^3])
        s4.FontSize = 16;
        title('Dechirped Neural Spect','FontSize', 20);
        ylabel('Center Frequency CH (Hz)','FontSize', 20)
        xlabel('Elapsed Time (msec)','FontSize', 20)
        hold on
    end
end

frame = getframe(1);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,gifname,'gif', 'Loopcount',inf);

% save('int_plot.mat','gifname','cm','imind','im','frame')
%% Remove noisyness from of kmeans skirts
old_skirt_vector = skirt_vector;

sign_vector = diff(skirt_vector);
old_sign_vector = sign_vector;


% Your shouldn't have a postive negative derivative closer than 3k together
diffskirt1 = diff(skirt_vector);
diffskirt2 = diff(diffskirt1);

sign_diff1 = sign(diffskirt1);
what = diff(sign_diff1);

pos_loc = find(sign_diff1 ==1);
neg_loc = find(sign_diff1 ==-1);

% diff_loc = pos_loc-neg_loc;
%
% trouble = diff_loc(diff_loc>6);

ch_window = 3; % aka 6 for 3k and 3 for 1.5k
for q = 1:length(neg_loc)
    %     diffskirt1 = diff(skirt_vector);
    %     sign_diff1 = sign(diffskirt1);
    if any(sign_diff1(neg_loc(q)+1:neg_loc(q)+ch_window) == 1)
        skirt_vector(neg_loc(q):neg_loc(q)+(min(find(sign_diff1(neg_loc(q)+1:neg_loc(q)+ch_window) == 1)))) = 2000;
        skirt_logical(neg_loc(q):neg_loc(q)+(min(find(sign_diff1(neg_loc(q)+1:neg_loc(q)+ch_window) == 1)))) = 1;
    end
end

% figure(82)
% plot(old_skirt_vector)
% hold on
% plot(skirt_vector,'mo')

% while cont_null_small
%     % Initially compute
%     ynot = diff(find([0; skirt_vector ;0]==0))-1; % looks for length of continuous zeroes
%     ynot(ynot==0) =[];
%
% %     f
% %     null_lists = find(sign_vector==1)+1 ;
% %
% %     skirt_vector =
%
%     % Recalculate skirt to see if constaints met
%     ynot = diff(find([0; skirt_vector ;0]==0))-1; % looks for length of continuous zeroes
%     ynot(ynot==0) =[];
%     if ynot(ynot>=3)
%         cont_null_small = 0;
%     end
%
% end

% for k = 10:length(sign_vector)
%     sign_vector = diff(skirt_vector);
%     if k == 24
%         j = 0;
%     end
%
%     if (sign_vector(k-1)==+1) & any(sign_vector([k:k+4])==-1)% | (sign_vector(k-1)==1) & any(sign_vector(k+6:k+1)==-1)
%         local_skirt_vector = skirt_vector(k-3:k+3);
%         if size(local_skirt_vector(local_skirt_vector== 1)) < 3 & skirt_vector(k) == 0% if the number of elements around kth point that is changing sign is small
%             skirt_vector(k) = 1;
%
%         end
%     end
%
%     sign_vector = diff(skirt_vector);
%    if (sign_vector(k-1)==-1) & any(sign_vector([k:k+4])==+1)% | (sign_vector(k-1)==1) & any(sign_vector(k+6:k+1)==-1)
%         local_skirt_vector = skirt_vector(k-3:k+3);
%         if size(local_skirt_vector(local_skirt_vector== 1)) < 3 & skirt_vector(k) ==0 % if the number of elements around kth point that is changing sign is small
%             skirt_vector(k) = 1;
%
%         end
%     end
%
% end

% skirt_vector = old_skirt_vector;
% sign_vector = old_sign_vector;
%
% figure(12)
% plot([1:length(old_skirt_vector)],old_skirt_vector,'bo')
% hold on
% plot([1:length(old_sign_vector)],old_sign_vector,'k*')
% hold on ; plot([1:length(skirt_vector)],skirt_vector,'r.')
%
% figure(12)
% plot([1:length(old_skirt_vector)],old_skirt_vector,'b')
% hold on
% plot([1:length(old_sign_vector)],old_sign_vector,'k*')
% hold on ; plot([1:length(skirt_vector)],skirt_vector,'r')

% Just
ynot = diff(find([0; skirt_logical ;0]==0))-1; % looks for length of continuous zeroes
ynot(ynot==0) =[];
center_distances = ceil(ynot/2); % nulls cant be less thatn 1.5khz wide
null_starts = find(diff(skirt_logical)==1)+1;
null_ch_list =  find(skirt_logical==1); % null_starts(center_distances>=3) +center_distances(center_distances>=3);

% % % % % % % widdle way skirt edges so you can get to center!
% % % % % % cont_skirt_vector = skirt_vector;
% % % % % %
% % % % % % sign_vector = diff(skirt_vector);
% % % % % % cont_sign_vector = sign_vector;
% % % % % %
% % % % % % plot([1:length(cont_skirt_vector)],cont_skirt_vector,'bo')
% % % % % % hold on
% % % % % % plot([1:length(cont_sign_vector)],cont_sign_vector,'g*')
% % % % % %
% % % % % % while centers_not_found == 1
% % % % % % for k = sign_vector(k)~=0
% % % % % %     % Recompute differences
% % % % % %     sign_vector = diff(skirt_vector);
% % % % % %     % Modify
% % % % % %     if (sign_vector(k)==1)| (sign_vector(k)==-1)% on rising or falling edge
% % % % % %         skirt_vector(k+1) = 0;
% % % % % %     end
% % % % % %     % Check if you found center
% % % % % %
% % % % % % end
% % % % % % end
% % % % % % ynot = diff(find([0; skirt_vector ;0]==0))-1; % looks for length of continuous zeroes
% % % % % % ynot(ynot==0) =[];
% % % % % %
% % % % % % skirt_vector()
% % % % % % null_ch_list = skirt_vector
%% 5) Send to Deconvolution, spectral tranformation module

plot_opt_trans = 1;
% prom_sensitivity = 500;
% [null_ch_latency,null_ch_list] = findpeaks(echo_delay_est_list,'MinPeakProminence',prom_sensitivity);


s4 = subplot(2,3,4);
hold on
for r = 1:length(null_ch_list)
    plot([0,standard_time(end)]*10^3, vertical_offset(null_ch_list(r))/10^3*ones(size([1,standard_time(end)])),'m','MarkerSize',3,'LineWidth',1);
end
axis([standard_time(1)*10^3 standard_time(end)*10^3 0 1.2*vertical_offset(end)/10^3])
s4.FontSize = 16;
title('Dechirped Neural Spect','FontSize', 20);
ylabel('Frequency (kHz)','FontSize', 20)
xlabel('Elapsed Time (msec)','FontSize', 20)
hold on


% frame = getframe(1);
% im = frame2im(frame);
% [imind,cm] = rgb2ind(im,256);
% imwrite(imind,cm,gifname,'gif','WriteMode','append');
% save('int_plot.mat','gifname','cm','imind','im','frame')

inf_roi = [8:50];
scat_spect_trans(creature_file,plot_opt_trans,sample_pt,num_ch,null_ch_list,line_length,echo_count,vertical_offset,inf_roi)


% 4) Echo has been done processing, go back for listening for the completion of the next echo
current_echo_complete = 0;
null_ch_list = [];


end