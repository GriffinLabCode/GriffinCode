function v_est = euler_diff(y, Ts)

v_est = zeros(1, length(y));

for k = 1 : size(y,2) - 1
    v_est(k + 1) = (y(k + 1) - y(k)) / Ts;
end