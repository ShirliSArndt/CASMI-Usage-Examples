# ---------------------------------------------------------------------------
# Synthetic Ground Truth Example #1
# ---------------------------------------------------------------------------
# This script generates a synthetic dataset comprising 10 categorical predictor 
# variables (x1 to x10) and a categorical outcome variable (y). The outcome is 
# functionally dependent on predictors x1 through x5 and independent of x6 
# through x10. The distribution of each informative predictor is intentionally 
# distinct, and random noise is included in the outcome.
#
# Each predictor contains no more than five categories. The outcome variable 
# is discretized into 10 levels. This dataset is designed specifically to 
# evaluate the behavior of the CASMI.mineCombination() function under a 
# known ground-truth structure.
# -----------------------------------------------------------------------------

# Load required libraries
library(dplyr)
library(CASMI)

# -----------------------
# Data Generation
# -----------------------

# Set reproducibility seed
set.seed(123)

# Define sample size
n <- 1000

# Generate informative predictors x1–x5 with varying distributions
x1 <- sample(c("A", "B", "C", "D"), size = n, replace = TRUE, prob = c(0.1, 0.2, 0.3, 0.4))
x2 <- sample(c("W", "X", "Y", "Z"), size = n, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1))
x3 <- sample(c("L", "M", "N"), size = n, replace = TRUE, prob = c(0.5, 0.3, 0.2))
x4 <- sample(c("P", "Q"), size = n, replace = TRUE, prob = c(0.7, 0.3))
x5 <- sample(c("E", "F", "G", "H", "I"), size = n, replace = TRUE, prob = c(0.2, 0.3, 0.2, 0.2, 0.1))

# Generate uninformative predictors x6 to x10 with different (but unrelated) distributions
x6 <- sample(c("A", "B", "C", "D"), size = n, replace =  TRUE, prob = c(0.05, 0.25, 0.25, 0.45))
x7 <- sample(c("W", "X", "Y", "Z"), size = n, replace = TRUE, prob = c(0.1, 0.1, 0.3, 0.5))
x8 <- sample(c("L", "M", "N"), size = n, replace =TRUE, prob = c(0.7, 0.2, 0.1))
x9 <- sample(c("P", "Q"), size = n, replace = TRUE, prob = c(0.4, 0.6))
x10 <- sample(c("E", "F", "G", "H", "I"), size = n, replace = TRUE, prob = c(0.3, 0.1, 0.15, 0.25, 0.2))

# -----------------------
# Outcome Generation
# -----------------------

# Convert categorical variables x1–x5 into numeric scores for use in outcome formula
x1_num <- as.numeric(factor(x1, levels = c("A", "B", "C", "D")))
x2_num <- as.numeric(factor(x2, levels = c("W", "X", "Y", "Z")))
x3_num <- as.numeric(factor(x3, levels = c("L", "M", "N")))
x4_num <- as.numeric(factor(x4, levels = c("P", "Q")))
x5_num <- as.numeric(factor(x5, levels = c("E", "F", "G", "H", "I")))

# Construct a numeric response variable as a weighted sum of x1–x5 with added noise
# The weights define the strength of association for each informative variable

y_numeric <- 3 * x1_num + 2 * x2_num + x3_num + 2 * x4_num - 2 * x5_num + rnorm(n, mean = 0, sd = 2)

# Discretize numeric y into 10 approximately equal-frequency categorical bins
y <- cut(y_numeric, breaks = 10, labels = paste0("Category", 1:10))

# -----------------------
# Combine Data
# -----------------------

# Create the final data frame containing all variables
data <- data.frame(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, y)

# -----------------------
# Optional: Introduce Missing Values
# -----------------------

# Randomly assign ~5% NA values across different rows for each variable to simulate missingness
# This step mimics real-world data quality issues for testing robustness
data$x1[sample(1:n, size = round(0.05 * n), replace = FALSE)]  <- NA
data$x2[sample(1:n, size = round(0.05 * n), replace = FALSE)]  <- NA
data$x3[sample(1:n, size = round(0.05 * n), replace = FALSE)]  <- NA
data$x4[sample(1:n, size = round(0.05 * n), replace = FALSE)]  <- NA
data$x5[sample(1:n, size = round(0.05 * n), replace = FALSE)]  <- NA
data$x6[sample(1:n, size = round(0.05 * n), replace = FALSE)]  <- NA
data$x7[sample(1:n, size = round(0.05 * n), replace = FALSE)]  <- NA
data$x8[sample(1:n, size = round(0.05 * n), replace = FALSE)]  <- NA
data$x9[sample(1:n, size = round(0.05 * n), replace = FALSE)]  <- NA
data$x10[sample(1:n, size = round(0.05 * n), replace = FALSE)] <- NA

# Uncomment the line below to also introduce ~5% missingness in y
# data$y[sample(1:n, size = round(0.05 * n), replace = FALSE)] <- NA

# Display the first few rows for inspection
head(data)

# -----------------------
# CASMI Evaluation
# -----------------------

# Apply CASMI.mineCombination with default settings.
# Returns the single most informative combination of predictors,
# automatically selecting both the number and identity of variables.
CASMI.mineCombination(data)

# Apply CASMI.mineCombination with a fixed number of variables per combination.
# Returns the top 3 combinations (default) that each include exactly 2 predictors.
CASMI.mineCombination(data, NumOfVar = 2)

# Apply CASMI.mineCombination with both number of variables and number of combinations defined.
# Returns only the top 2 combinations that each include exactly 2 predictors.
CASMI.mineCombination(data, NumOfVar = 2,
                            NumOfComb = 2)
