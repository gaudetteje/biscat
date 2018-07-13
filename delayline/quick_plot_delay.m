function quick_plot_delay()
close all

%% 

load('left_ear_neg45_1_delay.mat'); 

time = 1:size(delay_data_array,1);
nonzero_hist_val_vector = []; 
x_vector = []; 
y_vector = []; 
% color_vector = cell(1,size(delay_data_array,1))

for sample_pt = 1:size(delay_data_array,1)
    nonzero_hist_col = find(delay_data_array(:,sample_pt));
    if ~isempty(nonzero_hist_col)
        sample_pt; 
        nonzero_hist_val = delay_data_array(nonzero_hist_col,sample_pt); % nonzero_hist_col(nonzero_hist_col~=0)
        x =  sample_pt*2*10^-6*ones(size(nonzero_hist_val,1),1); 
        y = nonzero_hist_col*2*10^-6; 
        
        x_vector =  [x_vector;x];
        y_vector =  [y_vector;y];
        nonzero_hist_val_vector = [ nonzero_hist_val_vector; nonzero_hist_val]; 
%         
%         plot(x,y,'mo');
%         pause(0.1)
        
        
       % scatter(x,y,3,nonzero_hist_val);
        
    end
end

figure(1) 
scatter3(x_vector,y_vector,nonzero_hist_val_vector,'g');
xlabel('Elapsed Time (sec)','FontSize',12,'FontWeight','bold');
ylabel('Delay Estmate (sec)','FontSize',12,'FontWeight','bold');
zlabel('# of CH Confidence','FontSize',12,'FontWeight','bold'); 
view(-42,25)
grid on 

%%
load('left_hs_left_ear_a_delay.mat')


time = 1:size(delay_data_array,1);
left_nonzero_hist_val_vector = []; 
left_x_vector = []; 
left_y_vector = []; 
% color_vector = cell(1,size(delay_data_array,1))

for sample_pt = 1:size(delay_data_array,1)
    left_nonzero_hist_row = find(delay_data_array(:,sample_pt));
    if ~isempty(left_nonzero_hist_row)
        sample_pt; 
        left_nonzero_hist_val = delay_data_array(left_nonzero_hist_row,sample_pt); % nonzero_hist_col(nonzero_hist_col~=0)
        left_x =  sample_pt*2*10^-6*ones(size(left_nonzero_hist_val,1),1); 
        left_y = left_nonzero_hist_row*2*10^-6; 
        
        left_x_vector =  [left_x_vector;left_x];
        left_y_vector =  [left_y_vector;left_y];
        left_nonzero_hist_val_vector = [ left_nonzero_hist_val_vector; left_nonzero_hist_val]; 
%         
%         plot(x,y,'mo');
%         pause(0.1)
        
        
       % scatter(x,y,3,nonzero_hist_val);
        
    end
end

figure(2)
scatter3(left_x_vector,left_y_vector,left_nonzero_hist_val_vector,'r');
xlabel('Elapsed Time (sec)','FontSize',12,'FontWeight','bold');
ylabel('Delay Estmate (sec)','FontSize',12,'FontWeight','bold');
zlabel('# of CH Confidence','FontSize',12,'FontWeight','bold'); 

view(-42,25)
grid on 



%% overlap
figure(3)
hold on 
scatter3(x_vector,y_vector,nonzero_hist_val_vector,'g');
scatter3(left_x_vector,left_y_vector,left_nonzero_hist_val_vector,'r');
xlabel('Elapsed Time (sec)','FontSize',12,'FontWeight','bold');
ylabel('Delay Estmate (sec)','FontSize',12,'FontWeight','bold');
zlabel('# of CH Confidence','FontSize',12,'FontWeight','bold'); 
view(-42,25)
grid on 



%%  gradient plot 
% figure(2) 
% hold on 
% %scatter(x_vector,y_vector,2, nonzero_hist_val_vector); 
% scatter(left_x_vector,left_y_vector,2,left_nonzero_hist_val_vector);
end