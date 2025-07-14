# CASMI Usage Examples

This repository provides usage examples for the `CASMI.mineCombination()` function, which identifies combinations of variables most strongly associated with a given outcome. The included examples use synthetic and simulated datasets designed to support interpretability, transparency, and reproducibility.

## Overview

`CASMI.mineCombination()` is part of the CASMI R package and is designed to discover combinations of predictors (factors, features, or independent variables) that show strong multivariate association with a categorical outcome. This is especially useful for exploratory analysis when associations may not be evident through individual variables alone.

Each example includes data generation, preprocessing (including discretization of continuous variables), CASMI evaluation, and interpretation-ready code.

The latest version of the CASMI package is available on CRAN — just search for `"CASMI"`  
https://CRAN.R-project.org/package=CASMI

## Examples

### 1. Synthetic Dataset with Known Structure

- A fully controlled dataset where the outcome is explicitly dependent on a subset of categorical predictors.
- Designed to validate CASMI’s capacity to recover known associations.
- Outputs are interpreted to illustrate how CASMI quantifies multivariate relevance.

**Script**: [01_synthetic_ground_truth.R](./01_synthetic_ground_truth.R)

### 2. Real-World Simulation: Simple Mixed-Type Demo

- Simulates a small clinical‐style dataset with:
  - 2 continuous lab measures
  - 1 discrete count variable
  - 3 categorical risk factors
  - A 10-level decile outcome (risk deciles Y1–Y10)
- ~5% missingness injected at random per predictor
- Continuous/count → 3-level clinical bins before CASMI
- Illustrates CASMI’s handling of mixed data types in a compact example

**Script**: [02_synthetic_realworld_simple.R](./02_synthetic_realworld_simple.R)

### 3. Real-World Simulation: Complex Correlated CVD-Risk Cohort

- Simulates a larger, correlated panel of:
  - 10 continuous labs (via Gaussian copula + realistic bounds)
  - 5 independent “noise” labs
  - Demographics (age category, sex, ZIP code)
  - A 3-level 10-year CVD risk outcome
- ~5% missingness injected at random in core labs
- Entropy-based binary binning, constant-level & coverage filtering
- Demonstrates CASMI’s scalability to high-dimensional discrete data

**Script**: [03_synthetic_realworld_complex.R](./03_synthetic_realworld_complex.R)

## Requirements

```r
install.packages("dplyr")
install.packages("CASMI")

