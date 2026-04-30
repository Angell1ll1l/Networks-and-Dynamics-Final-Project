%% main_replication_sync_transition.m
% Replicate the synchronization transition analysis.
% We increase all four coupling parameters together and compute
% synchronization between the two action oscillators.

clear; clc; close all;
rng(2);
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
figDir = fullfile(projectRoot, 'figures');
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

%% Simulation settings
T = 12;
dt = 0.025;          % 25 ms step, matching model-behavior analysis
discard_time = 2;
nTrials = 80;        % use 80 first for speed; later can increase

omega_mean = 2;
omega_sd = 0.2;
beta = 0.020;

coupling_values = 0.1:0.5:30;   % coarser than paper for speed first
sync_mean = zeros(length(coupling_values),1);
sync_sem = zeros(length(coupling_values),1);

%% Run coupling sweep
for c = 1:length(coupling_values)
    g = coupling_values(c);

    trial_sync = zeros(nTrials,1);

    for r = 1:nTrials
        params = [g, g, g, g];

        [t, theta] = simulate_four_oscillator(params, T, dt, omega_mean, omega_sd, beta);

        idx = t >= discard_time;

        theta1 = theta(idx,2);   % action oscillator person 1
        theta2 = theta(idx,3);   % action oscillator person 2

        trial_sync(r) = synchronization_index(theta1, theta2);
    end

    sync_mean(c) = mean(trial_sync, 'omitnan');
    sync_sem(c) = std(trial_sync, 0, 'omitnan') / sqrt(sum(~isnan(trial_sync)));

    fprintf('coupling = %.2f, sync = %.4f\n', g, sync_mean(c));
end

%% Find near-complete synchronization threshold
threshold = 0.99;
first_idx = find(sync_mean >= threshold, 1, 'first');

if isempty(first_idx)
    threshold_coupling = NaN;
else
    threshold_coupling = coupling_values(first_idx);
end

[max_sync, max_idx] = max(sync_mean);
max_coupling = coupling_values(max_idx);
summaryText = sprintf('Threshold %.2f first reached at g = %.2f\nMax sync = %.3f at g = %.2f\nTrials per point = %d', ...
    threshold, threshold_coupling, max_sync, max_coupling, nTrials);

%% Plot with numerical summary inside figure
figure('Color','w', 'Position', [100 100 850 550]);

errorbar(coupling_values, sync_mean, sync_sem, 'LineWidth', 1.3);
hold on;
xline(threshold_coupling, '--', 'LineWidth', 1.2);
yline(threshold, '--', 'LineWidth', 1.2);

xlabel('Common coupling weight');
ylabel('Synchronization index');
title('Replication of synchronization transition in the four-oscillator model');
grid on;
ylim([0 1.05]);

title('Author-code-aligned synchronization transition');

text(2, 0.18, summaryText, ...
    'FontSize', 11, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'black');
saveas(gcf, fullfile(figDir, 'figure_replication_sync_transition.png'));