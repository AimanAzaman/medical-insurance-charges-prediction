# Medical Insurance Charges Prediction --- R

## Overview

This project analyzes medical insurance charges and develops regression
models to predict individual insurance costs using demographic and
health-related characteristics.

The project was built in **R** with a focus on practical insurance
analytics:

-   Exploratory data analysis
-   Data quality checks
-   Statistical relationships
-   Multiple linear regression
-   Interaction effects
-   5-fold cross-validation
-   Hold-out test evaluation
-   Model diagnostics
-   New-customer prediction

## Dataset

The project uses the **Medical Cost Personal Dataset**, containing 1,338
observations and 7 variables.

  Variable     Description
  ------------ ---------------------------------------
  `age`        Age of the policyholder
  `sex`        Sex
  `bmi`        Body Mass Index
  `children`   Number of dependents/children covered
  `smoker`     Smoking status
  `region`     Residential region
  `charges`    Individual medical insurance charges

Dataset source:

https://www.kaggle.com/datasets/mirichoi0218/insurance

The dataset contains no missing values.

A key finding from the exploratory analysis was the large difference in
average charges between non-smokers and smokers:

-   Non-smokers: approximately **\$8,434**
-   Smokers: approximately **\$32,050**

## Business Question

> Can demographic, lifestyle and health-related characteristics be used
> to predict individual medical insurance charges?

This is relevant to insurance analytics because understanding the
relationship between policyholder characteristics and expected costs can
support risk segmentation, pricing analysis and quantitative
decision-making.

## Methodology

### 1. Data Preparation

-   Loaded the insurance data.
-   Checked structure, summary statistics and missing values.
-   Removed accidental leading/trailing whitespace.
-   Converted categorical variables to factors.

### 2. Exploratory Data Analysis

The analysis investigates smoking status, age, BMI, number of children,
region and correlations among numerical variables.

### 3. Regression Modelling

Four candidate multiple linear regression specifications were developed.

**Model 1 --- Main Effects**

``` text
charges ~ age + sex + bmi + children + smoker + region
```

**Model 2 --- BMI × Smoking Interaction**

``` text
charges ~ age + sex + bmi + children + smoker * bmi + region
```

**Model 3 --- Age × Smoking Interaction**

``` text
charges ~ age * smoker + sex + bmi + children + region
```

**Model 4 --- Reduced BMI × Smoking Interaction Model**

``` text
charges ~ age + children + smoker * bmi + region
```

### 4. Model Validation

1.  The dataset was divided into **80% training data** and **20% testing
    data**.
2.  The four candidate models were compared using **5-fold
    cross-validation on the training data**.
3.  The model with the lowest cross-validation RMSE was selected.
4.  The selected model was refitted using all training observations.
5.  The untouched test set was used once for final evaluation.

This reduces the risk of data leakage and provides a more reliable
estimate of performance on unseen observations.

## Model Selection

Based on 5-fold cross-validation, **Model 4** achieved the lowest
cross-validation RMSE and MAE.

### Cross-Validation Results

  Model                CV RMSE         CV MAE
  ------------- -------------- --------------
  **Model 4**     **4,944.92**   **2,991.22**
  Model 2             4,946.95       2,998.04
  Model 1             6,199.00       4,298.05
  Model 3             6,204.80       4,305.64

### Final Model

``` text
charges ~ age + children + smoker * bmi + region
```

## Final Test-Set Performance

The selected Model 4 was evaluated on the previously unseen 20% test
set.

  Metric                  Result
  ------------- ----------------
  **Test R²**         **0.8296**
  **RMSE**        **\$4,592.75**
  **MAE**         **\$2,668.39**

The final model explains approximately **82.96% of the variation in
medical insurance charges on unseen test data**.

The **MAE of approximately \$2,668** represents the average absolute
difference between predicted and actual charges in the test set.

## Model Diagnostics

The selected regression model was assessed using:

-   Residuals vs Fitted --- potential non-linearity
-   Normal Q-Q --- residual normality
-   Scale-Location --- constant variance
-   Residuals vs Leverage --- potentially influential observations

The diagnostics indicate that the model does not perfectly capture all
sources of variation in medical insurance charges, particularly for some
higher-cost observations.

## Actual vs Predicted Charges

The project compares actual charges with predicted charges. Observations
closer to the 45-degree reference line represent more accurate
predictions.

## Example New-Customer Prediction

The final model can estimate charges for a hypothetical policyholder:

  Variable         Value
  ---------- -----------
  Age                 30
  Sex               Male
  BMI                 25
  Children             2
  Smoker              No
  Region       Southeast

The model produces both a predicted charge and a prediction interval.

## Key Findings

1.  **Smoking status** has a particularly strong relationship with
    medical insurance charges.
2.  **Age** is positively associated with charges.
3.  **BMI** contributes to prediction, with its relationship differing
    according to smoking status.
4.  **Children and region** have comparatively smaller effects than the
    major risk factors.
5.  The **smoking status × BMI interaction** improved predictive
    performance compared with the simpler main-effects models.

## Skills Demonstrated

### R

-   Data cleaning
-   `ggplot2`
-   Exploratory data analysis
-   Correlation analysis
-   Multiple linear regression
-   Interaction terms
-   5-fold cross-validation
-   Train-test validation
-   Model evaluation
-   Residual diagnostics
-   Prediction

### Insurance / Actuarial Relevance

-   Risk-factor analysis
-   Cost prediction
-   Risk segmentation
-   Interpretation of model drivers
-   Quantitative decision support

## Project Structure

``` text
medical-insurance-charges-prediction/
├── README.md
├── insurance_analysis.R
├── medical-insurance-charges-prediction.ipynb
├── .gitignore
└── data/
    └── README.md
```

## How to Run

### Kaggle

Open the notebook in Kaggle and attach the Medical Cost Personal
Dataset.

### Local R / RStudio

1.  Download `insurance.csv` from the dataset source.
2.  Place it in `data/insurance.csv`.
3.  Run `insurance_analysis.R`.

### Jupyter with an R Kernel

Open `medical-insurance-charges-prediction.ipynb` and run the cells from
top to bottom.

## Limitations

This dataset is useful for demonstrating insurance analytics techniques,
but it is not a complete real-world insurance pricing dataset.

-   The dataset contains a relatively small number of risk variables.
-   It does not contain policy exposure, claim frequency, claim
    severity, policy limits or policy dates.
-   The data is observational, so statistical relationships should not
    automatically be interpreted as causal.
-   Medical charges are highly variable, particularly among high-cost
    individuals.
-   Linear regression may not fully capture the non-linear nature of
    medical costs.

## Future Improvements

-   Generalized linear models for insurance pricing
-   Log-transformed or other skew-aware models
-   Non-linear age and BMI effects
-   Regularized regression
-   Gradient boosting
-   Claim frequency and severity modelling
-   SQL-based insurance portfolio analysis
-   Power BI insurance dashboard

## Author

**Muhammad Aiman bin Azaman**

Actuarial Science Student\
Focus: Insurance Data Analytics
