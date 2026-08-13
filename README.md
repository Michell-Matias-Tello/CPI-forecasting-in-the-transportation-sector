# Transport CPI Forecasting: Comparative Evaluation of SARIMA vs. Holt-Winters

## Strategic Overview & Core Findings

This repository delivers a high-fidelity, data-driven comparative analysis of two premiere time-series forecasting methodologies—**SARIMA** and **Holt-Winters**—applied to the monthly Consumer Price Index (CPI) for the transportation sector in a major metropolitan area. Spanning historical data from February 2001 to August 2024 (283 observations), the study rigorously evaluated model performance to generate actionable forecasts for the critical September–December 2024 window.

**Key Finding:** The SARIMA(1,0,1)(1,0,1)₁₂ model conclusively outperformed the optimized Holt-Winters additive model across all three major error metrics. The SARIMA model achieved an RMSE of **0.1410**, representing an **18% improvement** over Holt-Winters (0.172), providing a statistically robust foundation for strategic budget planning, price stabilization policies, and economic risk mitigation.

---

## 1. The Business Case & Analytical Mandate

The transportation sector represents a substantial component (≈12.4%) of the consumer price basket. Fluctuations in transport costs have a cascading effect on logistics, household purchasing power, and national inflation rates. Given the sector's high sensitivity to international fuel prices, infrastructure constraints, and seasonal demand shocks, accurate short-term forecasting is essential for:

- **Government Policy:** Proactively designing subsidies or tax adjustments to curb inflation.
- **Corporate Logistics:** Budgeting for fleet operational costs and fuel hedging strategies.
- **Consumer Finance:** Anticipating changes in the cost of living.

This project addresses these needs by determining the most accurate predictive model through a strict, reproducible statistical pipeline.

---

## 2. Data Foundation & Preprocessing Framework

| Attribute | Detail |
| :--- | :--- |
| **Variable** | Monthly Percentage Variation of CPI (Non-Tradable Transport Services) |
| **Geographic Scope** | Metropolitan Area |
| **Time Frame** | February 2001 – August 2024 |
| **Frequency** | Monthly (Seasonality = 12) |
| **Observations** | 283 |
| **Source** | Central Bank Public Statistical Database |

### Preprocessing Steps
1.  **Smoothing:** A central moving average (k=5) was applied to mitigate localized volatility during 2003.
2.  **Stationarity Check:** The Augmented Dickey-Fuller (ADF) test confirmed stationarity (p-value < 0.01), allowing for `d=0` in the ARIMA framework.
3.  **Log Transformation:** A logarithmic transformation was applied (after offsetting negative values) to stabilize variance and normalize residual distribution.
4.  **Decomposition:** Additive decomposition was performed to isolate trend, seasonal, and random components, confirming the use of an additive Holt-Winters model.

---

## 3. Methodological Approach & Model Rigor

### 3.1 SARIMA: High-Order Stochastic Modeling
Five candidate SARIMA models were identified, estimated, and rigorously validated.
- **Identification:** Orders (`p`, `q`) were determined by analyzing ACF and PACF correlograms.
- **Estimation:** Parameters were estimated via Maximum Likelihood.
- **Validation:** Residuals were tested via the Ljung-Box test to ensure they behaved as white noise (no autocorrelation, p > 0.05). Q-Q plots confirmed normality.

### 3.2 Holt-Winters: Trend-Aware Exponential Smoothing
The **Additive** variant was selected due to the seasonality maintaining constant amplitude relative to the trend.
- **Initialization:** Heuristic values for α, β, γ.
- **Optimization:** Parameters were strictly optimized using the **GRG Nonlinear** solver (Microsoft Excel) to minimize MAPE, subject to the constraint `0 ≤ α, β, γ ≤ 1`. The optimized values stabilized at `α=0.3627, β=0.0462, γ=0.2516`.

---

## 4. Quantitative Performance Benchmarks

The performance of the two best-performing models was evaluated against a 12-month hold-out test set. The SARIMA model demonstrated strict superiority in all metrics:

| Metric | SARIMA(1,0,1)(1,0,1)₁₂ | Holt-Winters (Optimized) | Delta | % Improvement |
| :--- | :--- | :--- | :--- | :--- |
| **MAE** | 0.1167 | 0.1260 | -0.0093 | **~7.4%** |
| **MAPE** | 12.64% | 13.91% | -1.27% | **~9.1%** |
| **RMSE** | **0.1410** | 0.1720 | -0.0310 | **~18.0%** |

