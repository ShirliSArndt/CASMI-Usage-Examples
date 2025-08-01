# CASMI Usage Examples

This repository provides usage examples for the `CASMI.mineCombination()` function, which identifies combinations of variables most strongly associated with a given outcome. The included examples use synthetic and simulated datasets designed to support interpretability, transparency, and reproducibility.

## Overview

`CASMI.mineCombination()` is part of the CASMI R package and is designed to discover combinations of predictors (factors, features, or independent variables) that show strong multivariate association with a categorical outcome. This is especially useful for exploratory analysis when associations may not be evident through individual variables alone.

Each example includes data generation, preprocessing (including discretization of continuous variables), CASMI evaluation, and interpretation-ready code.

The latest version of the CASMI package is available on CRAN — just search for `"CASMI"`  
https://CRAN.R-project.org/package=CASMI

## Examples

### 1. Synthetic Dataset with Known Structure

- Simulates 10 categorical predictors (`x1`–`x10`), where only `x1`–`x5` truly drive the outcome and `x6`–`x10` are pure noise  
- Generates a 10‐level categorical outcome (`y`) as a weighted sum of `x1`–`x5` plus random noise, then discretized into equal‐frequency bins  
- Introduces a small amount of missingness in predictors to mimic real‐world data imperfections  
- Validates that `CASMI.mineCombination()` can recover the true informative subset (`x1`–`x5`) and ignore the noise variables  
- Illustrates how to interpret kappa* and SMIz for known ground-truth associations  

**Script**: [`01_synthetic_ground_truth.R`](./01_synthetic_ground_truth.R)

### 2. Real-World Simulation: Simple Mixed-Type Demo

- Simulates a compact clinical-style cohort with:  
  - **5 continuous measurements** (glucose, total cholesterol, HDL, sodium, creatinine) rounded to realistic precision  
  - **3 categorical factors** (sex, smoking status, ZIP code)  
- Generates a **10-level decile outcome** (`Y1` = lowest 10% risk … `Y10` = highest 10% risk) **before** introducing missingness  
- Introduces **~5% missing values completely at random** into each predictor  
- **Bins** continuous & count measures into Low/Normal/High categories using clinical cut-points  
- Demonstrates running `CASMI.mineCombination()` on a fully **discretized, mixed-type** dataset  

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

