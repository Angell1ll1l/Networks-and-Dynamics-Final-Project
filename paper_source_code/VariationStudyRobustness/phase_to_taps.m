function taps = phase_to_taps(t, theta, discard_time)
% Convert phase trajectory to tap times.
% We count a tap whenever the unwrapped phase crosses a multiple of 2*pi.
% Linear interpolation is used to estimate crossing time.

    theta_unwrapped = unwrap(theta);
    k_min = ceil(theta_unwrapped(1)/(2*pi));
    k_max = floor(theta_unwrapped(end)/(2*pi));

    taps = [];

    for k = k_min:k_max
        target = 2*pi*k;

        idx = find(theta_unwrapped(1:end-1) < target & theta_unwrapped(2:end) >= target, 1);

        if ~isempty(idx)
            t1 = t(idx);
            t2 = t(idx+1);
            th1 = theta_unwrapped(idx);
            th2 = theta_unwrapped(idx+1);

            crossing_time = t1 + (target - th1) * (t2 - t1) / (th2 - th1);

            if crossing_time >= discard_time
                taps(end+1,1) = crossing_time;
            end
        end
    end
end