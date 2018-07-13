function generate_sweep_data()
% Read in hfm 25dB 50usec
hfm_struct  = load('hfm_25db_50us.mat');
hfm_raw     = hfm_struct.ts;
names = fieldnames(hfm_raw);

hfm_fs     = hfm_raw.fs;
hfm_time = hfm_raw.time;
hfm_data = hfm_raw.data;

figure(1)
spectrogram(hfm_data,blackman(256),250,256,hfm_fs,'yaxis')
ax = gca;
set(gca,'YScale','log')
axis([0, 15, 10, inf])
shg

% Make the impulse
imp_fs     = hfm_raw.fs;
imp_time = hfm_raw.time;

imp_index   = [find(imp_time == .002):find(imp_time == .00202)]; % these are .1msec = 100usec wide
echo_index = [find(imp_time == .0090):find(imp_time == .00902)];

imp_data  = zeros(size(hfm_data));
imp_data(imp_index) = max(hfm_data);
imp_data(echo_index) = max(hfm_data); % no interference, just another click

figure(2)
spectrogram(imp_data,blackman(256),250,256,imp_fs,'yaxis')
ax = gca;
set(gca,'YScale','log')
axis([0, 15, 10, inf])
shg


ts.fs = imp_fs;
ts.time = imp_time;
ts.data = imp_data; 
save('imp_100usec_wide.mat','ts')

end