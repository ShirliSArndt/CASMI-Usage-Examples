# -----------------------------------------------------------------------------
# Synthetic Ground Truth Example #2: Enhanced Mixed‐Type Real‐World Simulation
# -----------------------------------------------------------------------------
# This script generates a synthetic dataset comprising:
#  • 5 continuous lab measures with realistic rounding:
#      – glucose       (mg/dL, integer)
#      – cholesterol   (mg/dL, integer)
#      – hdl           (mg/dL, integer)
#      – sodium        (mmol/L, 1 decimal)
#      – creatinine    (mg/dL, 2 decimals)
#  • 3 categorical factors: sex, smoking status, region code
#  • A 10‐level categorical outcome y_cat (deciles of a continuous risk score)
#    – “Y1” = lowest 10% of risk, …, “Y10” = highest 10% of risk
#  • ~5% missing values injected completely at random per predictor
#  • Continuous/count variables binned into Low/Normal/High before CASMI
#  • Demonstrates CASMI.mineCombination() on mixed‐type, discretized data
#
# Because of privacy constraints on real medical data, we use GPT‐generated synthetic data.
# -----------------------------------------------------------------------------

# -----------------------
# Load Required Libraries
# -----------------------
library(dplyr)
library(CASMI)

# -----------------------
# Set Parameters
# -----------------------
set.seed(123)
n <- 1000  # number of samples

# -----------------------
# Generate Predictors
# -----------------------

# Continuous predictors (clamped to plausible ranges)
glucose     <- pmin(pmax(rnorm(n, mean = 90,  sd = 20),  50), 250)   %>% round(0)
cholesterol <- pmin(pmax(rnorm(n, mean = 190, sd = 35), 100), 300)   %>% round(0)
hdl         <- pmin(pmax(rnorm(n, mean = 55,  sd = 12),  20), 100)   %>% round(0)
sodium      <- pmin(pmax(rnorm(n, mean = 140, sd = 3),  125), 155)   %>% round(1)
creatinine  <- pmin(pmax(rnorm(n, mean = 1.0, sd = 0.25), 0.4), 2.5) %>% round(2)

# Categorical predictors
sex         <- sample(c("Female", "Male"), n, replace = TRUE)
smoker      <- sample(c("No", "Yes"), n, replace = TRUE, prob = c(0.7, 0.3))
region_code <- sample(c("10001", "60610", "94105"), n, replace = TRUE)

# -----------------------
# Missing Values (~5%)
# -----------------------
set.seed(456)

for (var in c("glucose", "cholesterol", "hdl", "sodium", "creatinine")) {
  idx <- sample(1:n, size = round(0.05 * n), replace = FALSE)
  assign(var, {
    x <- get(var)
    x[idx] <- NA
    x
  })
}

# -----------------------
# Generate Outcome Variable
# -----------------------

# Linear risk score from lab values with some noise
y_score <- 0.20 * glucose +
  0.15 * cholesterol -
  0.025 * hdl +
  0.50 * sodium +
  1.50 * creatinine +
  rnorm(n, mean = 0, sd = 2)

# Discretize into deciles
y_cat <- cut(
  y_score,
  breaks = quantile(y_score, probs = seq(0, 1, 0.1), na.rm = TRUE),
  labels = paste0("Y", 1:10),
  include.lowest = TRUE
)

# -----------------------
# Combine into Data Frame
# -----------------------
df <- data.frame(
  glucose, cholesterol, hdl, sodium, creatinine,
  sex, smoker, region_code, y_cat,
  stringsAsFactors = FALSE
)

# Optional: preview
head(df, 10)

# -----------------------
# Preprocessing: Auto-Bin Predictors
# -----------------------

df_processed <- df %>%
  mutate(
    glucose_cat    = autoBin.binary(data.frame(glucose, y_cat), index = 1)[, 1],
    chol_cat       = autoBin.binary(data.frame(cholesterol, y_cat), index = 1)[, 1],
    hdl_cat        = autoBin.binary(data.frame(hdl, y_cat), index = 1)[, 1],
    sodium_cat     = autoBin.binary(data.frame(sodium, y_cat), index = 1)[, 1],
    creatinine_cat = autoBin.binary(data.frame(creatinine, y_cat), index = 1)[, 1]
  ) %>%
  select(glucose_cat, chol_cat, hdl_cat, sodium_cat, creatinine_cat, y_cat)

# -----------------------
# Filter: Ensure y_cat has no NA
# -----------------------
df_processed <- df_processed %>% filter(!is.na(y_cat))

# Optional: preview
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

# Return only the top 2 combinations of 3 variables
CASMI.mineCombination(df_processed, NumOfVar = 3, NumOfComb = 2)

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
