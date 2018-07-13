function l_r_singal_maker()
close all
clear

% Load broadcast
% [signal , fs] = audioread('bat_special.wav');
% broadcast = signal(1:1903);

load ('lr_broadcast.mat')

% Select location in polar coordinates


FigHandle = figure('Position', [100, 100, 1000, 500]);
hold on
x_semi = linspace(-5,5,100);
y_semi = sqrt(5^2-x_semi.^2);
plot(x_semi,y_semi)
grid on
grid minor

[x,y] = ginput(1);    % click mouse on desired initial value

plot([0,x],[0,y],'r', 'LineWidth',2)
plot([0,x],[0,y],'bo', 'MarkerSize',6,'LineWidth',3)


[theta,rho] = cart2pol(x,y);
rad_to_deg = 57.2958;
theta_deg = theta*rad_to_deg-90;

% find flat seperation baseline
dist_time_conversion = 58*10^-6; % cm to usec

flat_distance = rho*100;% convert rho (m) into cm
flat_time = flat_distance*dist_time_conversion; % in SEC

% implement time delay effect between ears
theta_time_conversion = 1*10^-6; % deg to usec

% implememnt amplitude difference effect between ears
theta_intensity_conversion = 0.1; % deg into intensity
broadcast_db = mag2db(broadcast);
if theta_deg >0
    intensity_left = broadcast*db2mag(.5*abs(theta_deg)*theta_intensity_conversion);
    intensity_right = broadcast/db2mag(.5*abs(theta_deg)*theta_intensity_conversion);
    time_delay_left = flat_time - .5*abs(theta_deg)*theta_time_conversion;
    time_delay_right = flat_time + .5*abs(theta_deg)*theta_time_conversion;
elseif theta_deg<0
    intensity_left = broadcast/db2mag(.5*abs(theta_deg)*theta_intensity_conversion);
    intensity_right = broadcast*db2mag(.5*abs(theta_deg)*theta_intensity_conversion);
    time_delay_left = flat_time + .5*abs(theta_deg)*theta_time_conversion;
    time_delay_right = flat_time - .5*abs(theta_deg)*theta_time_conversion;
end



% Save to .wav
time_to_taps = 2*10^-6;

signal_left = zeros(1,15000);
signal_left(1:size(broadcast,1)) = broadcast;
% net_time_delay = flat_time+time_delay_left;
net_index_delay_left = ceil(time_delay_left/time_to_taps);
signal_left(net_index_delay_left:net_index_delay_left+size(broadcast,1)-1) = intensity_left;

signal_right = zeros(1,15000);
signal_right(1:size(broadcast,1)) = broadcast;
%net_time_delay = flat_time+time_delay_right;
net_index_delay_right = ceil(time_delay_right/time_to_taps);
signal_right(net_index_delay_right:net_index_delay_right+size(broadcast,1)-1) = intensity_right;

figure(2)
subplot(2,1,1)
plot(signal_left,'r')
axis([0 15000 -3 3])
subplot(2,1,2)
plot(signal_right,'g')
axis([0 15000 -3 3])

% % % %% Decoding test
% % % alt_const = -40*10^-6;
% % % delta_t = time_delay_left-time_delay_right; %  mean(left_y_vector)-mean(right_y_vector);
% % % %intensity_val_left = (mean(left_y_vector)-delta_t)/(alt_const);
% % %
% % % if delta_t <0% LHS object
% % %     delta_deg = delta_t/(theta_time_conversion + theta_intensity_conversion*alt_const);
% % %     delta_rad = (delta_deg)/rad_to_deg;
% % % elseif delta_t >0% if RHS object
% % %     delta_deg = delta_t/(theta_time_conversion - theta_intensity_conversion*alt_const);
% % %     delta_rad = (delta_deg)/rad_to_deg;
% % % end
%%
close all
% save('left_hs.mat')
% fs = 500*10^3;
% signal_left = signal_left./(max(abs(signal_left)));
% audiowrite('left_hs_left_ear.wav',signal_left,fs);
% signal_right = signal_right./(max(abs(signal_right)));
% audiowrite('left_hs_right_ear.wav',signal_right,fs);
% 
% save('left_hs_e.mat')
% fs = 500*10^3;
% signal_left = signal_left./(max(abs(signal_left)));
% audiowrite('left_hs_left_ear_e.wav',signal_left,fs);
% signal_right = signal_right./(max(abs(signal_right)));
% audiowrite('left_hs_right_ear_e.wav',signal_right,fs);

save('neg15_1.mat')
fs = 500*10^3;
signal_left = signal_left./(max(abs(signal_left)));
audiowrite('left_ear_neg15_1.wav',signal_left,fs);
signal_right = signal_right./(max(abs(signal_right)));
audiowrite('right_ear_neg15_1.wav',signal_right,fs);

% %
% save('right_hs_e.mat')
% fs = 500*10^3;
% signal_left = signal_left./(max(abs(signal_left)));
% audiowrite('right_hs_left_ear_e.wav',signal_left,fs);
% signal_right = signal_right./(max(abs(signal_right)));
% audiowrite('right_hs_right_ear_e.wav',signal_right,fs);
end