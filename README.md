# Networks-and-Dynamics-Final-Project

This repository contains the code and instructions for reproducing our final project on the four-oscillator synchronization model.

The project includes:
- a preserved copy of the original author code;
- replication scripts for baseline paper-style results;
- variation-study scripts for robustness analysis;
- repository-level instructions for dependencies, data generation, and output organization.

## Repository Structure

```text
README.md
requirements.txt
src/
scripts/
data/
figures/
paper/
paper_source_code/
```

- `paper_source_code/FourOscModel/`: original author implementation (preserved and attributed).
- `paper_source_code/VariationStudyRobustness/`: our replication and robustness scripts.
- `scripts/`: high-level entry-point scripts with clear mapping to figures/tables.
- `data/`: generated data guidance (no private datasets required).
- `figures/`: output figures produced by the scripts.
- `paper/`: paper/report notes and manuscript-related files.

## Reproduction Quick Start

1. Install MATLAB (recommended R2022b or newer).
2. Clone this repository.
3. In MATLAB, open the repository root and run:
   - `scripts/reproduce_core_results.m` for baseline replication;
   - `scripts/reproduce_variation_results.m` for robustness studies;
   - `scripts/reproduce_all.m` to run all scripts.
4. Generated figures will be written to `figures/`.

## Script-to-Result Mapping

The main scripts and their intended outputs are documented in `scripts/README.md`, including:
- Table-1-style lag-correlation replication;
- synchronization transition replication;
- noise, initialization, coupling perturbation, and numerical sensitivity studies.

## Dependency Information

See `requirements.txt` for environment requirements.

## Data Access / Data Generation

See `data/README.md`.

This project uses simulated data generated from the model; no private or restricted dataset is required.

## External Code Attribution and Adaptation

We preserve and reuse the original FourOscModel code from:
- https://github.com/OleAd/FourOscModel

Attribution, license, and adaptation notes are recorded in:
- `paper_source_code/FourOscModel/SOURCE.md`
- `paper_source_code/FourOscModel/LICENSE`
- `paper_source_code/FourOscModel/README.original.md`
