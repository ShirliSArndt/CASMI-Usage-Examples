# CASMI Usage Examples

This repository provides usage examples for the CASMI feature selection method, using synthetically generated datasets designed to support interpretability, transparency, and reproducibility.

## Overview

The examples focus on demonstrating how CASMI identifies informative variable combinations in different settings. Each example includes data generation, preprocessing, CASMI execution, and interpretation of results.

## Examples

### 1. Synthetic Dataset with Known Structure

- A fully controlled dataset where the outcome is explicitly dependent on a subset of categorical predictors.
- Designed to validate CASMI’s capacity to recover known associations.
- Outputs are interpreted to illustrate how CASMI quantifies multivariate relevance.

**Script**: `01_synthetic_ground_truth.R`

### 2. Simulated Clinical Nutrition Scenario

- A synthetic dataset simulating real-world characteristics from nutritional epidemiology.
- Includes continuous variables (e.g., nutrient levels) and categorical variables (e.g., discretized clinical indicators).
- Illustrates how CASMI handles mixed data types and detects meaningful interactions.
- Results are illustrative and should not be interpreted as clinical evidence.

**Script**: `02_simulated_clinical_nutrition.R`

## Requirements

```r
install.packages("dplyr")
install.packages("CASMI")
