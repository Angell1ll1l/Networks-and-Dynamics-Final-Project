%% main_replication_baseline.m
% Replication baseline for Heggli et al. four-oscillator Kuramoto model.
% Goal: simulate the four-oscillator model using representative Table 1
% coupling weights and compute lag -1, 0, +1 correlations of the two
% action oscillators.

clear; clc; close all;
rng(1);
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
figDir = fullfile(projectRoot, 'figures');
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

%% Simulation settings
T = 12;              % total simulation time in seconds
dt = 0.01;           % 10 ms step, used for higher accuracy validation
discard_time = 2;    % discard first 2 seconds, corresponding to metronome period
nTrials = 300;       % use 300 for speed first; later increase to 2000

omega_mean = 2;      % 2 Hz corresponds to 120 bpm
omega_sd = 0.2;      % paper uses SD 0.2 Hz
beta = 0.020;        % 20 ms equivalent noise level for dataset 1-style simulations

%% Coupling settings from Table 1
% Columns are [i1, e1, i2, e2]
conditions = {
    'Leading-leading',       [6.5, 1.5, 7.8, 1.3];
    'Leading-following',     [1.7, 5.5, 4.1, 5.5];
    'Mutual adaptation',     [2.5, 6.3, 2.3, 5.1]
};

allLagMeans = zeros(size(conditions,1), 3);
allLagSEMs = zeros(size(conditions,1), 3);

%% Run simulations
for c = 1:size(conditions,1)
    conditionName = conditions{c,1};
    params = conditions{c,2};

    lagCorrs = zeros(nTrials, 3);

    for r = 1:nTrials
        [t, theta] = simulate_four_oscillator(params, T, dt, omega_mean, omega_sd, beta);

        % action oscillators are oscillator 2 and oscillator 3
        theta_action_1 = theta(:,2);
        theta_action_2 = theta(:,3);

        taps1 = phase_to_taps(t, theta_action_1, discard_time);
        taps2 = phase_to_taps(t, theta_action_2, discard_time);

        iti1 = diff(taps1);
        iti2 = diff(taps2);

        lagCorrs(r,:) = lag_correlations(iti1, iti2);
    end

    allLagMeans(c,:) = mean(lagCorrs, 1, 'omitnan');
    allLagSEMs(c,:) = std(lagCorrs, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(lagCorrs),1));

    fprintf('\n%s\n', conditionName);
    fprintf('Lag -1: %.4f, Lag 0: %.4f, Lag +1: %.4f\n', allLagMeans(c,1), allLagMeans(c,2), allLagMeans(c,3));
end

%% Plot with numerical values shown directly in the figure

lags = [-1, 0, 1];

figure('Color','w', 'Position', [100 100 1200 500]);

for c = 1:size(conditions,1)
    subplot(1,3,c);
    errorbar(lags, allLagMeans(c,:), allLagSEMs(c,:), 'o-', 'LineWidth', 1.5);
    yline(0, '--');
    xticks(lags);
    xlabel('Lag');
    ylabel('Cross-correlation');
    title(conditions{c,1});
    ylim([-1, 1]);
    grid on;

    % Put numerical values directly inside each plot
    txt = sprintf('lag -1 = %.3f\nlag  0 = %.3f\nlag +1 = %.3f', ...
        allLagMeans(c,1), allLagMeans(c,2), allLagMeans(c,3));

    text(-0.9, -0.75, txt, 'FontSize', 10, ...
        'BackgroundColor', 'white', 'EdgeColor', 'black');
end

sgtitle('Replicated lag-correlation patterns from Table 1 coupling weights');
saveas(gcf, fullfile(figDir, 'figure_replication_baseline.png'));