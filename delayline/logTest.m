function logTest

start = 20e+3;
stop = 100e+3;
numsteps = 80;
x = 0:1:numsteps;
% green wood 
% vabers law 
stepsize = (exp(5) - exp(1))/numsteps;
y = exp(1) + stepsize .* x;

close all
plot(x, y,'r.');

lny = log(y);

figure
plot(x, 20*lny,'r.');

end