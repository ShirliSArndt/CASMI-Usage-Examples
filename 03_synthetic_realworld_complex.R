# -----------------------------------------------------------------------------
# Synthetic Ground Truth Example #3: Nutrient‐Centric Mixed‐Type Simulation
# -----------------------------------------------------------------------------
# This script generates a synthetic dataset comprising:
#  • 27 continuous nutrient and metabolic lab measures with realistic distributions:
#      – e.g., glucose_mgdl        (Normal), 
#              triglycerides_mgdl  (Log-normal), 
#              ferritin_ngml       (Log-normal), etc.
#      – excludes 2 derived measures (VLDL, total cholesterol)
#  • 2 discrete count variables: supplement_count (Poisson), alcohol_days (Binomial)
#  • 3 categorical factors: sex, age_group, diet_pattern
#  • A 5‐level categorical outcome risk_cat (quintiles of a composite risk score)
#    – “Risk1” = lowest 20% of risk, …, “Risk5” = highest 20% of risk
#  • ~5% missing values introduced completely at random per numeric predictor
#  • Continuous/count variables binned using supervised binning before CASMI
#  • Demonstrates CASMI.mineCombination() on nutrient‐driven, discretized data
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
set.seed(123)
n <- 800  # Number of synthetic patients

# -----------------------
# Generate Nutrient Values with Varied Distributions
# -----------------------

# Glucose (Normal, clamped)
glucose_mgdl <- pmin(pmax(round(rnorm(n, 95, 15)), 60), 200)

# Electrolytes and Minerals (Normal, clamped)
calcium_mgdl    <- pmin(pmax(round(rnorm(n, 9.4, 0.4), 1), 8.0), 11.0)
phosphate_mgdl  <- pmin(pmax(round(rnorm(n, 3.4, 0.5), 1), 2.0), 6.0)
magnesium_mgdl  <- pmin(pmax(round(rnorm(n, 2.0, 0.2), 2), 1.2), 3.5)
potassium_mmol  <- pmin(pmax(round(rnorm(n, 4.1, 0.3), 2), 3.0), 6.0)
sodium_mmol     <- pmin(pmax(round(rnorm(n, 140, 2), 1), 130), 155)
chloride_mmol   <- pmin(pmax(round(rnorm(n, 102, 3), 1), 95), 115)

# Trace Elements (Normal, clamped)
iron_ugdl       <- pmin(pmax(round(rnorm(n, 85, 30)), 20), 200)
folate_ngml     <- pmin(pmax(round(rnorm(n, 12, 3), 1), 3), 24)
zinc_ugdl       <- pmin(pmax(round(rnorm(n, 90, 12)), 40), 150)
copper_ugdl     <- pmin(pmax(round(rnorm(n, 100, 15)), 60), 200)
selenium_ugdl   <- pmin(pmax(round(rnorm(n, 95, 10)), 60), 150)

# Lipids (Normal, clamped)
ldl_mgdl        <- pmin(pmax(round(rnorm(n, 120, 30)), 50), 250)
hdl_mgdl        <- pmin(pmax(round(rnorm(n, 55, 12)), 20), 100)

# Kidney Function (Normal, clamped)
creatinine_mgdl <- pmin(pmax(round(rnorm(n, 1.0, 0.15), 2), 0.5), 2.0)
bun_mgdl        <- pmin(pmax(round(rnorm(n, 14, 3)), 5), 30)

# Iron Storage & Vitamins (Log-normal, clamped)
ferritin_ngml   <- pmin(pmax(round(rlnorm(n, log(100), 0.4)), 5), 800)
vit_d_ngml      <- pmin(pmax(round(rlnorm(n, log(28), 0.2), 1), 5), 80)
vit_b12_pgml    <- pmin(pmax(round(rlnorm(n, log(450), 0.3)), 100), 1000)

# Lipids & Inflammation (Log-normal, clamped)
triglycerides_mgdl <- pmin(pmax(round(rlnorm(n, log(150), 0.5)), 30), 500)
crp_mgdl        <- pmin(pmax(round(rlnorm(n, log(0.8), 0.6), 2), 0.1), 15)

# Amino Acid Metabolism (Log-normal, clamped)
homocysteine_umol <- pmin(pmax(round(rlnorm(n, log(10), 0.4), 1), 5), 50)

# Liver Enzymes (Log-normal, clamped)
alt_iu          <- pmin(pmax(round(rlnorm(n, log(25), 0.6)), 5), 150)
ast_iu          <- pmin(pmax(round(rlnorm(n, log(22), 0.5)), 5), 120)
alp_iu          <- pmin(pmax(round(rlnorm(n, log(65), 0.4)), 20), 200)
ggt_iu          <- pmin(pmax(round(rlnorm(n, log(30), 0.5)), 5), 250)

