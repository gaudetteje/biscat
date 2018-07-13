function scat_spect_trans(creature_file,plot_opt_trans,sample_pt,num_ch,null_ch_list,line_length,echo_count,vertical_offset,inf_roi)
% INPUT:
%
%
% OUTPUT:
%
%
% DESCRIPTION:
% Spectral interference processing is done here
%
disp_ch = sprintf('%d, ',vertical_offset(null_ch_list));
fprintf('SPECT_TRANS SAYS: Echo # %d has Nulls @ kHz CH of %s ',echo_count,disp_ch)


%% Show me dah Null CHs (Dechirped)  - null channels and CD will plot on same plot? yes cuz cd only happens once
s5 = subplot(2,3,5);
s5.LineWidth = 1.5;
s5.FontSize = 16;
hold on

nullcd_plot_opt = 1; % for sure we want this
null_ch_logical = zeros(1,num_ch);
null_ch_logical(null_ch_list) = 1;
tri_level_opt = 1;
[glint_usec,glint_usec_popularity,glint_label,cd_array] =  scat_interference_coincidence_detector(tri_level_opt,nullcd_plot_opt,sample_pt,null_ch_logical,num_ch,echo_count,vertical_offset,inf_roi);

% % label 2 or 3?
% trap_label = 3;
% for b = 1:size(cd_array,2)-1
%     interf_data = vertical_offset(logical(cd_array(:,b).*(glint_label(:,b)==trap_label)));
%     if ~isempty(interf_data)
%     plot(glint_usec(b)*ones(size(interf_data)),interf_data,'b.')
%     end
% end

trans_file = strcat(creature_file,'_interf.mat');
save(trans_file,'glint_usec_popularity')
%axis([vertical_offset(1) vertical_offset(end) vertical_offset(1) vertical_offset(end)])


% title({'Running Deconvolution';sprintf('Time Frame = %s',num2str(sample_pt))},'FontSize', 20)
% ylabel('Cepstrum Level','FontSize', 20)
% xlabel('Perceived Delay (Raw Tap Count)','FontSize', 20)
% axis([0 line_length 0 1.3*glint_seperation(end)])


nonzero_usec = glint_usec(glint_usec_popularity~=0);
nonzero_pop = glint_usec_popularity(glint_usec_popularity~=0)

copy_to_excel = [nonzero_usec,nonzero_pop]
%% Echo Interefence - 2D Image

hold on
seperation_hz = zeros(size(vertical_offset,1)-1,1);
for u = 2:1:size(vertical_offset,1)
    seperation_hz(u-1) = (vertical_offset(u)-vertical_offset(1))/10^3;
end

s6 = subplot(2,3,6)
cla(s6)
hold on
s6.LineWidth = 1.5;
s6.FontSize = 16;

title('Interefence Pattern Image','FontSize', 20)
ylabel('Image Strength','FontSize', 20)
xlabel('Null Seperation (kHz)','FontSize', 20)
axis([seperation_hz(1) seperation_hz(end) 0 .5])
hold on

% plot(glint_usec,glint_usec_popularity,'r',glint_usec,glint_usec_popularity,'bo','MarkerSize',4,'MarkerFaceColor','b')
%plot((glint_usec(inf_roi))glint_usec_popularity(inf_roi),'r',glint_usec(inf_roi),glint_usec_popularity(inf_roi),'bo','MarkerSize',4,'MarkerFaceColor','b')
p = plot(glint_usec,glint_usec_popularity/num_ch,'LineWidth',3,'Color', [153 0 53]/255);
plot(glint_usec,glint_usec_popularity/num_ch,'o','MarkerSize',5,'MarkerEdgeColor', [153 0 153]/255,'MarkerFaceColor', [102 0 204]/255);

hold off
load('int_plot.mat')
frame = getframe(1);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,gifname,'gif','WriteMode','append');
save('int_plot.mat','gifname','cm','imind','im','frame')


%%  Running Perceived Delays & Interference -2D Image
% s9 = subplot(2,3,9);
% title({'Running Perceived Delays &';'Interference -2D Image '},'FontSize', 20)
% ylabel('Cepstrum Level','FontSize', 20)
% xlabel('Null Seperation','FontSize', 20)
%
% % figure(echo_count*10);
% hold on
% % dummy_ones = ones(10,1);
% % for u = 1:length(glint_delays)
% %     plot(echo_delay+glint_delays(u)*dummy_ones, linspace(0,glint_delays_popularity(u),size(dummy_ones,1)),'r','LineWidth',2);
% % end
% plot(glint_delays, glint_delays_popularity,'b','LineWidth',2);
% plot(glint_delays, glint_delays_popularity,'r*','MarkerSize',5);
% axis([0 1 0 1.5*max(glint_delays_popularity)])
% title(sprintf('Spectral Content of Echo #%d',echo_count),'FontSize', 20)
% ylabel('Delay Est. (xx)','FontSize', 20)
% xlabel('Standard Time (unit time)','FontSize', 20)
% hold off
%




end