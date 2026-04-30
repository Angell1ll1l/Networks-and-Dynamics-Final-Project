%% main_author_style_sync_transition.m
% Author-code-style replication of synchronization transition.

clear; clc; close all;
rng(2);
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
t_max = 12;

frequency_mean = 2;
f_std = 0.2;

msNoise = 20;
currNoise = msNoise*(2*pi/500);

numSims = 200;

%% Coupling sweep on paper scale
% Paper scale g is 0.1 to 30.
% Since Kuramoto_calculations.m internally multiplies C by 10,
% we pass g/10 into the author's function.
g_values = 0.1:0.5:30;

sync_mean = zeros(length(g_values),1);
sync_sem = zeros(length(g_values),1);

for gi = 1:length(g_values)

    g = g_values(gi);
    g_input = g/10;

    C = [0 g_input g_input 0;
         g_input 0 0 0;
         0 0 0 g_input;
         0 g_input g_input 0];

    thisSync = zeros(numSims,1);

    for n = 1:numSims
        Phases = Kuramoto_calculations(C, D, frequency_mean, f_std, f_dist, ...
            t_max, dt, sampling, currNoise);

        theta1 = Phases(2,:);
        theta2 = Phases(3,:);

        thisSync(n) = sync_index_author_style(theta1, theta2);
    end

    sync_mean(gi) = mean(thisSync, 'omitnan');
    sync_sem(gi) = std(thisSync, 0, 'omitnan') / sqrt(sum(~isnan(thisSync)));

    fprintf('g = %.2f, S = %.4f\n', g, sync_mean(gi));
end

%% Summary values
threshold = 0.99;
first_idx = find(sync_mean >= threshold, 1, 'first');

if isempty(first_idx)
    threshold_g = NaN;
else
    threshold_g = g_values(first_idx);
end

[~, idx155] = min(abs(g_values - 15.5));
S_at_155 = sync_mean(idx155);

[maxS, maxIdx] = max(sync_mean);
g_at_max = g_values(maxIdx);

%% Plot
figure('Color','w', 'Position', [100 100 850 550]);

errorbar(g_values, sync_mean, sync_sem, 'LineWidth', 1.3);
hold on;

xline(15.5, '--', 'LineWidth', 1.2);
yline(threshold, '--', 'LineWidth', 1.2);

xlabel('Common coupling weight g, paper scale');
ylabel('Synchronization index');
title('Replicated synchronization transition');
grid on;
ylim([0 1.05]);

summaryText = sprintf('S first reaches %.2f at g = %.2f\nS at g = 15.5 is %.3f\nMax S = %.3f at g = %.2f\nTrials per point = %d', ...
    threshold, threshold_g, S_at_155, maxS, g_at_max, numSims);

text(1.2, 0.18, summaryText, ...
    'FontSize', 11, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'black');
saveas(gcf, fullfile(figDir, 'figure_sync_transition_author_style.png'));

%% Local function
function S = sync_index_author_style(theta1, theta2)
    phi = angle(exp(1i*(theta1 - theta2)));
    S = abs(mean(exp(1i*phi)));
end