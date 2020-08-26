clear all
close all

%% Generate noisy signal
Ts = 0.005;                                 % 200 Hz
t = 0 : Ts : 10;
y = 10 * sin(t);                            % Position signal
y_dot = 10 * cos(t);                        % Actual velocity
A = 0.05;
noise = A * 2 * rand(1, size(t,2)) - 1;     % Evenly distributed noisy 
                                            % signal boundary: ¦noise¦ < A
y = y + noise;

%% 
d = 0.05;                                   % position noise boundary
m = 20;

v_est1 = euler_diff(y, Ts);
v_est2 = foaw_diff(y, Ts, m, d);
v_est3 = pi_diff(y, Ts, 10, 0.5);

figure
hold on
plot(t, v_est1, 'g')
plot(t, v_est2, 'r')
plot(t, v_est3, 'b')

legend('euler', 'foaw', 'pi');