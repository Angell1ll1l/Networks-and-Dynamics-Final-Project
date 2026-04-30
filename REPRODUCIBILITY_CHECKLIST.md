# Reproducibility Checklist

This checklist maps repository artifacts to the required reproducibility items.

## 1) Public repository

- GitHub repository URL: https://github.com/Angell1ll1l/Networks-and-Dynamics-Final-Project
- The repository should remain public for external reproducibility review.

## 2) README with project summary and reproduction instructions

- File: `README.md`
- Includes project summary, repository structure, quick-start run steps, and output location.

## 3) Dependency information

- File: `requirements.txt`
- States MATLAB version requirement and environment notes.

## 4) Source code and scripts used to generate main results

- Source code:
  - `paper_source_code/FourOscModel/` (author code)
  - `paper_source_code/VariationStudyRobustness/` (project scripts)
- Entry-point scripts:
  - `scripts/reproduce_core_results.m`
  - `scripts/reproduce_variation_results.m`
  - `scripts/reproduce_all.m`

## 5) Clear instructions for data access or generation

- File: `data/README.md`
- Clarifies that results are generated from simulation (no private dataset download required).

## 6) Clear labeling of which scripts reproduce which figures/tables

- File: `scripts/README.md`
- Provides script-to-result mapping and expected output file names in `figures/`.

## 7) Brief note about externally adapted code

- Files:
  - `paper_source_code/FourOscModel/SOURCE.md`
  - `paper_source_code/FourOscModel/LICENSE`
  - `paper_source_code/FourOscModel/README.original.md`
- Project-level adaptation summary:
  - Reused: core author model functions and original algorithmic structure.
  - Fixed/adjusted: reproducibility-oriented path handling and scripted output export flow.
  - Added: replication and robustness scripts, wrapper entry points, and repository-level reproducibility documentation.
