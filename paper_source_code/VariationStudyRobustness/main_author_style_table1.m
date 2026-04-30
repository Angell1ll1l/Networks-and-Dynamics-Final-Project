%% main_author_style_table1.m
% Author-code-style replication using OleAd/FourOscModel functions:
% Kuramoto_calculations.m and interpolateZeroCrossing.m

clear; clc; close all;
rng(1);
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
figDir = fullfile(projectRoot, 'figures');
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

%% Settings copied from author's FourOscModel.m style
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
numSims = 1000;

%% Coupling parameters
% Important:
% The author example enters Table-1-scale values divided by 10,
% because Kuramoto_calculations.m internally multiplies C by 10.
conditions = {
    'Leading-leading',       [0.65, 0.15, 0.78, 0.13];
    'Leading-following',     [0.17, 0.55, 0.41, 0.55];
    'Mutual adaptation',     [0.25, 0.63, 0.23, 0.51]
};

allMeanLags = zeros(size(conditions,1), 3);
allSEMs = zeros(size(conditions,1), 3);

for c = 1:size(conditions,1)

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

    collLags = zeros(numSims, 3);

    for n = 1:numSims
        Phases = Kuramoto_calculations(C, D, frequency_mean, f_std, f_dist, ...
            t_max, dt, sampling, currNoise);

        [P1ITI, P2ITI] = interpolateZeroCrossing(Phases, dt, sampling, discard);

        % Replace author dependency crosscorr.m with our local lag function.
        collLags(n,:) = local_lag_corr_author_order(P1ITI, P2ITI);
    end

    allMeanLags(c,:) = mean(collLags, 1, 'omitnan');
    allSEMs(c,:) = std(collLags, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(collLags),1));

    fprintf('\n%s\n', conditionName);
    fprintf('Lag -1 = %.3f, Lag 0 = %.3f, Lag +1 = %.3f\n', ...
        allMeanLags(c,1), allMeanLags(c,2), allMeanLags(c,3));
end

%% Plot with values directly inside figure
lags = [-1, 0, 1];

figure('Color','w', 'Position', [100 100 1200 500]);

for c = 1:size(conditions,1)
    subplot(1,3,c);

    errorbar(lags, allMeanLags(c,:), allSEMs(c,:), 'o-', 'LineWidth', 1.5);
    yline(0, '--');
    xticks(lags);
    xlabel('Lag');
    ylabel('Cross-correlation');
    title(conditions{c,1});
    ylim([-0.6, 0.6]);
    grid on;

    txt = sprintf('lag -1 = %.3f\nlag  0 = %.3f\nlag +1 = %.3f', ...
        allMeanLags(c,1), allMeanLags(c,2), allMeanLags(c,3));

    text(-0.9, -0.45, txt, ...
        'FontSize', 10, ...
        'BackgroundColor', 'white', ...
        'EdgeColor', 'black');
end

sgtitle('Replicated lag-correlation patterns from Table 1 coupling weights');
saveas(gcf, fullfile(figDir, 'figure_table1_author_style.png'));

%% Local function
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

    % Here we return [lag -1, lag 0, lag +1].
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