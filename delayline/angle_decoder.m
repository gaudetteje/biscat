function angle_decoder()
%%
close all
% load('right_hs.mat');
% left_ear = load('right_hs_left_ear_delay_data.mat');
% right_ear = load('right_hs_right_ear_delay_data.mat');
% 
load('left_hs_a.mat');
left_ear = load('left_hs_left_ear_a_delay.mat');
right_ear = load('left_hs_right_ear_a_delay.mat');


% load('forward.mat');
% left_ear = load('forward_left_ear_delay.mat');
% right_ear = load('forward_right_ear_delay.mat');


%% Grab Delay Data from Ears

%% RIGHT
right_delay_data_array = right_ear.delay_data_array;
right_nonzero_hist_val_vector = [];
right_x_vector = [];
right_y_vector = [];

for sample_pt = 1:size(right_delay_data_array,1)
    right_nonzero_hist_row = find(right_delay_data_array(:,sample_pt));
    if ~isempty(right_nonzero_hist_row)
        sample_pt;
        right_nonzero_hist_val = right_delay_data_array(right_nonzero_hist_row,sample_pt); % nonzero_hist_col(nonzero_hist_col~=0)
        right_x =  sample_pt*2*10^-6*ones(size(right_nonzero_hist_val,1),1);
        right_y = right_nonzero_hist_row*2*10^-6;
        
        right_x_vector =  [right_x_vector;right_x];
        right_y_vector =  [right_y_vector;right_y];
        right_nonzero_hist_val_vector = [ right_nonzero_hist_val_vector; right_nonzero_hist_val];
        
    end
end

%% LEFT
left_delay_data_array = left_ear.delay_data_array;
left_nonzero_hist_val_vector = [];
left_x_vector = [];
left_y_vector = [];

for sample_pt = 1:size(left_delay_data_array,1)
    left_nonzero_hist_row = find(left_delay_data_array(:,sample_pt));
    if ~isempty(left_nonzero_hist_row)
        sample_pt;
        left_nonzero_hist_val = left_delay_data_array(left_nonzero_hist_row,sample_pt); % nonzero_hist_col(nonzero_hist_col~=0)
        left_x =  sample_pt*2*10^-6*ones(size(left_nonzero_hist_val,1),1);
        left_y = left_nonzero_hist_row*2*10^-6;
        
        left_x_vector =  [left_x_vector;left_x];
        left_y_vector =  [left_y_vector;left_y];
        left_nonzero_hist_val_vector = [ left_nonzero_hist_val_vector; left_nonzero_hist_val];
        
    end
end

%% time signal
figure(10)
% figure(2)
% subplot(2,1,1)
% plot((1:7000)/(500e3),signal_left(1:7000),'r')
% cut = .02;
% axis([0 cut -3 3])
% xlabel('Time (sec)')
% subplot(2,1,2)
% plot((1:7000)/(500e3),signal_right(1:7000),'g')
% axis([0 cut  -3 3])
% xlabel('Time (sec)')

%% DECODE
% constants
alt_const = 40*10^-6;
rad_to_deg = 57.2958;
dist_time_conversion = 58*10^-6; % in units sec/cm so converts cm to usec
theta_time_conversion = 1*10^-6; % [sec/deg] units so it converts deg to usec
theta_intensity_conversion = 0.1; % [dB per deg] converts deg into intensity dB

% broadcast_db = mag2db(broadcast);
% if theta_deg >0
%     intensity_left = .5*broadcast*db2mag(.5*abs(theta_deg)*theta_intensity_conversion);
%     intensity_right = .5*broadcast/db2mag(.5*abs(theta_deg)*theta_intensity_conversion);
% elseif theta_deg<0
%     intensity_left = .5*broadcast/db2mag(.5*abs(theta_deg)*theta_intensity_conversion);
%     intensity_right = .5*broadcast*db2mag(.5*abs(theta_deg)*theta_intensity_conversion);
% end

% Decode distance

% Decode angle

delta_t = mean(right_y_vector)-mean(left_y_vector);
theta_v1 = (mean(left_y_vector)-delta_t)/(-.5*theta_time_conversion);

decoded_flat_t = mean([left_y_vector;right_y_vector]);
mean_left = mean(left_y_vector);
mean_right =  mean(right_y_vector);
left_diff_t = mean_left-decoded_flat_t;
right_diff_t =mean_right -decoded_flat_t;

new_const = theta_time_conversion + theta_intensity_conversion*alt_const; 
if delta_t >0% LHS object
    delta_deg = (delta_t)/(new_const);
    delta_rad = (delta_deg+90)/rad_to_deg;
elseif delta_t <0% if RHS object
    delta_deg = delta_t/(new_const);
    delta_rad = (delta_deg-90)/rad_to_deg;
end

% flat_dist_meters = mean([left_y_vector;right_y_vector])*(1/(dist_time_conversion*10^2));
% if mean(left_y_vector) < mean(right_y_vector)% LHS object
%     delta_deg = delta_t/(theta_time_conversion + theta_intensity_conversion*alt_const);
%     delta_rad = (delta_deg)/rad_to_deg;
% elseif mean(left_y_vector) > mean(right_y_vector) % if RHS object
%     delta_deg = delta_t/(theta_time_conversion - theta_intensity_conversion*alt_const);
%     delta_rad = (delta_deg)/rad_to_deg;
% end

flat_dist_meters = decoded_flat_t*(1/(dist_time_conversion*10^2));
[decoded_x,decoded_y] = pol2cart(delta_rad,flat_dist_meters);

%% PLot
FigHandle = figure('Position', [100, 100, 1000, 500]);
hold on
x_semi = linspace(-5,5,100);
y_semi = sqrt(5^2-x_semi.^2);
plot(x_semi,y_semi)
grid on
grid minor

g = plot([0,x],[0,y],'b', 'LineWidth',2);
d = plot([0,decoded_x],[0,decoded_y],'r', 'LineWidth',2);
legend(g,'gnd truth')
legend(d,'decoded')
plot([0,x],[0,y],'bo', 'MarkerSize',6,'LineWidth',3)
plot([0,decoded_x],[0,decoded_y],'ro', 'MarkerSize',6,'LineWidth',3)


end