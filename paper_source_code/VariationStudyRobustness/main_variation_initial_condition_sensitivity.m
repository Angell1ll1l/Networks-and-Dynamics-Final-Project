%% main_variation_initial_condition_sensitivity.m
% 3C Variation Study 2:
% Initial-condition sensitivity of synchronization strategies.
%
% We use the author-code-style pipeline:
% Kuramoto_calculations.m and interpolateZeroCrossing.m
%
% Each block of simulations uses a different random seed. Since the author
% code randomly initializes phases inside Kuramoto_calculations.m, changing
% the seed changes the initial phase configuration and random perturbations.

clear; clc; close all;
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
figDir = fullfile(projectRoot, 'figures');
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

%% Author-style settings
N = 4;
D = zeros(N);
f_dist = ones(N,1);

dt = 0.01;
sampling = 10;
t_max = 10;

frequency_mean = 2;
f_std = 0.2;

msNoise = 35;
currNoise = msNoise*(2*pi/500);

discard = 4;

%% Initial-condition / seed settings
nSeeds = 40;          % number of different random seeds
simsPerSeed = 120;    % simulations averaged under each seed

%% Coupling parameters on author input scale
% Table 1 paper-scale values divided by 10.
conditions = {
    'Leading-leading',       [0.65, 0.15, 0.78, 0.13];
    'Leading-following',     [0.17, 0.55, 0.41, 0.55];
    'Mutual adaptation',     [0.25, 0.63, 0.23, 0.51]
};

nCond = size(conditions,1);

seedLagMeans = zeros(nCond, nSeeds, 3);

%% Run simulations
for c = 1:nCond

    conditionName = conditions{c,1};
    params = conditions{c,2};

    i1 = params(1);
    e1 = params(2);
    i2 = params(3);
    e2 = params(4);

    C = [0  i1 e1 0;
         i1 0  0  0;
         0  0  0  i2;
         0  e2 i2 0];

    for seedIdx = 1:nSeeds

        rng(seedIdx);

        collLags = zeros(simsPerSeed, 3);

        for s = 1:simsPerSeed

            Phases = Kuramoto_calculations(C, D, frequency_mean, f_std, f_dist, ...
                t_max, dt, sampling, currNoise);

            [P1ITI, P2ITI] = interpolateZeroCrossing(Phases, dt, sampling, discard);

            collLags(s,:) = local_lag_corr_author_order(P1ITI, P2ITI);
        end

        seedLagMeans(c,seedIdx,:) = mean(collLags, 1, 'omitnan');

        fprintf('%s, seed %d: lag -1 = %.3f, lag 0 = %.3f, lag +1 = %.3f\n', ...
            conditionName, seedIdx, ...
            seedLagMeans(c,seedIdx,1), seedLagMeans(c,seedIdx,2), seedLagMeans(c,seedIdx,3));
    end
end

%% Compute summary statistics
overallMean = squeeze(mean(seedLagMeans, 2, 'omitnan'));
overallSD = squeeze(std(seedLagMeans, 0, 2, 'omitnan'));

%% Plot
figure('Color','w', 'Position', [100 100 1300 450]);

lags = [-1, 0, 1];

for c = 1:nCond
    subplot(1,3,c);
    hold on;

    data = squeeze(seedLagMeans(c,:,:));  % nSeeds x 3

    % Plot seed-level results as faint connected points
    for seedIdx = 1:nSeeds
        plot(lags, data(seedIdx,:), '-', 'Color', [0.75 0.75 0.75], 'LineWidth', 0.6);
    end

    % Plot mean across seeds
    errorbar(lags, overallMean(c,:), overallSD(c,:), 'o-', ...
        'LineWidth', 2.0, 'MarkerSize', 7);

    yline(0, '--');
    xticks(lags);
    xlabel('Lag');
    ylabel('Lag correlation');
    title(conditions{c,1});
    grid on;
    ylim([-0.2, 0.45]);

    % Stability summary
    m = overallMean(c,:);
    sd = overallSD(c,:);

    txt = sprintf('Mean across seeds:\nlag -1 = %.3f\nlag 0 = %.3f\nlag +1 = %.3f\n\nSDs:\n%.3f, %.3f, %.3f', ...
        m(1), m(2), m(3), sd(1), sd(2), sd(3));

    text(-0.9, -0.16, txt, ...
        'FontSize', 8.5, ...
        'BackgroundColor', 'white', ...
        'EdgeColor', 'black');
end

sgtitle('Initial-condition sensitivity of lag-correlation patterns');
saveas(gcf, fullfile(figDir, 'figure_variation_initial_condition_sensitivity.png'));

%% Local functions
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