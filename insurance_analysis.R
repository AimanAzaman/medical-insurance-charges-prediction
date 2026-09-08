# Medical Insurance Charges Prediction
# Portfolio project in R
#
# Dataset:
# Medical Cost Personal Dataset (Kaggle)
# https://www.kaggle.com/datasets/mirichoi0218/insurance
#
# The script is designed to be reproducible:
# - cleans categorical variables
# - performs EDA
# - creates an 80/20 train-test split
# - compares four regression specifications using 5-fold CV on the training data
# - evaluates the selected model once on the untouched test set
# - produces diagnostics and a new-customer prediction

# -----------------------------
# 1. Setup and data loading
# -----------------------------

library(ggplot2)

kaggle_path <- "../input/datasets/mosapabdelghany/medical-insurance-cost-dataset/insurance.csv"
local_path  <- "data/insurance.csv"

if (file.exists(kaggle_path)) {
  insurance <- read.csv(kaggle_path)
} else if (file.exists(local_path)) {
  insurance <- read.csv(local_path)
} else if (file.exists("insurance.csv")) {
  insurance <- read.csv("insurance.csv")
} else {
  stop("insurance.csv was not found. Download the Kaggle dataset and place it in data/insurance.csv.")
}

# Remove accidental leading/trailing whitespace.
insurance[] <- lapply(
  insurance,
  function(x) if (is.character(x)) trimws(x) else x
)

# Treat categorical variables as factors.
insurance$sex    <- factor(insurance$sex)
insurance$smoker <- factor(insurance$smoker)
insurance$region <- factor(insurance$region)

# -----------------------------
# 2. Data overview and quality
# -----------------------------

str(insurance)
summary(insurance)

missing_values <- colSums(is.na(insurance))
missing_values

cat("Rows:", nrow(insurance), "\n")
cat("Columns:", ncol(insurance), "\n")

# -----------------------------
# 3. Exploratory data analysis
# -----------------------------

aggregate(charges ~ smoker, data = insurance, FUN = mean)

# Smoker distribution
ggplot(insurance, aes(x = smoker)) +
  geom_bar() +
  labs(
    title = "Number of Policyholders by Smoking Status",
    x = "Smoking Status",
    y = "Number of Policyholders"
  ) +
  theme_minimal()

# Charges by smoking status
ggplot(insurance, aes(x = smoker, y = charges)) +
  geom_boxplot() +
  labs(
    title = "Medical Insurance Charges by Smoking Status",
    x = "Smoking Status",
    y = "Medical Insurance Charges"
  ) +
  theme_minimal()

# Age vs charges
ggplot(insurance, aes(x = age, y = charges)) +
  geom_point(alpha = 0.6) +
  labs(
    title = "Age vs Medical Insurance Charges",
    x = "Age",
    y = "Medical Insurance Charges"
  ) +
  theme_minimal()

# BMI vs charges, segmented by smoker status
ggplot(insurance, aes(x = bmi, y = charges, shape = smoker)) +
  geom_point(alpha = 0.6) +
  labs(
    title = "BMI vs Medical Insurance Charges",
    x = "BMI",
    y = "Medical Insurance Charges",
    shape = "Smoker"
  ) +
  theme_minimal()

# Charges by number of children
ggplot(insurance, aes(x = factor(children), y = charges)) +
  geom_boxplot() +
  labs(
    title = "Medical Insurance Charges by Number of Children",
    x = "Number of Children",
    y = "Medical Insurance Charges"
  ) +
  theme_minimal()

# Charges by region
ggplot(insurance, aes(x = region, y = charges)) +
  geom_boxplot() +
  labs(
    title = "Medical Insurance Charges by Region",
    x = "Region",
    y = "Medical Insurance Charges"
  ) +
  theme_minimal()

# Numeric correlations
cor(
  insurance[c("age", "bmi", "children", "charges")]
)

# -----------------------------
# 4. Train-test split
# -----------------------------

set.seed(123)

train_index <- sample(
  seq_len(nrow(insurance)),
  size = floor(0.80 * nrow(insurance))
)

train_data <- insurance[train_index, ]
test_data  <- insurance[-train_index, ]

cat("Training observations:", nrow(train_data), "\n")
cat("Testing observations:", nrow(test_data), "\n")

