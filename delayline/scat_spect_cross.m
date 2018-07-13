function scat_spect_cross(plot_opt_cross,pre_proc_running_act, sample_pt, num_ch,line_length,...
    vertical_offset, running_act_mask,echo_count,standard_time,running_delay_est_log,fs,alt_band_model)
% INPUT:
%
%
% OUTPUT:
%
%
% DESCRIPTION:
% Time delay estimation is done here, Deal with the figure's plotting here
% as well
%

%% Generate delaye stimate for this time sample
% plot_opt_cross = 0;
% delay_est = delay_perception(plot_opt_cross,running_act, sample_pt, num_ch,standard_time);

%% Plot delay est
% Plot flagged activation points that are indictive of nulls
if plot_opt_cross ==1    
    %%   Extract the delay estimate for frame, from histogram
    s3 = subplot(2,3,3);
    hold on
    nonzero_running_delay_est_log = running_delay_est_log(running_delay_est_log~=0);
    snap_hist = histogram(nonzero_running_delay_est_log,'Numbins',line_length,'Visible','off'); % i think bins need to be width 1 to facilitate stuff
    
    snap_hist_data = snap_hist.Data;
    %nonzero_data = snap_hist_data(snap_hist_data ~= 0); % this is data that got binned
    % max(nonzero_data);
    %
    %     popular_nonzero_data = [];
    %     plot_thres = 0;
    %     if ~isempty(snap_hist_data)
    %         hist_bin_counts = snap_hist.Values(snap_hist.Values >0);
    %         plot_thres    = max(hist_bin_counts);
    %         bin_logical = find(snap_hist.Values >0);
    %         for h = 1:size(hist_bin_counts,2)
    %             if hist_bin_counts(h) == plot_thres
    %                 bin_index = bin_logical(h);
    %                 popular_nonzero_data = [popular_nonzero_data ;snap_hist.BinEdges(bin_index)];
    %             end
    %         end
    %
    %     else
    %         popular_nonzero_data = 0;
    %     end
    % % % % % % % % %
    %     color_res = 4;
    %     color_hist = histogram(nonzero_data,color_res);
    %     pop_index = max(color_hist.Values(color_hist.Values >0));
    %     popular_bin =
    %     if ~isempty(nonzero_data)
    %         avg_data = mean(nonzero_data);
    %         if avg_data mean(color_pop(color_res))
    %             color = [1 0 0];
    %         elseif avg_data >color_pop(color_res-1)
    %             color = [1 0 1];
    %         elseif avg_datas >color_pop(color_res-2)
    %             color = [0 1 0];
    %         else
    %             color = [ 0 1 1];
    %         end
    %         plot((1/fs)*sample_pt,avg_data/fs,'MarkerFaceColor',color,'MarkerSize',1);
    %     end
    
    
    
    %    plot((1/fs)*sample_pt*ones(size(nonzero_data)),nonzero_data/fs,'ko','MarkerSize',1);
    
    % plot(sample_pt*ones(size(popular_nonzero_data)),popular_nonzero_data,'mo','MarkerSize',2,'MarkerFace', 'm');
    
    inst_delay_obj = plot((10^3)*(1/fs)*sample_pt*ones(size(nonzero_running_delay_est_log)),(nonzero_running_delay_est_log/fs)*10^3,'o','MarkerSize',1);
    
    % h = plot((1/fs)*sample_pt*ones(size(snap_hist_data)),snap_hist_data/fs,'o','MarkerSize',1);
    if ~isempty(inst_delay_obj)
        inst_delay_obj.Color = [0 .5 0]; % [0.4660    0.6740    0.1880];
    end
    %     if ~isempty(h)
    %         h.Color =  [0 .5 0];  %[0.4660    0.6740    0.1880];
    %     end
    
   
    title({'Running Delay Estimate ';sprintf('Time Elapsed = %s (msec)',num2str((sample_pt/fs)*10^3))},'FontSize', 20)
    ylabel({'Delay Estimate (msec)'},'FontSize', 20)
    xlabel('Elapsed Time (msec) ','FontSize', 20)
    axis([0 standard_time(end) 0 standard_time(end)]*10^3)
    hold off
%     
    
    %%  Deal with frame clean up
    pause(.005) % need pause when not saving gif since it goes way too fast
    %delete(inst_delay_obj)
    % delete(snap_hist);
end
end