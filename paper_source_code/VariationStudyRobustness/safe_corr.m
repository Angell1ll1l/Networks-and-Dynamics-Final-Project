function r = safe_corr(x, y)
% Correlation with protection against zero variance or invalid input.

    x = x(:);
    y = y(:);

    valid = ~isnan(x) & ~isnan(y);
    x = x(valid);
    y = y(valid);

    if length(x) < 3 || std(x) == 0 || std(y) == 0
        r = NaN;
    else
        C = corrcoef(x, y);
        r = C(1,2);
    end
end