*While Holt-Winters captured the general seasonal cycle, it failed to handle stochastic, non-seasonal fluctuations. SARIMA's advanced autoregressive (AR) and moving average (MA) components enabled it to model complex dependencies, resulting in narrower prediction intervals and significantly reduced error magnitude.*

---

## 5. Forward-Looking Forecast (Q4 2024)

Using the validated SARIMA model, the following probabilistic forecasts were generated:

| Date | Forecast (%) | 80% Confidence Interval | 95% Confidence Interval |
| :--- | :--- | :--- | :--- |
| **Sep 2024** | 0.0277 | [-0.4607, 0.6381] | [-0.6783, 1.0208] |
| **Oct 2024** | 0.4942 | [-0.1045, 1.2481] | [-0.3698, 1.7234] |
| **Nov 2024** | 0.1221 | [-0.4070, 0.7907] | [-0.6409, 1.2133] |
| **Dec 2024** | **1.8373** | [0.9448, 2.9671] | [0.5509, 3.6820] |

**Observation:** The model predicts a significant inflationary surge in December 2024 (1.84%), consistent with strong historical end-of-year demand patterns and logistics bottlenecks. The widening confidence intervals reflect cumulative uncertainty inherent in long-horizon extrapolation.

---

## 6. Technical Implementation & Operational Deployment

The entire analytical pipeline is automated via a single executable R script.

### Directory Layout
```text
proyecto-ipc-transporte/
├── Main_script.R           # Master execution script
├── README.md               # Project documentation
├── LICENSE                 # MIT License
│
├── Dashboard/
│    ├── dashboard.py
│    └── README.md  
│
├── data/
│   └── processed/
│       └── ipc_smoothed.csv        # Auto-generated by script
│
├── outputs/
│   ├── tables/             # CSV files: metrics, stats, forecasts
│   ├── figures/            # Diagnostic plots (ACF/PACF, residuals, forecast)
│   └── reports/            # Generated text reports (summary.txt)
│
├── IPC EN TRANSPORTE.xlsx                  
├── Informe_Seminario_Capstone_2024.pdf
├── Modelo_Holt_Winter.xlsx
└── .gitignore              # Excludes large files and temporary outputs

```

---

## 7. ANALYTICAL FRAMEWORK

### 7.1. Exploratory Data Analysis Phase

- Comprehensive time series visualisation to identify trends, cycles, and outliers.
- Descriptive statistical computation and monthly distribution analysis.
- Seasonal pattern identification through boxplots and decomposition.
- Autocorrelation structure evaluation using ACF and PACF.
- Stationarity verification via Augmented Dickey-Fuller test.

### 7.2. Data Preparation Phase

- Central smoothing using a 5-point moving average to reduce noise.
- Targeted outlier treatment for anomalous periods (e.g., specific months in 2003).
- Logarithmic transformation to stabilise variance and handle extreme values.
- Train-test split with the last 12 months reserved for validation.

### 7.3. Model Development Phase

SARIMA Candidate Models Evaluated:

| Model Number | Non-Seasonal Order (p,d,q) | Seasonal Order (P,D,Q) |
|--------------|---------------------------|----------------------|
| 1            | (0,1,1)                   | (0,1,1)12            |
| 2            | (1,0,1)                   | (1,0,1)12            |
| 3            | (2,0,0)                   | (0,1,1)12            |
| 4            | (1,0,1)                   | (0,1,1)12            |
| 5            | (0,0,1)                   | (1,1,1)12            |

Holt-Winters Configuration:

- Seasonal type: Additive (based on decomposition analysis)
- Optimised smoothing parameters:
  - Alpha (level)   = 0.3627
  - Beta  (trend)   = 0.0462
  - Gamma (seasonal)= 0.2516
- Optimisation criterion: Minimisation of MAPE via GRG Nonlinear Solver.

### 7.4. Model Validation Phase

- Residual diagnostics (ACF, PACF, Q-Q plots) for each candidate model.
- Ljung-Box test for autocorrelation of residuals.
- Shapiro-Wilk test for normality of residuals.
- Comparative performance evaluation using MAE, RMSE, and MAPE.

### 7.5. Forecasting Phase

- 4-step-ahead forecast horizon (periods 1-4).
- Confidence intervals at 80% and 95% significance levels.
- Inverse transformation to restore original scale for interpretability.

