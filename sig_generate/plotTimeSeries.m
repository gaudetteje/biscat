function plot_ts(cfg,ts)
% PLOT_TS  plots time series signals
%
% PLOT_TS(CFG,TS)  is called from RunBiscatMain.m

% plot time series data
if cfg.file_timeseries
    figure;
    plot(ts.time.*1000, ts.data);
    grid;
    xlabel('Time (ms)');
    ylabel('Acoustic Sound Pressure (Pa)');
    title(cfg.file_name,'Interpreter','none');
end

% plot spectrogram
if cfg.file_specgram
%    N = round(length(ts.time)/10);
    [S,F,T,P] = spectrogram(ts.data,window(@blackman,1024),1e3,2^11,ts.fs./1000,'yaxis');
    figure;
    surf(T,F,10*log10(abs(P)),'EdgeColor','none');
    xlabel('Time (milliseconds)')
    ylabel('Frequency (kHz)')
    zlabel('Power Spectral Density (dB)')
%    ylabel('dB SPL // 1uPa @ 1m')
    title(cfg.file_name,'Interpreter','none');
    
    colorbar;               % add colorbar
    axis tight; view(0,90);
    
end

% plot pseudo wigner-ville distribution
if cfg.file_wignerville
    figure;
    [TFR,T,F] = tfrpwv(hilbert(ts.data));        % long oversampled signals will cause out-of-memory errors, need to fix this (resample or split up signal?)
    T = T.*ts.fs; F = F./ts.fs;
    surf(T,F,TFR);  shading interp;
    xlabel('Time (seconds)')
    ylabel('Frequency (Hz)')
    title('Pseudo Wigner Ville TFR')
end