# Mixture Values
vldl_mgdl          <- round(triglycerides_mgdl / 5)
cholesterol_total_mgdl <- ldl_mgdl + hdl_mgdl + vldl_mgdl
uricacid_mgdl      <- round(rnorm(n, 5.8, 1), 1)

# -----------------------
# Discrete & Categorical Variables
# -----------------------
supplement_count <- rpois(n, lambda = 2)
alcohol_days      <- rbinom(n, size = 7, prob = 0.3)
sex               <- sample(c("Male", "Female"), n, replace = TRUE)
age_group         <- sample(c("18-30", "31-50", "51-70", "71+"), n, replace = TRUE, prob = c(0.25, 0.35, 0.3, 0.1))
diet_pattern      <- sample(c("Omnivore", "Vegetarian", "Vegan", "Keto"), n, replace = TRUE)

# -----------------------
# Introduce ~5% Missing Values Randomly
# -----------------------
num_vars <- c("glucose_mgdl", "calcium_mgdl", "phosphate_mgdl", "magnesium_mgdl", "iron_ugdl",
              "ferritin_ngml", "vit_d_ngml", "vit_b12_pgml", "ldl_mgdl", "hdl_mgdl",
              "triglycerides_mgdl", "crp_mgdl", "homocysteine_umol")

for (var in num_vars) {
  idx <- sample(1:n, round(0.05 * n))
  temp <- get(var)
  temp[idx] <- NA
  assign(var, temp)
}

# -----------------------
# Generate Outcome Variable: Composite Risk Score
# -----------------------
risk_score <- 0.1 * ldl_mgdl +
  0.1 * triglycerides_mgdl -
  0.12 * hdl_mgdl +
  0.07 * uricacid_mgdl +
  0.1 * crp_mgdl -
  0.05 * vit_d_ngml +
  0.03 * alt_iu +
  rnorm(n, 0, 5)

risk_cat <- cut(risk_score,
                breaks = quantile(risk_score, probs = seq(0, 1, 0.2), na.rm = TRUE),
                labels = paste0("Risk", 1:5),
                include.lowest = TRUE)

# -----------------------
# Combine Raw Data
# -----------------------
df <- data.frame(
  glucose_mgdl, calcium_mgdl, phosphate_mgdl, magnesium_mgdl, potassium_mmol,
  sodium_mmol, chloride_mmol, iron_ugdl, ferritin_ngml, vit_d_ngml,
  vit_b12_pgml, folate_ngml, zinc_ugdl, copper_ugdl, selenium_ugdl,
  ldl_mgdl, hdl_mgdl, triglycerides_mgdl, vldl_mgdl, cholesterol_total_mgdl,
  crp_mgdl, homocysteine_umol, uricacid_mgdl, alt_iu, ast_iu, alp_iu,
  ggt_iu, creatinine_mgdl, bun_mgdl, supplement_count, alcohol_days,
  sex, age_group, diet_pattern, risk_cat
)

# -----------------------
# View Data (optional)
# -----------------------
head(df)

# -----------------------
# Preprocessing: Bin Variables with Clinical Context
# -----------------------
df_processed <- df %>%
  mutate(
    glucose_cat = autoBin.binary(data.frame(glucose_mgdl, risk_cat), index = 1)[, 1],
    calcium_cat = autoBin.binary(data.frame(calcium_mgdl, risk_cat), index = 1)[, 1],
    phosphate_cat = autoBin.binary(data.frame(phosphate_mgdl, risk_cat), index = 1)[, 1],
    vitd_cat = autoBin.binary(data.frame(vit_d_ngml, risk_cat), index = 1)[, 1],
    ldl_cat = autoBin.binary(data.frame(ldl_mgdl, risk_cat), index = 1)[, 1],
    hdl_cat = autoBin.binary(data.frame(hdl_mgdl, risk_cat), index = 1)[, 1],
    trig_cat = autoBin.binary(data.frame(triglycerides_mgdl, risk_cat), index = 1)[, 1],
    crp_cat = autoBin.binary(data.frame(crp_mgdl, risk_cat), index = 1)[, 1],
    supp_cat = autoBin.binary(data.frame(supplement_count, risk_cat), index = 1)[, 1]
  ) %>%
  dplyr::select(
    glucose_cat, calcium_cat, phosphate_cat, vitd_cat, ldl_cat, hdl_cat, trig_cat,
    crp_cat, supp_cat, sex, age_group, diet_pattern, risk_cat
  ) %>%
  filter(!is.na(risk_cat))

# -----------------------
# View Processed Data (optional)
# -----------------------
head(df_processed)

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
