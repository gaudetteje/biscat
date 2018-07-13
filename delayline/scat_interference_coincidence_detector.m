function [glint_usec,glint_usec_popularity,glint_label,cd_array] = scat_interference_coincidence_detector(tri_level_opt, nullcd_plot_opt,sample_pt,null_ch_logical,num_ch,echo_count,vertical_offset,inf_roi)

% INPUT:
% network_mask == 1 for log log both axis
% network_mask == 2 for raw index both axis
% OUTPUT:
%
%
% DESCRIPTION:
% Make coincidence detectors for a single delay line freq channel

%%  Visualize- coincidence detector array triangle - we def want this
% fig2 = figure(2);
% set(fig2, 'Position', [10 1000  1500 800]) % EDIT THIS WHEN YOU GET TO DESKTOP TOMRROW

cla(subplot(2,3,5))
hold on
% save('deconv_debug_bat_2h_100.mat')
% figure(1)
fs = 500*10^3;
max_occupied = size(null_ch_logical(null_ch_logical==1),2);
axis_bounds = 1.2*vertical_offset(end)/10^3;
null_cd_start = [(vertical_offset(1)/10^3)-((vertical_offset(2)-vertical_offset(1))/10^3)];
raw_null_cd_start = 0;
raw_index_vector  = 1:num_ch;

seperation_hz = zeros(size(vertical_offset,1)-1,1);
for u = 2:1:size(vertical_offset,1)
    seperation_hz(u-1) = (vertical_offset(u)-vertical_offset(1))/10^3;
end

raw_index_vector = seperation_hz;

