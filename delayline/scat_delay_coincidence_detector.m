function [delay_snapshot_vector,earliest_cell,activated_cells] =  scat_delay_coincidence_detector(plot_opt_pre,sample_pt,delay_line, freq_ch,num_ch,vertical_offset,speed_demon)

% INPUT:
%
%
% OUTPUT:
%
%
% DESCRIPTION:
% Make coincidence detectors for a single delay line freq channel
%

%% Parameters
post = 1; 
debug = 100; 
model_length   = size(delay_line,2);
neuron_train    = model_length:-debug:1; % goes right to left so that means indexing for cells need to go 1 to 100

% delay line lowest elements are the cells to the most right so when you
% throw them into nueron train that is backwards, it plots rightward first

%%  Visualize- coincidence detector array triangle
% fig2 = figure(2);
% set(fig2, 'Position', [10 1000  1500 800]) % EDIT THIS WHEN YOU GET TO DESKTOP TOMRROW

axis_bounds = model_length;

if plot_opt_pre == 1
    s5 = subplot(2,3,5);
    cla(s5)
    hold on
    axis([0 axis_bounds 0 axis_bounds ])
    ax = gca;
    ax.LineWidth = 1.5;
    ax.FontSize = 16;
    
    title({'Delay Line Coincidence Detector Array';sprintf('Time Frame = %s    Freq CH =  %s kHz ',num2str(sample_pt),vertical_offset(freq_ch)/10^3)},'FontSize', 16)
    ylabel('Cell Seperation ','FontSize', 20)
    xlabel('Delay Line Cells','FontSize', 20)
    
    plot(neuron_train,zeros(size(neuron_train,1),1),'ko','MarkerSize',.5)
    plot(neuron_train(delay_line),zeros(size(neuron_train(delay_line))),'ro','MarkerSize',5,'MarkerFaceColor','r')
    axis([0 axis_bounds 0 axis_bounds])
end

%% Coincidence Detector Logic
cd_array   = zeros(model_length,model_length);
if speed_demon == 1
    activated_cell_index = find(delay_line == 1); 
else % really CD just subtract for you in a really processing intensive manner
    
    for level = 1:size(delay_line,2)-1
        % filename = 'cc_single_ch.gif';
        
        % Plot the delay line template
        if (plot_opt_pre == 1) && (mod(level,500) == 0)
            plot(neuron_train(1:end-level),level*ones(size(neuron_train(1:end-level))),'k.','MarkerSize',.5)
        end
        
        %  Define Parameters
        stepsize = level;
        base_cell = 1;
        cc_checked = 0;
        cc_per_level = size(delay_line,2)-level;
        
        
        % While all combos not checked, continue checking
        while cc_checked < cc_per_level
            
            % Sweep through  the comparison index with a comparison window of 2
            cell1 = base_cell; % So it starts from right
            cell2 = base_cell+stepsize;
            
            % Show which cells are being compared:
            if plot_opt_pre ==1
                path1x = [neuron_train(cell1),neuron_train(base_cell)];
                path1y  = [0,level];
                
                path2x = [neuron_train(cell2),neuron_train(base_cell)];
                path2y  = [0,level];
                
                plot(path1x,path1y,'r','LineWidth',.5)
                plot(path2x,path2y,'g','LineWidth',.5)
            end
            
            %Take care of spike matches
            if (delay_line(cell1) == 1) && (delay_line(cell2) == 1) % use single & for sclar comparison so it doesnt compare binary decriptions of the ansers to logicals
                % Mark cd as match:
                cd_array(level,base_cell) = 1;
                cd_array = logical(cd_array);
                
                if plot_opt_pre == 1
                    %  Visualize- coincidence detector array triangle
                    if ~isempty(neuron_train(cd_array(level,:)))
                        plot(neuron_train(cd_array(level,:)),level*ones(size(neuron_train(cd_array(level,:)))),'ro','MarkerSize',5,'MarkerFaceColor','r') % this might be wasteful since overwriting everytime
                        
                        % Show which cells are being compared:
                        path1x = [neuron_train(cell1),neuron_train(base_cell)];
                        path1y  = [0,level];
                        
                        path2x = [neuron_train(cell2),neuron_train(base_cell)];
                        path2y  = [0,level];
                        
                        plot(path1x,path1y,'r','LineWidth',2)
                        plot(path2x,path2y,'b','LineWidth',2)
                        axis([0 axis_bounds 0 axis_bounds])
                    end
                    
                end
                
                
                
            end
            
            
            % Increment cells
            base_cell = base_cell+1;
            cc_checked = cc_checked +1;
            
        end
        %     %%  Exports gif & Delete Plot Objects so they look continuous:
        %     frame = getframe(1);
        %     im = frame2im(frame);
        %     [imind,cm] = rgb2ind(im,256);
        %     if level == 1;
        %         imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
        %     else
        %         imwrite(imind,cm,filename,'gif','WriteMode','append');
        %     end
        %
        %
        
        %     %%  Move on to next level
        %     level = level+1;
    end
end


%%  Parse which cells of coincidence detectors turned on and interpret as
% delay b/t active cells in delay line
hold off
earliest_cell = find(delay_line==1,1,'first');
activated_cells = find(delay_line==1);

% Determine activation pt elgibility

% Assign Outputs
if speed_demon == 1
    if size(activated_cell_index,2) <=1
        delay_snapshot_vector = 0; % there is no seperation of activated pts, only single activated pt so delay should be 0 
    else
        % means one or more than one pair of chirp echos
        delay_snapshot_vector = zeros(1,size(activated_cell_index,2)-1);
        for k = 2:size(activated_cell_index,2)
            delay_snapshot_vector(k-1) = activated_cell_index(k)-activated_cell_index(1); % subtract sound from baseline
        end
    end
else
    if size(find(cd_array(:,earliest_cell) == 1),2) <1 % you have only broadcast or no broadcast, so no delay
        delay_snapshot_vector = 0;
        
    elseif size(find(cd_array(:,earliest_cell) == 1),2) == 1 % you have broadcast and atleast 1 echo
        delay_snapshot_vector = find(cd_array(:,earliest_cell)==1);
        
    else % you have broadcast and atleast 2 echoes
        delay_snapshot_vector = movsum(find(cd_array(:,earliest_cell) == 1),size(find(cd_array(:,earliest_cell) == 1),2)); % this turns it into cummulative sum from broadcast
        
    end
end
end
