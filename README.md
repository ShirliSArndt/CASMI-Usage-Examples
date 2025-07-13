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

### 2. Simulated Clinical Nutrition Scenario

- A synthetic dataset simulating real-world characteristics from nutritional epidemiology.
- Includes continuous variables (e.g., nutrient levels) and categorical variables (e.g., discretized clinical indicators).
- Illustrates how CASMI handles mixed data types and detects meaningful interactions.
- Results are illustrative and should not be interpreted as clinical evidence.

**Script**: [02_simulated_clinical_nutrition.R](./02_simulated_clinical_nutrition.R)

## Requirements

```r
install.packages("dplyr")
install.packages("CASMI")
