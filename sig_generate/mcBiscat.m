% Run monte carlo analysis of BiSCAT

load ASA_baltimore


load(cfg.file_name)

load CN_test


param = [30];

for i=1:length(param)
    tic;
    
    cfg.cn_ntot = 100;
    cfg.cn_nrec = 0;
    cfg.cn_wrec = 0;
    cfg.cn_nsyn = 30;
    cfg.cn_lifparams(4:7) = [1 20 20 20];
    cfg.cn_lifparams(8:10) = [30 5 5];
    
    res.cn = runCochNuc(res.neur, ts, res.coch.Fc, cfg);
    %res = runBiscatMain(cfg);

    toc


    % Plot synaptic transconducances (g_ex, g_in, g_re)
    if cfg.cn_plottran
        figure;
        plot(ts.time, res.cn.g_ex, ts.time, res.cn.g_in)
        grid on;
        title(sprintf('Excitatory and Inhibitory Transconductances (N=%d, M=%d)', size(res.neur.spikes,2), cfg.cn_ntot))
        xlabel('Time (sec)')
        ylabel('Transconductance (dimensionless)')

        if cfg.cn_nrec > 0
            figure;
            plot(ts.time, res.cn.g_re)
            grid on;
            title(sprintf('Recurrent Synaptic Transconductances (N=%d, M=%d)', size(res.neur.spikes,2), cfg.cn_ntot))
            xlabel('Time (sec)')
            ylabel('Transconductance (dimensionless)')
        end
    end




    % Plot neuron membrane potential along with external stimulus vs. time
    if cfg.cn_plotvmem
        figure;
        plot(ts.time, res.cn.V)
        grid on; hold on;
        plot([0 ts.time(end)],[res.cn.NN.Vth res.cn.NN.Vth],'--r')
        title(sprintf('Integrate and Fire Neuron Membrane Potential (N=%d, M=%d)', size(res.neur.spikes,2), cfg.cn_ntot))
        xlabel('Time (sec)')
        ylabel('Potential (V)')
        set(gca,'YLim',[res.cn.NN.Vreset*1.2 0.12])
    end




    % display raster plot of neural activity
    if cfg.cn_rasterplot
        figure;
        rasterplot(res.cn.spikes', ts.fs);
        title('Cochlear Nucleus Spike Generation')
    end
    
end