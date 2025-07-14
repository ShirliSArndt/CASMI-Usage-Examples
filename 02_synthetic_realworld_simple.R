# -----------------------------------------------------------------------------
# Synthetic Ground Truth Example #1: Enhanced Mixed‐Type Real‐World Simulation
# -----------------------------------------------------------------------------
# This script generates a synthetic dataset comprising:
#  • 5 continuous lab measures with realistic rounding:
#      – glucose_cont       (mg/dL, integer)
#      – chol_cont          (mg/dL, integer)
#      – hdl_cont           (mg/dL, integer)
#      – sodium_mmol        (mmol/L, 1 decimal)
#      – creatinine_mgdl    (mg/dL, 2 decimals)
#  • 1 discrete count: white blood cell count (cells/µL, integer)
#  • 3 categorical factors: sex, smoking status, ZIP code
#  • A 10‐level categorical outcome y_cat (deciles of a continuous risk score)
#    – “Y1” = lowest 10% of risk, …, “Y10” = highest 10% of risk
#  • ~5% missing values injected completely at random per predictor
#  • Continuous/count variables binned into Low/Normal/High before CASMI
#  • Demonstrates CASMI.mineCombination() on mixed‐type, discretized data
#
# Because of privacy constraints on real medical data, we use GPT‐generated synthetic data.
# Version: CASMI 2.0.0 (CRAN)
# -----------------------------------------------------------------------------

# Load required libraries
library(dplyr)
library(CASMI)

# -----------------------
# Data Generation
# -----------------------
set.seed(123)
n <- 500

# Continuous labs (clamped & rounded)
glucose_cont    <- pmin(pmax(rnorm(n, 85, 20),  40), 400)  %>% round(0)  # mg/dL
chol_cont       <- pmin(pmax(rnorm(n,180, 40),  75), 400)  %>% round(0)  # mg/dL
hdl_cont        <- pmin(pmax(rnorm(n, 50, 15),  15), 100)  %>% round(0)  # mg/dL
sodium_mmol     <- pmin(pmax(rnorm(n,140,  3), 125), 155)  %>% round(1)  # mmol/L
creatinine_mgdl <- pmin(pmax(rnorm(n,  1, 0.2),0.5),   3)  %>% round(2)  # mg/dL

# Discrete count
wbc_count <- pmin(pmax(rpois(n, 7000), 500), 50000)  # cells/µL

# Categorical factors
sex      <- factor(sample(c("Female","Male"),      n, TRUE))
smoker   <- factor(sample(c("No","Yes"),           n, TRUE, prob = c(0.7, 0.3)))
zip_code <- factor(sample(c("10001","60610","94105"), n, TRUE))

# -----------------------
# Outcome Generation
# -----------------------
# Compute a continuous risk score driven by the labs, then discretize into deciles
y_num <-  0.02 * glucose_cont +
  0.015 * chol_cont -
  0.025 * hdl_cont +
  0.10 * sodium_mmol +
  0.50 * creatinine_mgdl +
  rnorm(n, 0, 1)

y_cat <- cut(
  y_num,
  breaks = quantile(y_num, probs = seq(0, 1, length.out = 11)),
  labels = paste0("Y", 1:10),
  include.lowest = TRUE
)
# Y1 = lowest 10% of risk scores, …, Y10 = highest 10%

# -----------------------
# Combine Data
# -----------------------
df <- data.frame(
  glucose_cont, chol_cont, hdl_cont, sodium_mmol, creatinine_mgdl,
  wbc_count,
  sex, smoker, zip_code,
  y_cat,
  stringsAsFactors = FALSE
)

# -----------------------
# Introduce Missing Values
# -----------------------
set.seed(456)
for (col in c("glucose_cont","chol_cont","hdl_cont","sodium_mmol","creatinine_mgdl","wbc_count")) {
  na_idx       <- sample(n, size = round(0.05 * n))
  df[na_idx, col] <- NA
}

# -----------------------
# Preprocessing
# -----------------------
df_processed <- df %>%
  mutate(
    glucose_cat = cut(glucose_cont,
                      breaks = c(-Inf, 70, 99, Inf),
                      labels = c("Low","Normal","High")),
    chol_cat    = cut(chol_cont,
                      breaks = c(-Inf,100,199,Inf),
                      labels = c("Low","Normal","High")),
    hdl_cat     = cut(hdl_cont,
                      breaks = c(-Inf, 40, 60, Inf),
                      labels = c("Low","Normal","High")),
    sodium_cat  = cut(sodium_mmol,
                      breaks = c(-Inf,135,145,Inf),
                      labels = c("Low","Normal","High")),
    creat_cat   = cut(creatinine_mgdl,
                      breaks = c(-Inf,0.8,1.2,Inf),
                      labels = c("Low","Normal","High")),
    wbc_cat     = cut(wbc_count,
                      breaks = c(-Inf,4000,11000,Inf),
                      labels = c("Low","Normal","High"))
  ) %>%
  dplyr::select(
    glucose_cat, chol_cat, hdl_cat, sodium_cat, creat_cat, wbc_cat,
    sex, smoker, zip_code,
    y_cat
  )

# -----------------------
# CASMI Evaluation
# -----------------------
# Auto‐select best combination of predictors
print(CASMI.mineCombination(df_processed))

# Top 3 two‐variable combinations
print(CASMI.mineCombination(df_processed, NumOfVar = 2))

# Top 2 of those two‐variable combinations
print(CASMI.mineCombination(df_processed, NumOfVar = 2, NumOfComb = 2))
