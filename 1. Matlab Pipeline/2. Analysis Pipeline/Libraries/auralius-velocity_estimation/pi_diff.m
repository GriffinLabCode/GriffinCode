function v_est = pi_diff(y, Ts, kp, ki)

error_acc = 0;
y_hat = 0;

for k = 1 : size(y,2)
    error = y(k) - y_hat;
    error_acc = error_acc + error * Ts;
    v_est(k) = kp * error + ki * error_acc;
    y_hat = y_hat  + v_est(k)* Ts;   
end