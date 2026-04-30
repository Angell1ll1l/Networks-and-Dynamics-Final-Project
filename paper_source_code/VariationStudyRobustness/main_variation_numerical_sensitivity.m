%% main_variation_numerical_sensitivity.m
% 3C Variation Study 4:
% Numerical step-size and time-horizon sensitivity.
%
% This script tests whether the lag-pattern conclusions depend on
% discretization step size dt or total simulation time T.
%
% It uses the author-code-style pipeline:
% Kuramoto_calculations.m and interpolateZeroCrossing.m

clear; clc; close all;
rng(5);
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
figDir = fullfile(projectRoot, 'figures');
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

%% Shared settings
N = 4;
D = zeros(N);
f_dist = ones(N,1);

frequency_mean = 2;
f_std = 0.2;

msNoise = 35;
currNoise = msNoise*(2*pi/500);

discard = 4;
numSims = 400;

%% Coupling parameters on author input scale
% Table 1 paper-scale values divided by 10.
conditions = {
    'Leading-leading',       [0.65, 0.15, 0.78, 0.13];
    'Leading-following',     [0.17, 0.55, 0.41, 0.55];
    'Mutual adaptation',     [0.25, 0.63, 0.23, 0.51]
};

nCond = size(conditions,1);

%% Test A: step-size sensitivity
dtValues = [0.005, 0.01, 0.025, 0.05];
fixedT = 10;

stepLagMeans = zeros(nCond, length(dtValues), 3);
stepScores = zeros(nCond, length(dtValues));

for c = 1:nCond

    conditionName = conditions{c,1};
    base = conditions{c,2};

    C = build_C(base);

    for di = 1:length(dtValues)

        dt = dtValues(di);

        % Keep the stored phase sampling interval approximately 0.1 s.
        % This avoids making dt=0.05 store only every 0.5 s.
        sampling = max(1, round(0.1/dt));

        collLags = zeros(numSims, 3);

        for s = 1:numSims

            Phases = Kuramoto_calculations(C, D, frequency_mean, f_std, f_dist, ...
                fixedT, dt, sampling, currNoise);

            [P1ITI, P2ITI] = interpolateZeroCrossing(Phases, dt, sampling, discard);

            collLags(s,:) = local_lag_corr_author_order(P1ITI, P2ITI);
        end

        r = mean(collLags, 1, 'omitnan');
        stepLagMeans(c,di,:) = r;
        stepScores(c,di) = diagnostic_score(c, r);

        fprintf('Step test: %s, dt = %.3f, sampling = %d, score = %.3f, lags = [%.3f %.3f %.3f]\n', ...
            conditionName, dt, sampling, stepScores(c,di), r(1), r(2), r(3));
    end
end

%% Test B: time-horizon sensitivity
TValues = [6, 10, 12, 20];
fixedDt = 0.01;
fixedSampling = 10;

timeLagMeans = zeros(nCond, length(TValues), 3);
timeScores = zeros(nCond, length(TValues));

for c = 1:nCond

    conditionName = conditions{c,1};
    base = conditions{c,2};

    C = build_C(base);

    for ti = 1:length(TValues)

        t_max = TValues(ti);

        collLags = zeros(numSims, 3);

        for s = 1:numSims

            Phases = Kuramoto_calculations(C, D, frequency_mean, f_std, f_dist, ...
                t_max, fixedDt, fixedSampling, currNoise);

            [P1ITI, P2ITI] = interpolateZeroCrossing(Phases, fixedDt, fixedSampling, discard);

            collLags(s,:) = local_lag_corr_author_order(P1ITI, P2ITI);
        end

        r = mean(collLags, 1, 'omitnan');
        timeLagMeans(c,ti,:) = r;
        timeScores(c,ti) = diagnostic_score(c, r);

        fprintf('Time test: %s, T = %.1f, score = %.3f, lags = [%.3f %.3f %.3f]\n', ...
            conditionName, t_max, timeScores(c,ti), r(1), r(2), r(3));
    end
end

%% Plot step-size sensitivity
figure('Color','w', 'Position', [100 100 1300 450]);
tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'compact');

for c = 1:nCond
    nexttile;
    plot(dtValues, stepScores(c,:), 'o-', 'LineWidth', 1.8, 'MarkerSize', 7);
    xline(0.01, '--', 'LineWidth', 1.1);
    xlabel('Step size dt (s)');
    ylabel('Diagnostic score');
    title(conditions{c,1});
    grid on;

    txt = sprintf('Baseline dt=0.01\nscore = %.3f', stepScores(c,dtValues==0.01));
    xl = xlim;
yl = ylim;
text(xl(1)+0.58*(xl(2)-xl(1)), yl(1)+0.78*(yl(2)-yl(1)), txt, ...
    'FontSize', 9, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'black');
end

sgtitle('Numerical step-size sensitivity');
saveas(gcf, fullfile(figDir, 'figure_variation_step_sensitivity.png'));

%% Plot time-horizon sensitivity
figure('Color','w', 'Position', [100 100 1300 450]);
tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'compact');

for c = 1:nCond
    nexttile;
    plot(TValues, timeScores(c,:), 's-', 'LineWidth', 1.8, 'MarkerSize', 7);
    xline(10, '--', 'LineWidth', 1.1);
    xlabel('Simulation time T (s)');
    ylabel('Diagnostic score');
    title(conditions{c,1});
    grid on;

    txt = sprintf('Baseline T=10 s\nscore = %.3f', timeScores(c,TValues==10));
    xl = xlim;
yl = ylim;
text(xl(1)+0.58*(xl(2)-xl(1)), yl(1)+0.78*(yl(2)-yl(1)), txt, ...
    'FontSize', 9, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'black');
end

sgtitle('Time-horizon sensitivity');
saveas(gcf, fullfile(figDir, 'figure_variation_time_sensitivity.png'));

%% Local functions

function C = build_C(params)
    i1 = params(1);
    e1 = params(2);
    i2 = params(3);
    e2 = params(4);

    C = [0  i1 e1 0;
         i1 0  0  0;
         0  0  0  i2;
         0  e2 i2 0];
end

function score = diagnostic_score(conditionIndex, r)
    r_minus = r(1);
    r_zero = r(2);
    r_plus = r(3);

    if conditionIndex == 1
        % Leading-leading: all lag correlations should be close to zero.
        % Lower is better.
        score = max(abs(r));
    elseif conditionIndex == 2
        % Leading-following: lag +1 should dominate.
        % Higher is better.
        score = r_plus - max(r_minus, r_zero);
    else
        % Mutual adaptation: side lags should dominate lag 0.
        % Higher is better.
        score = 0.5*(r_minus + r_plus) - r_zero;
    end
end

function r = local_lag_corr_author_order(x, y)
    x = x(:);
    y = y(:);

    m = min(length(x), length(y));
    x = x(1:m);
    y = y(1:m);

    if m < 4
        r = [NaN NaN NaN];
        return;
    end

    r_minus = safe_corr_local(x(2:end), y(1:end-1));
    r_zero  = safe_corr_local(x, y);
    r_plus  = safe_corr_local(x(1:end-1), y(2:end));

    r = [r_minus, r_zero, r_plus];
end

function r = safe_corr_local(x, y)
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