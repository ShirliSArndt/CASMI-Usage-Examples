# ------------------------------------------------------------------------------
# Synthetic Dataset with Ground Truth
# ------------------------------------------------------------------------------
# This script generates a synthetic dataset for evaluating the CASMI feature
# selection method. The outcome variable y is designed to be dependent on x1–x5
# and independent of x6–x10. All predictors are categorical (≤5 categories).
# The goal is to validate that CASMI identifies relevant variable combinations.
#
# Version: CASMI 2.0.0 (CRAN)
# ------------------------------------------------------------------------------
library(dplyr)

# -----------------------
# Data Generation
# -----------------------

# Set reproducibility
set.seed(123)

# Define sample size
n <- 1000

# Generate informative variables (x1–x5) with distinct category distributions
x1 <- sample(c("A", "B", "C", "D"), n, TRUE, prob = c(0.1, 0.2, 0.3, 0.4))
x2 <- sample(c("W", "X", "Y", "Z"), n, TRUE, prob = c(0.4, 0.3, 0.2, 0.1))
x3 <- sample(c("L", "M", "N"), n, TRUE, prob = c(0.5, 0.3, 0.2))
x4 <- sample(c("P", "Q"), n, TRUE, prob = c(0.7, 0.3))
x5 <- sample(c("E", "F", "G", "H", "I"), n, TRUE, prob = c(0.2, 0.3, 0.2, 0.2, 0.1))

# Generate noise variables (x6–x10) with balanced distributions
x6 <- sample(c("A", "B", "C", "D"), n, TRUE)
x7 <- sample(c("W", "X", "Y", "Z"), n, TRUE)
x8 <- sample(c("L", "M", "N"), n, TRUE)
x9 <- sample(c("P", "Q"), n, TRUE)
x10 <- sample(c("E", "F", "G", "H", "I"), n, TRUE)

# -----------------------
# Outcome Generation
# -----------------------

# Convert relevant x variables to numeric for internal computation
x1_num <- as.numeric(factor(x1, levels = c("A", "B", "C", "D")))
x2_num <- as.numeric(factor(x2, levels = c("W", "X", "Y", "Z")))
x3_num <- as.numeric(factor(x3, levels = c("L", "M", "N")))
x4_num <- as.numeric(factor(x4, levels = c("P", "Q")))
x5_num <- as.numeric(factor(x5, levels = c("E", "F", "G", "H", "I")))

# Generate y with linear combination of x1–x5 plus Gaussian noise
y_numeric <- 3*x1_num + 2*x2_num + x3_num + 0.5*x4_num - 2*x5_num + rnorm(n, 0, 2)

# Discretize numeric y into 10 categorical classes
y <- cut(y_numeric, breaks = 10, labels = paste0("Category", 1:10))

# Combine all variables into a single dataset
data <- data.frame(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, y)

# -----------------------
# (Optional) Insert Missing Values
# -----------------------
# This step simulates real-world conditions with incomplete data.
# NAs are added to different rows across predictors.

na_indices <- sample(1:n, size = 50, replace = FALSE)
data$x1[na_indices[1:5]] <- NA
data$x2[na_indices[6:10]] <- NA
data$x3[na_indices[11:15]] <- NA
data$x4[na_indices[16:20]] <- NA
data$x5[na_indices[21:25]] <- NA
data$x6[na_indices[26:30]] <- NA
data$x7[na_indices[31:35]] <- NA
data$x8[na_indices[36:40]] <- NA
data$x9[na_indices[41:45]] <- NA
data$x10[na_indices[46:50]] <- NA

# Uncomment the line below to add missing values in y
# data$y[na_indices[1:10]] <- NA

# Preview the generated dataset
head(data)

# -----------------------
# CASMI Feature Selection
# -----------------------

library(CASMI)

# Default: Automatic selection of top variable combinations
CASMI.mineCombination(data)

# Specify number of variables in each combination (e.g., pairs)
CASMI.mineCombination(data, NumOfVar = 2)

# Specify both the size and number of combinations to return
CASMI.mineCombination(data, NumOfVar = 2, NumOfComb = 2)
rob = c(0.7, 0.3))
x5 <- sample(c("E", "F", "G", "H", "I"), size = n, replace = TRUE, prob = c(0.2, 0.3, 0.2, 0.2, 0.1))

# Generate x6 to x10 with random distributions
x6 <- sample(c("A", "B", "C", "D"), size = n, replace = TRUE)
x7 <- sample(c("W", "X", "Y", "Z"), size = n, replace = TRUE)
x8 <- sample(c("L", "M", "N"), size = n, replace = TRUE)
x9 <- sample(c("P", "Q"), size = n, replace = TRUE)
x10 <- sample(c("E", "F", "G", "H", "I"), size = n, replace = TRUE)

# Generate y variable dependent on x1 to x5
# Assign numeric values to categories for calculation
x1_num <- as.numeric(factor(x1, levels = c("A", "B", "C", "D")))
x2_num <- as.numeric(factor(x2, levels = c("W", "X", "Y", "Z")))
x3_num <- as.numeric(factor(x3, levels = c("L", "M", "N")))
x4_num <- as.numeric(factor(x4, levels = c("P", "Q")))
x5_num <- as.numeric(factor(x5, levels = c("E", "F", "G", "H", "I")))

# Calculate y with added noise
y_numeric <- 3 * x1_num + 2 * x2_num + x3_num + 0.5 * x4_num - 2 * x5_num + rnorm(n, mean = 0, sd = 2)

# Discretize y into categories (no more than 10 categories)
y <- cut(y_numeric, breaks = 10, labels = paste0("Category", 1:10))


# Combine into a dataframe
data <- data.frame(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, y)


# ----optional: insert NA------
# GPT prompt: "Write R code to randomly put some NA values in x and y variables. NA in each variable should be in different rows."

# Introduce NA values into x and y variables
na_indices <- sample(1:n, size = 50, replace = FALSE)
data$x1[na_indices[1:5]] <- NA
data$x2[na_indices[6:10]] <- NA
data$x3[na_indices[11:15]] <- NA
data$x4[na_indices[16:20]] <- NA
data$x5[na_indices[21:25]] <- NA
data$x6[na_indices[26:30]] <- NA
data$x7[na_indices[31:35]] <- NA
data$x8[na_indices[36:40]] <- NA
data$x9[na_indices[41:45]] <- NA
data$x10[na_indices[46:50]] <- NA
# data$y[na_indices[1:10]] <- NA # uncomment for testing
# -----end insert NA------

# Display the first few rows of the dataset
head(data)


#--------------use CASMI-------------------

library(CASMI)

## Return the suggested combination with the default settings:
CASMI.mineCombination(data)

## Return combinations when the number of variables to be included
## in each combination is specified (e.g., NumOfVar = 2):
CASMI.mineCombination(data, NumOfVar = 2)

## Return combinations when the number of variables to be included
## in each combination is specified (e.g., NumOfVar = 2),
## while the number of top combinations to return is specified
## (e.g., NumOfComb = 2):
CASMI.mineCombination(data,
                      NumOfVar = 2,
                      NumOfComb = 2)
