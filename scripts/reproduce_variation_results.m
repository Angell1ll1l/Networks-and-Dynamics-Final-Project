%% reproduce_variation_results.m
% Entry point for robustness/variation study figures.

clear; clc;

repoRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repoRoot, 'paper_source_code', 'FourOscModel'));
addpath(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness'));

disp('Running variation study scripts...');

run(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_variation_noise_sweep.m'));
run(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_variation_initial_condition_sensitivity.m'));
run(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_variation_coupling_perturbation.m'));
run(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_variation_numerical_sensitivity.m'));

disp('Variation study finished. Check the figures/ directory.');
