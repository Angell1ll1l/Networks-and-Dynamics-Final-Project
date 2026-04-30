%% reproduce_all.m
% Run all replication and variation scripts.

clear; clc;

repoRoot = fileparts(fileparts(mfilename('fullpath')));

run(fullfile(repoRoot, 'scripts', 'reproduce_core_results.m'));
run(fullfile(repoRoot, 'scripts', 'reproduce_variation_results.m'));

disp('All scripts completed.');
