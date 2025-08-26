# CASMI Usage Examples

This repository provides usage examples for the `CASMI.mineCombination()` function, which identifies combinations of variables most strongly associated with a given outcome. The included examples use synthetic and simulated datasets designed to support interpretability, transparency, and reproducibility.

## Overview

`CASMI.mineCombination()` is part of the CASMI R package and is designed to discover combinations of predictors (factors, features, or independent variables) that show strong multivariate association with a categorical outcome. This is especially useful for exploratory analysis when associations may not be evident through individual variables alone.

Each example includes data generation, preprocessing (including discretization of continuous variables), CASMI evaluation, and interpretation-ready code.

The latest version of the CASMI package is available on CRAN — just search for `"CASMI"`  
https://CRAN.R-project.org/package=CASMI

## Examples

### 1. Synthetic Dataset: Known Informative Predictors

- Simulates **10 categorical predictors**:  
  - **Informative (used in outcome)** → x1, x2, x3, x4, x5  
  - **Non-informative (noise)** → x6, x7, x8, x9, x10  
- Constructs a numeric score as a **weighted sum of x1–x5** with added Gaussian noise.  
- Defines outcome `y` as **10 deciles** of this score (Category1–Category10).  
- Injects **random missing values per predictor**: each column receives an independently sampled number of NAs (1–100), outcome `y` remains fully observed.  
- **CASMI analysis:**  
  - *Default run:* `CASMI.mineCombination(data)` suggests the most informative combination with estimates of κ\* (95% CI), SMIz (95% CI), and p-value.  
  - *Fixed size (NumOfVar = 2):* returns the top-ranked pairs under the same metrics.  
- Provides a **ground-truth example** for demonstrating CASMI on a fully categorical dataset with heterogeneous missingness and structured noise.  

**Script**: [`01_synthetic_ground_truth.R`](./01_synthetic_ground_truth.R)

### 2. Real-World Simulation: Simple Mixed-Type Demo

- Simulates a compact clinical cohort with:  
  - **7 continuous labs**:  
    - *Informative (used in outcome)* → glucose, cholesterol, HDL, sodium, creatinine  
    - *Non-informative (noise)* → triglycerides, potassium  
  - **3 categorical factors**:  
    - *Informative (used in outcome)* → smoking status  
    - *Non-informative (noise)* → sex, region code  
- Constructs a continuous risk score from glucose, cholesterol, HDL, sodium, creatinine, **and smoker** (Yes=1, No=0) with added random noise.  
- Defines **`y_cat` as 10 deciles** of the risk score; missingness in predictors is injected **before** outcome generation so NAs can propagate.  
- Injects **~5% MCAR missing values per variable** (continuous and categorical).  
- **Preprocessing for CASMI:** supervised auto-binning (`autoBin.binary`) applied only to the **informative continuous labs**;  
  `smoker` kept categorical; for a controlled teaching example, `df_processed` includes only the outcome-driver predictors.  
- Demonstrates `CASMI.mineCombination()` on a **discretized, mixed-type** dataset with known ground truth structure.  

**Script**: [`02_synthetic_realworld_simple.R`](./02_synthetic_realworld_simple.R)

---

### 3. Nutrient-Centric Simulation: CASMI Evaluation on Lab-Derived Risk

- Simulates a synthetic clinical dataset with:
  - **27 continuous lab variables** with realistic, physiologic distributions  
    *(e.g., glucose, triglycerides, ferritin, CRP, liver enzymes)*
  - **2 discrete lifestyle measures**  
    *(supplement count, alcohol days/week)*
  - **3 demographic factors**  
    *(sex, age group, diet pattern)*
- Creates a **5-level composite risk outcome** (`Risk1`–`Risk5`) based on lipid, vitamin, and inflammation markers *before* introducing missingness
- Introduces **~5% missing values completely at random** into each numeric predictor
- Applies **supervised binning** using `autoBin.binary()`, converting continuous/count variables into categorical intervals
- Demonstrates `CASMI.mineCombination()` on a **high-dimensional, discretized dataset**

**Script**: [`03_synthetic_realworld_complex.R`](03_synthetic_realworld_complex.R)

## Requirements

```r
install.packages("dplyr")
install.packages("CASMI")

