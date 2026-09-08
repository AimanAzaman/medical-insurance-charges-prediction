# Medical Insurance Charges Prediction — R

## Overview

This project analyzes medical insurance charges and develops regression models to predict individual insurance costs using demographic and health-related characteristics.

The project was built in **R** with a focus on practical insurance analytics:

- Exploratory data analysis
- Data quality checks
- Statistical relationships
- Multiple linear regression
- Interaction effects
- Cross-validation
- Hold-out test evaluation
- Model diagnostics
- New-customer prediction

## Dataset

The project uses the **Medical Cost Personal Dataset**, containing 1,338 observations and 7 variables:

| Variable | Description |
|---|---|
| `age` | Age of the policyholder |
| `sex` | Sex |
| `bmi` | Body Mass Index |
| `children` | Number of dependents/children covered |
| `smoker` | Smoking status |
| `region` | Residential region |
| `charges` | Individual medical insurance charges |

Dataset source:  
https://www.kaggle.com/datasets/mirichoi0218/insurance

The original analysis found no missing values. It also showed a large difference in average charges between non-smokers and smokers, with average charges of approximately 8,434 and 32,050 respectively.

## Business Question

> Can demographic, lifestyle and health-related characteristics be used to predict individual medical insurance charges?

This is relevant to insurance analytics because understanding the relationship between policyholder characteristics and expected costs can support pricing, risk segmentation and portfolio analysis.

## Methodology

### 1. Data preparation

- Loaded the insurance dataset.
- Removed accidental leading/trailing whitespace.
- Converted categorical variables to factors.
- Checked data structure, summary statistics and missing values.

### 2. Exploratory Data Analysis

The analysis investigates:

- Smoking status and insurance charges
- Age and insurance charges
- BMI and insurance charges
- Number of children and charges
- Regional differences
- Correlations among numerical variables

A key finding from the exploratory analysis is that smoking status is strongly associated with higher insurance charges.

### 3. Regression modelling

Four candidate multiple linear regression specifications are compared:

**Model 1 — Main effects**
```text
charges ~ age + sex + bmi + children + smoker + region
```

**Model 2 — BMI × smoking interaction**
```text
charges ~ age + sex + bmi + children + smoker * bmi + region
```

**Model 3 — Age × smoking interaction**
```text
charges ~ age * smoker + sex + bmi + children + region
```

**Model 4 — Reduced interaction model**
```text
charges ~ age + children + smoker * bmi + region
```

### 4. Model validation

To avoid evaluating models on observations used during training:

1. The data is split into **80% training** and **20% testing** observations.
2. The four candidate models are compared using **5-fold cross-validation on the training data**.
3. The model with the lowest cross-validation RMSE is selected.
4. The selected model is refitted using all training observations.
5. The untouched test set is used once for final evaluation.

This gives a more reliable estimate of how the selected model performs on unseen data than comparing models that were trained on the full dataset.

### 5. Evaluation metrics

The project reports:

- **R²** — proportion of variation in charges explained by the model.
- **RMSE** — average prediction error with greater penalty for large errors.
- **MAE** — average absolute prediction error.

### 6. Diagnostics

The selected regression model is assessed using:

- Residuals vs Fitted
- Normal Q-Q
- Scale-Location
- Residuals vs Leverage

The diagnostics are used to identify non-linearity, non-normal residuals, changing variance and potentially influential observations.

## Project Structure

```text
medical-insurance-charges-prediction/
│
├── README.md
├── insurance_analysis.R
├── medical-insurance-charges-prediction.ipynb
│
└── data/
    └── README.md
```

## How to Run

### Option 1 — Kaggle

Upload `medical-insurance-charges-prediction.ipynb` to Kaggle and attach the Medical Cost Personal Dataset.

### Option 2 — Local R / RStudio

1. Download `insurance.csv` from the dataset source.
2. Place it at:

```text
data/insurance.csv
```

3. Run `insurance_analysis.R`.

### Option 3 — Jupyter with an R kernel

Open:

```text
medical-insurance-charges-prediction.ipynb
```

and run the cells from top to bottom.

## Skills Demonstrated

**R**
- Data cleaning
- `ggplot2`
- Exploratory data analysis
- Correlation analysis
- Multiple linear regression
- Interaction terms
- Cross-validation
- Model evaluation
- Residual diagnostics
- Prediction

**Insurance / actuarial relevance**
- Risk-factor analysis
- Cost prediction
- Risk segmentation
- Interpretation of model drivers
- Quantitative decision support

## Key Takeaways

The exploratory analysis indicates that smoking status has a particularly strong relationship with medical insurance charges. Age and BMI also show meaningful relationships with charges, while the effects of children and region are comparatively smaller.

The modelling stage tests whether adding interaction effects improves predictive performance rather than relying only on individual predictor effects.

The final model is selected using cross-validation on the training data and then evaluated on previously unseen test observations.

## Limitations

This dataset is useful for demonstrating insurance analytics techniques, but it is not a complete pricing dataset for a real insurer.

Important limitations include:

- The dataset contains a relatively small number of risk variables.
- It does not contain policy dates, claim frequency, claim severity, exposure or policy limits.
- The data is observational, so regression relationships should not automatically be interpreted as causal.
- Medical charges are highly variable, particularly for high-cost individuals.

## Future Improvements

Possible extensions include:

- Generalized linear models for insurance pricing
- Log-transformed or other skew-aware models
- Non-linear age/BMI effects
- Regularized regression
- Gradient boosting
- Claim frequency and severity modelling
- A Power BI dashboard
- SQL-based insurance portfolio analysis

## Author

**Muhammad Aiman bin Azaman**

Actuarial Science student  
Focus: Insurance Data Analytics
