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
├── main_script.R           # Master execution script
├── README.md               # Project documentation
├── LICENSE                 # MIT License
│
├── data/
│   ├── raw/
│   │   └── IPC_EN_TRANSPORTE.xlsx  # Source data (User must place file here)
│   └── processed/
│       └── ipc_smoothed.csv        # Auto-generated by script
│
├── outputs/
│   ├── tables/             # CSV files: metrics, stats, forecasts
│   ├── figures/            # Diagnostic plots (ACF/PACF, residuals, forecast)
│   └── reports/            # Generated text reports (summary.txt)
│
└── .gitignore              # Excludes large files and temporary outputs
