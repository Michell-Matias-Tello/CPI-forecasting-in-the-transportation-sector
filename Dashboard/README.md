## 🚀 How to Run the Dashboard

### Step 1: Install dependencies

```bash
pip install streamlit pandas plotly numpy statsmodels
```

### Step 2: Save the file correctly

Save the code as `dashboard.py` (NOT `# dashboard.py`)

### Step 3: Run the dashboard

```bash
streamlit run dashboard.py
```

Or if you're in VS Code:

```bash
# Open terminal and run:
streamlit run "c:/Users/Michell/Downloads/Insurance/Seguros/Insurance/dashboard.py"
```

### Step 4: Access the dashboard

Open your browser and go to: `http://localhost:8501`

---

## 📁 Required Directory Structure

Create these folders before running:

```
Insurance/
├── dashboard.py
├── data/
│   └── processed/
│       └── ipc_smoothed.csv    # Will be auto-generated if missing
├── outputs/
│   └── tables/
│       └── forecasts.csv        # Will be auto-generated if missing
└── models/                      # Optional
```

---

## ✅ What the Dashboard Shows

- **Time Series**: Historical CPI with moving averages and volatility bands
- **Forecast**: Predictions with 80% and 95% confidence intervals
- **Decomposition**: Trend, seasonal, and residual components
- **Data Table**: Full dataset with filtering and sorting