# -----------------------------
# 5. Candidate regression models
# -----------------------------
#
# Model 1: Main effects
# Model 2: Smoking status × BMI interaction
# Model 3: Age × smoking status interaction
# Model 4: Reduced model with smoking status × BMI interaction
#
# All models are trained only on train_data.

model_formulas <- list(
  Model_1 = charges ~ age + sex + bmi + children + smoker + region,
  Model_2 = charges ~ age + sex + bmi + children + smoker * bmi + region,
  Model_3 = charges ~ age * smoker + sex + bmi + children + region,
  Model_4 = charges ~ age + children + smoker * bmi + region
)

# -----------------------------
# 6. Five-fold cross-validation
# -----------------------------
#
# Model selection is based on CV performance within the training data.
# The test set remains untouched until the final evaluation.

set.seed(123)

k <- 5
fold_id <- sample(
  rep(seq_len(k), length.out = nrow(train_data))
)

cv_evaluate <- function(formula, data, folds) {

  fold_metrics <- lapply(seq_len(max(folds)), function(i) {

    fold_train <- data[folds != i, ]
    fold_valid <- data[folds == i, ]

    fit <- lm(formula, data = fold_train)
    pred <- predict(fit, newdata = fold_valid)
    actual <- fold_valid$charges

    data.frame(
      RMSE = sqrt(mean((actual - pred)^2)),
      MAE = mean(abs(actual - pred))
    )
  })

  fold_metrics <- do.call(rbind, fold_metrics)

  data.frame(
    CV_RMSE = mean(fold_metrics$RMSE),
    CV_MAE = mean(fold_metrics$MAE)
  )
}

cv_results <- do.call(
  rbind,
  lapply(model_formulas, cv_evaluate, data = train_data, folds = fold_id)
)

cv_results$Model <- rownames(cv_results)
rownames(cv_results) <- NULL

cv_results <- cv_results[
  order(cv_results$CV_RMSE),
  c("Model", "CV_RMSE", "CV_MAE")
]

cv_results

# -----------------------------
# 7. Select the best specification
# -----------------------------

best_model_name <- cv_results$Model[1]
best_formula <- model_formulas[[best_model_name]]

cat("Selected model:", best_model_name, "\n")
best_formula

# Refit selected specification on all training observations.
final_model <- lm(best_formula, data = train_data)

summary(final_model)
confint(final_model)

# -----------------------------
# 8. Final evaluation on test set
# -----------------------------

test_predictions <- predict(final_model, newdata = test_data)
actual_charges <- test_data$charges

RMSE <- sqrt(mean((actual_charges - test_predictions)^2))
MAE <- mean(abs(actual_charges - test_predictions))

SS_res <- sum((actual_charges - test_predictions)^2)
SS_tot <- sum((actual_charges - mean(actual_charges))^2)

Test_R2 <- 1 - SS_res / SS_tot

final_results <- data.frame(
  Model = best_model_name,
  Test_R2 = Test_R2,
  RMSE = RMSE,
  MAE = MAE
)

final_results

# -----------------------------
# 9. Actual vs predicted
# -----------------------------

prediction_plot_data <- data.frame(
  Actual = actual_charges,
  Predicted = test_predictions
)

ggplot(prediction_plot_data, aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(
    title = paste("Actual vs Predicted Charges -", best_model_name),
    x = "Actual Charges",
    y = "Predicted Charges"
  ) +
  theme_minimal()

# -----------------------------
# 10. Regression diagnostics
# -----------------------------

par(mfrow = c(2, 2))
plot(final_model)
par(mfrow = c(1, 1))

# -----------------------------
# 11. Example new-customer prediction
# -----------------------------

new_customer <- data.frame(
  age = 30,
  sex = factor("male", levels = levels(insurance$sex)),
  bmi = 25,
  children = 2,
  smoker = factor("no", levels = levels(insurance$smoker)),
  region = factor("southeast", levels = levels(insurance$region))
)

predict(
  final_model,
  newdata = new_customer,
  interval = "prediction"
)

# -----------------------------
# 12. Save model results
# -----------------------------

write.csv(
  cv_results,
  "cv_model_comparison.csv",
  row.names = FALSE
)

write.csv(
  final_results,
  "final_test_results.csv",
  row.names = FALSE
)
