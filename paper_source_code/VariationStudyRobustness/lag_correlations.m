function r = lag_correlations(x, y)
% Compute lag -1, 0, +1 correlations between two ITI time series.
%
% Convention:
% lag -1: x(2:end) with y(1:end-1)
% lag  0: x(1:end) with y(1:end)
% lag +1: x(1:end-1) with y(2:end)

    m = min(length(x), length(y));
    x = x(1:m);
    y = y(1:m);

    if m < 4
        r = [NaN, NaN, NaN];
        return;
    end

    r_minus = safe_corr(x(2:end), y(1:end-1));
    r_zero  = safe_corr(x, y);
    r_plus  = safe_corr(x(1:end-1), y(2:end));

    r = [r_minus, r_zero, r_plus];
end