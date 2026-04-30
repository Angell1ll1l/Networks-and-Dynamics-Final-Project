# Reproduction Scripts and Labels

This document maps each script to the result it reproduces.

## Entry-point scripts (run from this folder)

- `reproduce_core_results.m`
  - Runs baseline replication scripts:
    - `main_author_style_table1.m` -> Table-1-style lag-correlation patterns (`figures/figure_table1_author_style.png`)
    - `main_author_style_sync_transition.m` -> synchronization transition curve (`figures/figure_sync_transition_author_style.png`)
    - `main_replication_baseline.m` -> baseline lag-correlation replication (`figures/figure_replication_baseline.png`)
    - `main_replication_sync_transition.m` -> baseline transition replication (`figures/figure_replication_sync_transition.png`)

- `reproduce_variation_results.m`
  - Runs robustness scripts:
    - `main_variation_noise_sweep.m` -> noise sensitivity (`figures/figure_variation_noise_sweep.png`)
    - `main_variation_initial_condition_sensitivity.m` -> seed/initial-condition sensitivity (`figures/figure_variation_initial_condition_sensitivity.png`)
    - `main_variation_coupling_perturbation.m` -> coupling perturbation diagnostics and lag examples (`figures/figure_variation_coupling_perturbation_scores.png`, `figures/figure_variation_coupling_perturbation_lags.png`)
    - `main_variation_numerical_sensitivity.m` -> numerical sensitivity (dt and T) (`figures/figure_variation_step_sensitivity.png`, `figures/figure_variation_time_sensitivity.png`)

- `reproduce_all.m`
  - Runs both suites above in sequence.

## Notes

- The scripts use only simulated data from the model.
- All exported figures are written to `figures/` automatically by the corresponding `main_*.m` files.
