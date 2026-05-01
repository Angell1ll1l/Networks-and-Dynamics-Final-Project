%% reproduce_all.m
% Run all replication and variation scripts.

clear; clc;

repoRoot = fileparts(fileparts(mfilename('fullpath')));

run_isolated(fullfile(repoRoot, 'scripts', 'reproduce_core_results.m'));
run_isolated(fullfile(repoRoot, 'scripts', 'reproduce_variation_results.m'));

disp('All scripts completed.');

function run_isolated(scriptPath)
% Run each dispatcher in function scope so downstream "clear" calls do not
% erase variables in this script.
run(scriptPath);
end
