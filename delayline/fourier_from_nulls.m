function fourier_from_nulls()


clc

load('echo_delay_est_list.mat')

figure(90)
% plot(echo_delay_est_list)
% shg 
clean_signal = echo_delay_est_list(10:145);
% plot(clean_signal,'r*','MarkerSize',5)

time = 1:length(clean_signal)';
high_res_time = 0:.1:time(end);

high_res_sig = interp1(time,clean_signal,high_res_time);
high_res_sig = high_res_sig(~isnan(high_res_sig)); 
high_res_time = high_res_time(~isnan(high_res_sig)); 
plot(time,clean_signal,'r*',high_res_time,high_res_sig,':.');

%% https://www.mathworks.com/help/matlab/ref/fft.html
figure(91)
Fs = 500;            % Sampling frequency
L = length(high_res_sig);             % Length of signal
% t = (0:L-1)*T;        % Time vector

y = fft(high_res_sig); 

P2 = abs(y/L);
P1 = P2(1:ceil(L/2+1));
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
plot(P1)
axis([0 100 0 500])
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

end