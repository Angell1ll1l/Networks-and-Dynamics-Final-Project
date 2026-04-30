%% main_variation_noise_sweep.m
% 3C Variation Study 1:
% Noise sensitivity of synchronization strategies.
%
% This script uses the author-code-style pipeline:
% Kuramoto_calculations.m and interpolateZeroCrossing.m

clear; clc; close all;
rng(3);
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

discard = 4;
numSims = 600;

%% Noise levels in milliseconds
noiseLevels = [0, 10, 20, 35, 50, 80];

%% Coupling parameters on author input scale
% These are Table 1 paper-scale values divided by 10.
conditions = {
    'Leading-leading',       [0.65, 0.15, 0.78, 0.13];
    'Leading-following',     [0.17, 0.55, 0.41, 0.55];
    'Mutual adaptation',     [0.25, 0.63, 0.23, 0.51]
};

nCond = size(conditions,1);
nNoise = length(noiseLevels);

lagMeans = zeros(nCond, nNoise, 3);
lagSEMs = zeros(nCond, nNoise, 3);

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

    for ni = 1:nNoise

        msNoise = noiseLevels(ni);
        currNoise = msNoise*(2*pi/500);

        collLags = zeros(numSims, 3);

        for s = 1:numSims

            Phases = Kuramoto_calculations(C, D, frequency_mean, f_std, f_dist, ...
                t_max, dt, sampling, currNoise);

            [P1ITI, P2ITI] = interpolateZeroCrossing(Phases, dt, sampling, discard);

            collLags(s,:) = local_lag_corr_author_order(P1ITI, P2ITI);
        end

        lagMeans(c,ni,:) = mean(collLags, 1, 'omitnan');
        lagSEMs(c,ni,:) = std(collLags, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(collLags),1));

        fprintf('%s, noise = %d ms: lag -1 = %.3f, lag 0 = %.3f, lag +1 = %.3f\n', ...
            conditionName, msNoise, ...
            lagMeans(c,ni,1), lagMeans(c,ni,2), lagMeans(c,ni,3));
    end
end

%% Plot
figure('Color','w', 'Position', [100 100 1300 450]);

for c = 1:nCond
    subplot(1,3,c);
    hold on;

    m1 = squeeze(lagMeans(c,:,1));
    m0 = squeeze(lagMeans(c,:,2));
    p1 = squeeze(lagMeans(c,:,3));

    plot(noiseLevels, m1, 'o-', 'LineWidth', 1.4);
    plot(noiseLevels, m0, 's-', 'LineWidth', 1.4);
    plot(noiseLevels, p1, '^-', 'LineWidth', 1.4);

    yline(0, '--');
    xlabel('Noise level (ms)');
    ylabel('Lag correlation');
    title(conditions{c,1});
    grid on;
    ylim([-0.25, 0.45]);

    legend({'lag -1', 'lag 0', 'lag +1'}, 'Location', 'best');

    % Add compact summary at the highest noise level
    txt = sprintf('At %d ms:\nlag -1 = %.3f\nlag 0 = %.3f\nlag +1 = %.3f', ...
        noiseLevels(end), m1(end), m0(end), p1(end));

    text(noiseLevels(end)-24, -0.20, txt, ...
    'FontSize', 9, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'black');
end

sgtitle('Noise sensitivity of lag-correlation patterns');
saveas(gcf, fullfile(figDir, 'figure_variation_noise_sweep.png'));

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