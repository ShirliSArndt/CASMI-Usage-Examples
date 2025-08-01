# -----------------------------------------------------------------------------
# Synthetic Ground Truth Example #2: Enhanced Mixed‐Type Real‐World Simulation
# -----------------------------------------------------------------------------
# This script generates a synthetic dataset comprising:
#  • 5 continuous lab measures with realistic rounding:
#      – glucose_cont       (mg/dL, integer)
#      – chol_cont          (mg/dL, integer)
#      – hdl_cont           (mg/dL, integer)
#      – sodium_mmol        (mmol/L, 1 decimal)
#      – creatinine_mgdl    (mg/dL, 2 decimals)
#  • 3 categorical factors: sex, smoking status, ZIP code
#  • A 10‐level categorical outcome y_cat (deciles of a continuous risk score)
#    – “Y1” = lowest 10% of risk, …, “Y10” = highest 10% of risk
#  • ~5% missing values introduced completely at random per predictor
#  • Continuous/count variables binned into Low/Normal/High before CASMI
#  • Demonstrates CASMI.mineCombination() on mixed‐type, discretized data
#
# Because of privacy constraints on real medical data, we use GPT‐generated synthetic data.
# Version: CASMI 2.0.0 (CRAN)
# -----------------------------------------------------------------------------

# -----------------------
# Load Required Libraries
# -----------------------
library(dplyr)
library(CASMI)

# -----------------------
# Set Parameters
# -----------------------
set.seed(123)        # Reproducibility for data generation
n <- 1000             # Number of samples

# -----------------------
# Generate Predictors
# -----------------------

# Continuous lab predictors (clamped to realistic clinical ranges)
glucose_cont    <- pmin(pmax(rnorm(n = n, mean = 90,  sd = 20),  50), 250)   %>% round(0)
chol_cont       <- pmin(pmax(rnorm(n = n, mean = 190, sd = 35), 100), 300)   %>% round(0)
hdl_cont        <- pmin(pmax(rnorm(n = n, mean = 55,  sd = 12),  20), 100)   %>% round(0)
sodium_mmol     <- pmin(pmax(rnorm(n = n, mean = 140, sd = 3),  125), 155)   %>% round(1)
creatinine_mgdl <- pmin(pmax(rnorm(n = n, mean = 1.0, sd = 0.25), 0.4), 2.5) %>% round(2)

# Count-based lab (white blood cell count)
# wbc_count <- pmin(pmax(rpois(n = n, lambda = 7000), 2000), 25000)

# Categorical demographic/location features
sex      <- sample(c("Female", "Male"), size = n, replace = TRUE)
smoker   <- sample(c("No", "Yes"),     size = n, replace = TRUE, prob = c(0.7, 0.3))
zip_code <- sample(c("10001", "60610", "94105"), size = n, replace = TRUE)

# -----------------------
# Missing Values
# -----------------------
set.seed(456)  # Reproducibility for NA placement

# Apply ~5% missing values per numeric predictor
for (var in c("glucose_cont", "chol_cont", "hdl_cont", "sodium_mmol", "creatinine_mgdl")) {
  missing_indices <- sample(1:n, size = round(0.05 * n), replace = FALSE)
  assign(var, {
    temp <- get(var)
    temp[missing_indices] <- NA
    temp
  })
}

# -----------------------
# Generate Outcome Variable
# -----------------------

# Create a numeric risk score based on lab values
y_numeric <- 0.20 * glucose_cont +
            0.15 * chol_cont -
            0.025 * hdl_cont +
            0.50 * sodium_mmol +
            1.50 * creatinine_mgdl +
            rnorm(n = n, mean = 0, sd = 2)  # Add random noise

# Discretize into deciles (Y1 = lowest 10%, Y10 = highest 10%)
y_cat <- cut(y_numeric,
             breaks = quantile(y_numeric, probs = seq(0, 1, length.out = 11), na.rm = TRUE),
             labels = paste0("Y", 1:10),
             include.lowest = TRUE)

# -----------------------
# Combine Raw Data
# -----------------------

# Combine all variables into a single data frame
df <- data.frame(
  glucose_cont, chol_cont, hdl_cont, sodium_mmol, creatinine_mgdl, sex, smoker, zip_code, y_cat,
  stringsAsFactors = FALSE
)

# View the head of raw data (optional)
head(df, 10)

## Double-check NA in the last column

# -----------------------
# Preprocessing: Auto-Bin Predictors
# -----------------------
# Use CASMI::autoBin.binary() to bin numeric/count variables based on relationship to y_cat.
# The index = 1 parameter tells CASMI which column is the predictor to bin.
# Only bin predictors that contribute to y_cat.

df_processed <- df %>%
  mutate(
    glucose_cat = autoBin.binary(data.frame(glucose_cont, y_cat), index = 1)[, 1],
    chol_cat    = autoBin.binary(data.frame(chol_cont,    y_cat), index = 1)[, 1],
    hdl_cat     = autoBin.binary(data.frame(hdl_cont,     y_cat), index = 1)[, 1],
    sodium_cat  = autoBin.binary(data.frame(sodium_mmol,  y_cat), index = 1)[, 1],
    creat_cat   = autoBin.binary(data.frame(creatinine_mgdl, y_cat), index = 1)[, 1]
  ) %>%
  dplyr::select(
    glucose_cat, chol_cat, hdl_cat, sodium_cat, creat_cat, y_cat
  )
# -----------------------
# Filter for Valid Outcome
# -----------------------
# CASMI requires the outcome to be in the last column and contain NO missing values.

df_processed <- df_processed %>% filter(!is.na(y_cat))

# -----------------------
# View Processed Data (optional)
# -----------------------
head(df_processed, 10)

# -----------------------
# CASMI Evaluation
# -----------------------

# Apply CASMI.mineCombination with default settings.
# Returns the single most informative combination of predictors,
# automatically selecting both the number and identity of variables.
CASMI.mineCombination(df_processed)

# Apply CASMI.mineCombination with a fixed number of variables per combination.
# Returns the top 3 combinations (default) that each include exactly 2 predictors.
CASMI.mineCombination(df_processed, NumOfVar = 3)

# Apply CASMI.mineCombination with both number of variables and number of combinations defined.
# Returns only the top 2 combinations that each include exactly 2 predictors.
CASMI.mineCombination(df_processed, NumOfVar = 3,
                      NumOfComb = 2)

# ----------------------------------------------------
# Descriptive Summary for All Variables (Example #2)
# ----------------------------------------------------
# Used for exploratory dataset overview
# Not all results are shown in the final paper; key stats may be extracted

# Separate continuous and categorical variables
cont_vars <- df %>% dplyr::select(where(is.numeric))
cat_vars  <- df %>% dplyr::select(where(~is.character(.) || is.factor(.)))

# Summary stats for continuous
summary(cont_vars)

# Frequency tables for categorical
lapply(cat_vars, table, useNA = "ifany")
