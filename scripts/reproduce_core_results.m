%% reproduce_core_results.m
% Entry point for baseline replication figures/tables.

clear; clc;

repoRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repoRoot, 'paper_source_code', 'FourOscModel'));
addpath(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness'));

disp('Running core replication scripts...');

run_isolated(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_author_style_table1.m'));
run_isolated(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_author_style_sync_transition.m'));
run_isolated(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_replication_baseline.m'));
run_isolated(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_replication_sync_transition.m'));

disp('Core replication finished. Check the figures/ directory.');

function run_isolated(scriptPath)
% Run each target script in function scope so internal "clear" does not
% erase variables in this dispatcher script.
run(scriptPath);
end
