# ---------------------------------------------------------------------------
# Simulated Clinical Nutrition Example
# ---------------------------------------------------------------------------
# This script simulates a clinical nutrition scenario in which various nutrient 
# intake levels and clinical indicators are used to predict a categorical outcome.
#
# The dataset includes both continuous variables (e.g., nutrient levels) and 
# discretized clinical measures (e.g., blood markers categorized as Low, Normal, High). 
# Some variables are designed to influence the outcome, while others are independent.
#
# The goal is to assess the ability of CASMI.mineCombination() to detect relevant 
# variable combinations in a mixed-type dataset under realistic, privacy-respecting 
# conditions.
#
# -----------------------------------------------------------------------------
# Version: CASMI 2.0.0 (CRAN)
# -----------------------------------------------------------------------------

# Load required libraries
library(dplyr)
library(CASMI)

# -----------------------
# Data Generation
# -----------------------

# Set seed for reproducibility
set.seed(42)
n <- 1000  # number of samples

# Generate continuous nutrient variables
protein   <- rnorm(n, mean = 60, sd = 10)
fiber     <- rnorm(n, mean = 25, sd = 5)
sodium    <- rnorm(n, mean = 3000, sd = 500)
potassium <- rnorm(n, mean = 3500, sd = 600)
calcium   <- rnorm(n, mean = 1000, sd = 200)

# Generate additional nutrients unrelated to outcome
zinc    <- rnorm(n, mean = 10, sd = 2)
iron    <- rnorm(n, mean = 15, sd = 3)
magnesium <- rnorm(n, mean = 400, sd = 50)

# Generate categorical clinical markers
cholesterol <- cut(rnorm(n, mean = 190, sd = 30),
                   breaks = c(-Inf, 200, 240, Inf),
                   labels = c("Desirable", "Borderline", "High"))

hdl <- cut(rnorm(n, mean = 55, sd = 15),
           breaks = c(-Inf, 40, 60, Inf),
           labels = c("Low", "Normal", "High"))

# -----------------------
# Outcome Generation
# -----------------------

# Compute numeric score based on selected relevant variables
score <- 0.02 * protein - 0.03 * sodium + 0.05 * fiber +
  0.1 * (cholesterol == "High") - 0.1 * (hdl == "Low") +
  rnorm(n, mean = 0, sd = 1.5)

# Discretize score into 5 outcome categories
outcome <- cut(score, breaks = 5, labels = paste0("Risk", 1:5))

# -----------------------
# Preprocessing for CASMI
# -----------------------

# Discretize continuous variables to align with CASMI’s categorical input requirements
# (You may tune cut points based on domain knowledge or quantiles)

protein_cat   <- cut(protein, breaks = quantile(protein, probs = seq(0, 1, 0.2)), include.lowest = TRUE)
fiber_cat     <- cut(fiber, breaks = quantile(fiber, probs = seq(0, 1, 0.2)), include.lowest = TRUE)
sodium_cat    <- cut(sodium, breaks = quantile(sodium, probs = seq(0, 1, 0.2)), include.lowest = TRUE)
potassium_cat <- cut(potassium, breaks = quantile(potassium, probs = seq(0, 1, 0.2)), include.lowest = TRUE)
calcium_cat   <- cut(calcium, breaks = quantile(calcium, probs = seq(0, 1, 0.2)), include.lowest = TRUE)

zinc_cat      <- cut(zinc, breaks = quantile(zinc, probs = seq(0, 1, 0.2)), include.lowest = TRUE)
iron_cat      <- cut(iron, breaks = quantile(iron, probs = seq(0, 1, 0.2)), include.lowest = TRUE)
magnesium_cat <- cut(magnesium, breaks = quantile(magnesium, probs = seq(0, 1, 0.2)), include.lowest = TRUE)

# -----------------------
# Combine Data
# -----------------------

data <- data.frame(
  protein_cat, fiber_cat, sodium_cat, potassium_cat, calcium_cat,
  zinc_cat, iron_cat, magnesium_cat,
  cholesterol, hdl,
  outcome
)

# -----------------------
# CASMI Evaluation
# -----------------------

# Apply CASMI.mineCombination with default settings.
# Returns a single combination of predictors that maximizes the CASMI score,
# automatically selecting both the number and identity of variables.
CASMI.mineCombination(data)

# Apply CASMI.mineCombination with a fixed number of variables per combination.
# Returns the top 3 combinations (default) that each include exactly 2 predictors.
CASMI.mineCombination(data, NumOfVar = 2)

# Apply CASMI.mineCombination with both number of variables and number of combinations defined.
# Returns only the top 2 combinations that each include exactly 2 predictors.
CASMI.mineCombination(data, NumOfVar = 2,
                            NumOfComb = 2)