green_plot_opt = 1;
if nullcd_plot_opt == 1
    % subplot(2,3,5);
    hold on
    
    ax = gca;
    ax.LineWidth = 1.5;
    ax.FontSize = 16;
    title({'Running Deconvolution';sprintf('Echo Completed at = %s (msec)',num2str(sample_pt*(1/fs)*10^3))},'FontSize', 20)
    ylabel('Frequency (kHz)','FontSize', 20)
    xlabel('Frequency Seperation (kHz)','FontSize', 20)
    hold on
    
    if green_plot_opt == 1 % hz xaxis vs hz yaxis
        plot(null_cd_start*ones(size(vertical_offset(logical(null_ch_logical)))),vertical_offset(logical(null_ch_logical))/10^3,'mo','MarkerSize',5); %,'MarkerFaceColor','m')
        axis([null_cd_start axis_bounds null_cd_start axis_bounds])
    elseif green_plot_opt == 2 % index xaxis vs index yaxis
        plot(raw_null_cd_start*ones(size(vertical_offset(logical(null_ch_logical)))),raw_index_vector(logical(null_ch_logical)*10^3),'mo','MarkerSize',5); %,'MarkerFaceColor','m')
        axis([raw_null_cd_start raw_index_vector(end) raw_null_cd_start raw_index_vector(end)])
    elseif green_plot_opt == 3 % hz xaxis vs index yaxis
        plot(null_cd_start*ones(size(vertical_offset(logical(null_ch_logical)))),raw_index_vector(logical(null_ch_logical)*10^3),'mo','MarkerSize',5); %,'MarkerFaceColor','m')
        axis([null_cd_start axis_bounds raw_null_cd_start raw_index_vector(end)])
    elseif green_plot_opt == 4 % index xaxis vs hz yaxis
        plot(raw_null_cd_start*ones(size(vertical_offset(logical(null_ch_logical)))),vertical_offset(logical(null_ch_logical)*10^3),'mo','MarkerSize',5); %,'MarkerFaceColor','m')
        axis([raw_null_cd_start raw_index_vector(end) vertical_offset(start) vertical_offset(end)])
    end
    load('gif_plot.mat')
    frame = getframe(1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if sample_pt == plot_update_rate;
        imwrite(imind,cm,gifname,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,gifname,'gif','WriteMode','append');
    end
    save('gif_plot.mat','gifname','cm','imind','sample_pt','plot_update_rate','im','frame')
end

%% Coincidence Detector Logic
cd_array   = zeros(num_ch,num_ch);
lcd_ch_vector = zeros(num_ch,1);
% filename = 'cc_single_ch.gif';

for column = 1:size(null_ch_logical,2)-1
    %  Define Parameters
    n_neighbor = column;
    base_cell = 1;
    cc_checked = 0;
    cc_per_level = size(null_ch_logical,2)-column;
    
    % While all combos not checked, continue checking
    while cc_checked < cc_per_level
        cell1 = base_cell;% So it starts from right
        % vertical_offset(cell1);
        cell2 = base_cell+n_neighbor;
        % vertical_offset(cell2);
        
        %Take care of spike matches & PLOT them
        if (null_ch_logical(cell1) == 1) & (null_ch_logical(cell2) == 1) & (lcd_ch_vector(cell2,1) ~= 4) % & (lcd_ch_vector(cell2,1) ~= 2)
            if lcd_ch_vector(cell2,1) ==0 % transition from default to first state , if you are already state 1, dont transition to state 1 doesnt make sense
                lcd_ch_vector(cell2,1) = 1;
            elseif lcd_ch_vector(cell2,1) == 2 % if you are on state 2 meaning a gap and you activate, go to state 3
                lcd_ch_vector(cell2,1) = 3;
            end
            if any(column==inf_roi)
                cd_array(n_neighbor,base_cell) = 1;
                cd_array = logical(cd_array);
            end
            
        else
            %             if lcd_ch_vector(cell2,1) ==0
            %                 lcd_ch_vector(cell2,1) = 2;
            %             end
            if lcd_ch_vector(cell2,1) ==1 % if was activated at one point and now it isn't, now you are transitioning from 1st state to 2nd state
                lcd_ch_vector(cell2,1) = 2;
            elseif  lcd_ch_vector(cell2,1) == 3
                lcd_ch_vector(cell2,1) = 4;
            end
            
        end
        
        % PLotting trapezoids
        
        if lcd_ch_vector(cell2,1) == 3
            if green_plot_opt == 1 % hz xaxis vs hz yaxis
                p = plot(vertical_offset(n_neighbor)/10^3,vertical_offset(cell2)/10^3,'o','MarkerSize',4); % ,'MarkerFaceColor','m');
            elseif green_plot_opt == 2 % index xaxis vs index yaxis
                p = plot(raw_index_vector(n_neighbor)*10^3,raw_index_vector(cell2)*10^3,'o','MarkerSize',4); % ,'MarkerFaceColor','m');
            elseif green_plot_opt == 3 % hz xaxis vs index yaxis
                p = plot(vertical_offset(n_neighbor)*10^3,raw_index_vector(cell2)*10^3,'o','MarkerSize',4); % ,'MarkerFaceColor','m');
            elseif green_plot_opt == 4  % index xaxis vs hz yaxis
                p = plot(raw_index_vector(n_neighbor)*10^3,vertical_offset(cell2)*10^3,'o','MarkerSize',4); % ,'MarkerFaceColor','m');
            end
            
            p.Color = [147 112 219]/255; % [ .5 0 0] ; % [0.4660    0.6740    0.1880];
            
        elseif lcd_ch_vector(cell2,1) == 1
            if green_plot_opt == 1 % hz xaxis vs hz yaxis
                p = plot(vertical_offset(n_neighbor)/10^3,vertical_offset(cell2)/10^3,'o','MarkerSize',4); % ,'MarkerFaceColor','m');
            elseif green_plot_opt == 2 % index xaxis vs index yaxis
                p = plot(raw_index_vector(n_neighbor)*10^3,raw_index_vector(cell2)*10^3,'o','MarkerSize',4); % ,'MarkerFaceColor','m');
            elseif green_plot_opt == 3 % hz xaxis vs index yaxis
                p = plot(vertical_offset(n_neighbor)*10^3,raw_index_vector(cell2)*10^3,'o','MarkerSize',4); % ,'MarkerFaceColor','m');
            elseif green_plot_opt == 4  % index xaxis vs hz yaxis
                p = plot(raw_index_vector(n_neighbor)*10^3,vertical_offset(cell2)*10^3,'o','MarkerSize',4); % ,'MarkerFaceColor','m');
            end
            
            p.Color = [147 112 219]/255; % [ .5 0 0] ; % [0.4660    0.6740    0.1880];
            
            
        end
        
        
        % Increment cells
        base_cell = base_cell+1;
        cc_checked = cc_checked +1;
        
        
        
        
    end
    
    %%  Move on to next level
    column = column+1;
    %giffy
    if column <55
        load('int_plot.mat')
        frame = getframe(1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        imwrite(imind,cm,gifname,'gif','WriteMode','append');
        save('int_plot.mat','gifname','cm','imind','im','frame')
    end
end



% Just replot to its on top

glint_label = [];


%%  Parse which cells of coincidence detectors turned on and interpret as
%I want all the interdelays , i want the weights too, so like sum down
%horizontal rows to get that but flag the ones that got turned on

dechirped_cd = sum(cd_array,2); % this adds up activations and tells you if there was speeration at that level

if length(find(dechirped_cd >= 1)) <1 % you have only broadcast or no broadcast, so no delay
    glint_usec = 0;
    glint_usec_popularity = 0;
elseif length(find(dechirped_cd >= 1)) >= 1 % you have atleast 2 pts on
    % glint_khz = seperation_hz(find(dechirped_cd >= 1)) ;
    glint_usec = seperation_hz;%1./vertical_offset(:)' ; % 1./(glint_khz); % idk what the magnitude will be for these babes
    glint_usec_popularity = dechirped_cd(1:end-1); % dechirped_cd(dechirped_cd >= 1);
end

end
