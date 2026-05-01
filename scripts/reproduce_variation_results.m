%% reproduce_variation_results.m
% Entry point for robustness/variation study figures.

clear; clc;

repoRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repoRoot, 'paper_source_code', 'FourOscModel'));
addpath(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness'));

disp('Running variation study scripts...');

run_isolated(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_variation_noise_sweep.m'));
run_isolated(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_variation_initial_condition_sensitivity.m'));
run_isolated(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_variation_coupling_perturbation.m'));
run_isolated(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_variation_numerical_sensitivity.m'));

disp('Variation study finished. Check the figures/ directory.');

function run_isolated(scriptPath)
% Run each target script in function scope so internal "clear" does not
% erase variables in this dispatcher script.
run(scriptPath);
end
