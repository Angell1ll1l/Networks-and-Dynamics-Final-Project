%% reproduce_core_results.m
% Entry point for baseline replication figures/tables.

clear; clc;

repoRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repoRoot, 'paper_source_code', 'FourOscModel'));
addpath(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness'));

disp('Running core replication scripts...');

run(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_author_style_table1.m'));
run(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_author_style_sync_transition.m'));
run(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_replication_baseline.m'));
run(fullfile(repoRoot, 'paper_source_code', 'VariationStudyRobustness', 'main_replication_sync_transition.m'));

disp('Core replication finished. Check the figures/ directory.');
