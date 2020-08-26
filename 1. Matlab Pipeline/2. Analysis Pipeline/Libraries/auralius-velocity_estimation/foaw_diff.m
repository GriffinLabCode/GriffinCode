function v_est = foaw_diff(y, Ts, m, d)

slope = 0;                                  % estimate

for k = 2 : size(y,2)
    window_len = 0;
    can_increase_window = true;
    
    while 1
        window_len = window_len + 1;

        if (window_len > m || k - window_len == 0)
            window_len = window_len - 1;
            break;
        end

        % slope of the line of: y(k) = slope * k * Ts + c
        % this line is passing through y_k to y_k-i
        slope_ = slope;
        slope = (y(k) - y(k - window_len)) / (window_len * Ts);              
                
        if (window_len > 1)
            c = y(k) - slope * k * Ts;
            
            % Check every point from k to k-i
            for j = 1 : window_len - 1
                delta = y(k - j) - (c + slope * (k - j) * Ts);
                if (abs(delta) > 2*d)
                    can_increase_window = false;
                    window_len = window_len - 1;
                    slope = slope_;
                    break;
                end %% end if
            end %% end for
            
        end %% end if

        if can_increase_window == false;            
            break;
        end       
    end    
    
    v_est(k) = slope;  
end

