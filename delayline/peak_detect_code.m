smoothness = 10;
    [rect_env,~] = envelope(neural_data,smoothness,'peak');
    
    % Local max values and location:
    %   [pks,locs] = findpeaks(rect_env);
%     cla(subplot(3,2,6))
%     subplot(3,2,6)
%     hold on
    prom_sensitivity = .05;
    sensitivity = .05;
    findpeaks(rect_env,'MinPeakProminence',prom_sensitivity*max(rect_env),'MinPeakHeight',sensitivity*max(rect_env));
    [pks,locs,w,prom] = findpeaks(rect_env,'MinPeakProminence',prom_sensitivity*max(rect_env),'MinPeakHeight',sensitivity*max(rect_env));
 