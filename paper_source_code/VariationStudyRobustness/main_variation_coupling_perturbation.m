%% main_variation_coupling_perturbation.m
% 3C Variation Study 3:
% Coupling-parameter perturbation.
%
% We test whether the reported synchronization strategies are robust under
% systematic changes to within-unit coupling and between-unit coupling.
%
% This script uses the author-code-style pipeline:
% Kuramoto_calculations.m and interpolateZeroCrossing.m

clear; clc; close all;
rng(4);
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
numSims = 500;

%% Perturbation levels
alphas = [0.5, 0.75, 1.0, 1.25, 1.5];

%% Coupling parameters on author input scale
% Table 1 paper-scale values divided by 10.
conditions = {
    'Leading-leading',       [0.65, 0.15, 0.78, 0.13];
    'Leading-following',     [0.17, 0.55, 0.41, 0.55];
    'Mutual adaptation',     [0.25, 0.63, 0.23, 0.51]
};

nCond = size(conditions,1);
nAlpha = length(alphas);

% Dimensions:
% condition x alpha x perturbation type x lag
% perturbation type 1 = scale internal i1,i2
% perturbation type 2 = scale external e1,e2
lagMeans = zeros(nCond, nAlpha, 2, 3);
lagSEMs = zeros(nCond, nAlpha, 2, 3);

scores = zeros(nCond, nAlpha, 2);

%% Run simulations
for c = 1:nCond

    conditionName = conditions{c,1};
    base = conditions{c,2};

    for mode = 1:2
        for ai = 1:nAlpha

            alpha = alphas(ai);

            params = base;

            if mode == 1
                % Scale internal coupling i1 and i2
                params(1) = alpha * base(1);
                params(3) = alpha * base(3);
            else
                % Scale external coupling e1 and e2
                params(2) = alpha * base(2);
                params(4) = alpha * base(4);
            end

            i1 = params(1);
            e1 = params(2);
            i2 = params(3);
            e2 = params(4);

            C = [0  i1 e1 0;
                 i1 0  0  0;
                 0  0  0  i2;
                 0  e2 i2 0];

            collLags = zeros(numSims, 3);

            for s = 1:numSims

                Phases = Kuramoto_calculations(C, D, frequency_mean, f_std, f_dist, ...
                    t_max, dt, sampling, currNoise);

                [P1ITI, P2ITI] = interpolateZeroCrossing(Phases, dt, sampling, discard);

                collLags(s,:) = local_lag_corr_author_order(P1ITI, P2ITI);
            end

            lagMeans(c,ai,mode,:) = mean(collLags, 1, 'omitnan');
            lagSEMs(c,ai,mode,:) = std(collLags, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(collLags),1));

            r = squeeze(lagMeans(c,ai,mode,:))';
            scores(c,ai,mode) = diagnostic_score(c, r);

            if mode == 1
                modeName = 'internal';
            else
                modeName = 'external';
            end

            fprintf('%s, %s scale alpha = %.2f: lag -1 = %.3f, lag 0 = %.3f, lag +1 = %.3f, score = %.3f\n', ...
                conditionName, modeName, alpha, r(1), r(2), r(3), scores(c,ai,mode));
        end
    end
end

%% Plot diagnostic scores: one panel for each strategy

figure('Color','w', 'Position', [100 100 1500 500]);

tiledlayout(1,3, 'Padding', 'compact', 'TileSpacing', 'compact');

for c = 1:nCond

    nexttile;
    hold on;

    internalScore = squeeze(scores(c,:,1));
    externalScore = squeeze(scores(c,:,2));

    plot(alphas, internalScore, 'o-', 'LineWidth', 1.8, 'MarkerSize', 7);
    plot(alphas, externalScore, 's-', 'LineWidth', 1.8, 'MarkerSize', 7);

    xline(1.0, '--', 'LineWidth', 1.1);
    yline(0, '--', 'LineWidth', 1.1);

    xlabel('Scaling factor \alpha');
    ylabel('Diagnostic score');
    title(conditions{c,1});
    grid on;

    legend({'Scale internal i_1,i_2', 'Scale external e_1,e_2'}, ...
        'Location', 'best');

    % Determine y limits with a little margin
    allVals = [internalScore(:); externalScore(:)];
    yMin = min(allVals);
    yMax = max(allVals);
    if abs(yMax - yMin) < 1e-6
        yMin = yMin - 0.05;
        yMax = yMax + 0.05;
    else
        margin = 0.15 * (yMax - yMin);
        yMin = yMin - margin;
        yMax = yMax + margin;
    end
    ylim([yMin, yMax]);

    % Baseline score at alpha = 1
    baseIdx = find(abs(alphas - 1.0) < 1e-9);

    txt = sprintf('At baseline \\alpha=1:\ninternal = %.3f\nexternal = %.3f', ...
        internalScore(baseIdx), externalScore(baseIdx));

    xText = alphas(1) + 0.04;
    yText = yMin + 0.12*(yMax-yMin);

    text(xText, yText, txt, ...
        'FontSize', 9, ...
        'BackgroundColor', 'white', ...
        'EdgeColor', 'black');
end

sgtitle('Coupling-parameter perturbation of synchronization strategies');
saveas(gcf, fullfile(figDir, 'figure_variation_coupling_perturbation_scores.png'));

%% Optional second figure: lag values at alpha = 0.5, 1.0, 1.5
selectedAlphas = [0.5, 1.0, 1.5];
selectedIdx = arrayfun(@(a) find(abs(alphas-a)<1e-9), selectedAlphas);

figure('Color','w', 'Position', [100 100 1300 650]);

plotIdx = 1;
lags = [-1, 0, 1];

for c = 1:nCond
    for mode = 1:2
        subplot(nCond,2,plotIdx);
        hold on;

        for si = 1:length(selectedIdx)
            ai = selectedIdx(si);
            r = squeeze(lagMeans(c,ai,mode,:))';
            plot(lags, r, 'o-', 'LineWidth', 1.4);
        end

        yline(0, '--');
        xticks(lags);
        xlabel('Lag');
        ylabel('Correlation');
        ylim([-0.1, 0.4]);
        grid on;

        if mode == 1
            modeTitle = 'scale internal';
        else
            modeTitle = 'scale external';
        end

        title([conditions{c,1}, ', ', modeTitle]);
        legend({'\alpha=0.5', '\alpha=1.0', '\alpha=1.5'}, 'Location', 'best');

        plotIdx = plotIdx + 1;
    end
end

sgtitle('Lag-pattern examples under coupling perturbation');
saveas(gcf, fullfile(figDir, 'figure_variation_coupling_perturbation_lags.png'));

%% Local functions

function score = diagnostic_score(conditionIndex, r)
    % r = [r_minus, r_zero, r_plus]
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