---

## 8. FINDINGS AND INTERPRETATION

### 8.1. Model Selection Rationale

The SARIMA(1,0,1)(1,0,1)12 model was selected as the optimal methodology based on:

1. Statistical Superiority: Lowest MAE, RMSE, and MAPE values among all candidates.
2. Residual Independence: Ljung-Box test p-value > 0.05, confirming no significant autocorrelation.
3. Normality: Shapiro-Wilk test p-value > 0.05, supporting the normality assumption.
4. Parsimony: Optimal balance between model complexity and fit (AIC and BIC criteria).
5. Out-of-Sample Stability: Consistent performance across the validation period.

### 8.2. Forecast Implications

The projected upward trajectory, particularly in the fourth period, suggests:

- Seasonal Amplification: End-of-year demand pressures may drive CPI increases.
- Inflationary Accumulation: Persistent cost pressures in the transportation sector.
- Structural Drivers: Fuel prices, regulatory changes, and supply-chain dynamics.
- Policy Relevance: These forecasts can inform fiscal and monetary policy decisions.

---

## 9. TECHNICAL SPECIFICATIONS

### 9.1. R Package Dependencies

| Package   | Minimum Version | Purpose |
|-----------|-----------------|---------|
| tidyverse | 2.0.0           | Data manipulation, transformation, and visualisation |
| readxl    | 1.4.0           | Excel file import |
| zoo       | 1.8.0           | Time series operations and rolling functions |
| tseries   | 0.10.0          | Stationarity testing |
| forecast  | 8.21.0          | ARIMA and Holt-Winters modelling |
| ggplot2   | 3.4.0           | Advanced data visualisation |
| viridis   | 0.6.0           | Colour palette management |
| lmtest    | 0.9.0           | Diagnostic testing |
| knitr     | 1.45.0          | Table formatting and report generation |
| urca      | 1.3.0           | Unit root testing |
| scales    | 1.3.0           | Axis scaling and label formatting |

### 9.2. Installation Commands
Install core packages
install.packages(c(
"tidyverse", "readxl", "zoo", "tseries",
"forecast", "ggplot2", "viridis", "lmtest",
"knitr", "urca", "scales"
))

#### Optional: Install packages for report generation
install.packages(c("rmarkdown", "tinytex"))
tinytex::install_tinytex()

---

## 10. REPRODUCIBILITY PROTOCOL

This project adheres to the highest standards of reproducible research:

- Single Execution: The complete workflow is encapsulated in main_script.R.
- Automated Generation: All outputs (tables, figures, reports) are generated programmatically without manual steps.
- Version Control: Full history is maintained through Git, enabling auditability.
- Comprehensive Documentation: Extensive code comments and this README provide full transparency.
- Dependency Management: All required packages are explicitly listed with version recommendations.

---

## 11. LICENSING AND TERMS

This project is distributed under the MIT License. See the LICENSE file for complete terms and conditions governing use, modification, and distribution.

---

## 12. LIMITATIONS AND DISCLAIMER

The forecasts and analyses presented are based on statistical modelling of historical data. Results are provided for informational and research purposes only. The following limitations should be carefully considered:

- Forecast accuracy depends on the continuation of historical patterns.
- External shocks (e.g., policy changes, global events) may significantly alter outcomes.
- Confidence intervals provide probabilistic guidance, not deterministic guarantees.
- Users should exercise independent judgment and consult qualified professionals before making decisions based on these findings.

---

## 13. VERSION HISTORY

| Version | Release Date | Description of Changes |
|---------|--------------|------------------------|
| 1.0     | November 2024 | Initial release with complete analysis framework and full documentation |

---

## 14. ACKNOWLEDGMENTS

This research was conducted as part of an academic program. The author expresses sincere gratitude to:

- Academic Supervisors for their guidance and valuable feedback.
- Institutional Support for providing resources and infrastructure.
- Data Providers for making historical economic data available.
- Open-Source Community for developing and maintaining the essential analytical tools used in this project.

---

## 15. SUPPORT AND CONTACT

For questions, issues, or support requests regarding this project:

- Submit an issue through the GitHub repository's issue tracker.
- Review the code comments and documentation for detailed guidance.
- Consult the outputs/ directory for comprehensive result files.

---

Document Version: 1.0
Last Updated: November 2024
Project Status: Complete
