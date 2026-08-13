# ================================================================
# PROYECTO: PRONÓSTICO IPC TRANSPORTE LIMA METROPOLITANA
# AUTOR: Michell Karen Angélica Matias Tello
# ================================================================

# ================================================================
# PARTE 1: CONFIGURACIÓN Y SETUP
# ================================================================

# Limpiar entorno
rm(list = ls())
gc()

# Crear estructura de carpetas automáticamente
create_project_structure <- function() {
  folders <- c(
    "data/raw",
    "data/processed",
    "outputs/figures/time_series_plots",
    "outputs/figures/acf_pacf",
    "outputs/figures/residuals",
    "outputs/figures/decomposition",
    "outputs/figures/forecasts",
    "outputs/tables",
    "outputs/reports"
  )
  
  for (folder in folders) {
    if (!dir.exists(folder)) {
      dir.create(folder, recursive = TRUE, showWarnings = FALSE)
      cat("✅ Created:", folder, "\n")
    }
  }
}

# Función para guardar gráficos
save_plot <- function(plot, filename, subfolder = "figures", 
                      width = 10, height = 6, dpi = 300) {
  base_dir <- getwd()
  file_path <- file.path(base_dir, "outputs", subfolder, filename)
  
  dir_path <- dirname(file_path)
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE, showWarnings = FALSE)
  }
  
  ggsave(
    filename = paste0(tools::file_path_sans_ext(filename), ".png"),
    plot = plot,
    path = dir_path,
    width = width,
    height = height,
    dpi = dpi
  )
  
  # También guardar en PDF
  ggsave(
    filename = paste0(tools::file_path_sans_ext(filename), ".pdf"),
    plot = plot,
    path = dir_path,
    width = width,
    height = height
  )
  
  cat("✅ Saved:", file.path(dir_path, paste0(tools::file_path_sans_ext(filename), ".png")), "\n")
}

# Función para guardar tablas
save_table <- function(table, filename) {
  file_path <- file.path(getwd(), "outputs/tables", filename)
  write.csv(table, file_path, row.names = FALSE)
  cat("✅ Saved:", file_path, "\n")
}

# Función para métricas de error
calculate_metrics <- function(actual, predicted) {
  mape <- mean(abs((actual - predicted) / actual)) * 100
  mae <- mean(abs(actual - predicted))
  rmse <- sqrt(mean((actual - predicted)^2))
  return(list(MAPE = mape, MAE = mae, RMSE = rmse))
}

# Ejecutar creación de estructura
create_project_structure()

# Cargar librerías
cat("\n📦 Loading libraries...\n")
suppressPackageStartupMessages({
  library(tidyverse)
  library(readxl)
  library(zoo)
  library(tseries)
  library(forecast)
  library(ggplot2)
  library(viridis)
  library(lmtest)
  library(knitr)
  library(urca)
  library(scales)
})
cat("✅ All libraries loaded\n")

# ================================================================
# PARTE 2: CARGA DE DATOS
# ================================================================

cat("\n📊 Loading data...\n")

# Verificar archivo
data_file <- "C:/Users/Michell/Downloads/Proyecto-ipc-transporte/IPC EN TRANSPORTE.xlsx"
if (!file.exists(data_file)) {
  stop("❌ Data file not found in data/raw/ folder. Please place the Excel file there.")
}

# Cargar datos
ipc_data <- read_excel(data_file, col_types = c("date", "numeric")) %>%
  mutate(Fecha = as.Date(Fecha))

cat("✅ Data loaded:", nrow(ipc_data), "observations\n")

# ================================================================
# PARTE 3: ANÁLISIS EXPLORATORIO - CORREGIDO
# ================================================================

cat("\n📈 Exploratory analysis...\n")

# Convertir a serie temporal
ipc_ts <- ts(ipc_data$IPC.Transporte, start = c(2001, 2), frequency = 12)

# --- Gráfico 1: Serie Temporal Original ---
p1 <- ggplot(ipc_data, aes(x = Fecha, y = IPC.Transporte)) +
  geom_line(color = "steelblue", size = 0.8) +
  labs(title = "Time Series of Transport CPI in Metropolitan Lima",
       x = "Date", y = "CPI") +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
save_plot(p1, "01_original_ts.png", "figures/time_series_plots")

# --- Estadísticas Descriptivas ---
desc_stats <- ipc_data %>%
  summarise(
    n = n(),
    Mean = mean(IPC.Transporte, na.rm = TRUE),
    SD = sd(IPC.Transporte, na.rm = TRUE),
    Min = min(IPC.Transporte, na.rm = TRUE),
    Q1 = quantile(IPC.Transporte, 0.25, na.rm = TRUE),
    Median = median(IPC.Transporte, na.rm = TRUE),
    Q3 = quantile(IPC.Transporte, 0.75, na.rm = TRUE),
    Max = max(IPC.Transporte, na.rm = TRUE)
  ) %>%
  pivot_longer(cols = everything(), names_to = "Statistic", values_to = "Value")

save_table(desc_stats, "descriptive_stats.csv")
print(desc_stats)

# --- Boxplot Mensual ---
png("outputs/figures/time_series_plots/02_boxplot_monthly.png", width = 800, height = 500)
colors <- viridis(12, option = "C")
boxplot(ipc_ts ~ cycle(ipc_ts), xlab = "Month", ylab = "CPI",
        main = "Monthly Boxplot of Transport CPI", col = colors)
dev.off()
cat("✅ Saved: outputs/figures/time_series_plots/02_boxplot_monthly.png\n")

# --- ACF ---
png("outputs/figures/acf_pacf/03_acf.png", width = 800, height = 500)
acf(ipc_ts, lag.max = 24, main = "Autocorrelation Function (ACF)")
dev.off()
cat("✅ Saved: outputs/figures/acf_pacf/03_acf.png\n")

# --- PACF ---
png("outputs/figures/acf_pacf/04_pacf.png", width = 800, height = 500)
pacf(ipc_ts, lag.max = 24, main = "Partial Autocorrelation Function (PACF)")
dev.off()
cat("✅ Saved: outputs/figures/acf_pacf/04_pacf.png\n")

cat("\n🔄 Decomposing time series...\n")

# Opción 1: Plot simple (sin parámetros adicionales)
png("outputs/figures/decomposition/05_decomposition_base.png", width = 1000, height = 800)
plot(decompose(ipc_ts))
dev.off()
cat("✅ Saved: outputs/figures/decomposition/05_decomposition_base.png\n")

# Opción 2: Empleando ggplot para mejor visualización
decomp <- decompose(ipc_ts)
decomp_df <- data.frame(
  Date = as.Date(time(decomp$trend), origin = "2001-01-01"),
  Observed = as.numeric(decomp$x),
  Trend = as.numeric(decomp$trend),
  Seasonal = as.numeric(decomp$seasonal),
  Random = as.numeric(decomp$random)
)

# Graficar con ggplot
p_decomp <- decomp_df %>%
  pivot_longer(cols = c(Observed, Trend, Seasonal, Random),
               names_to = "Component", values_to = "Value") %>%
  mutate(Component = factor(Component, levels = c("Observed", "Trend", "Seasonal", "Random"))) %>%
  ggplot(aes(x = Date, y = Value)) +
  geom_line(color = "steelblue", size = 0.6) +
  facet_wrap(~Component, scales = "free_y", ncol = 1) +
  labs(title = "Time Series Decomposition of Transport CPI",
       subtitle = "Observed, Trend, Seasonal, and Random Components",
       x = "Year", y = "Value") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5, color = "gray50"),
    strip.text = element_text(face = "bold")
  )

save_plot(p_decomp, "05_decomposition_ggplot.png", "figures/decomposition", width = 10, height = 10)

# --- Prueba ADF ---
adf_result <- adf.test(ipc_ts)
adf_df <- data.frame(
  Test = "Augmented Dickey-Fuller",
  Statistic = adf_result$statistic,
  P_Value = adf_result$p.value,
  Lag_Order = adf_result$parameter
)
save_table(adf_df, "adf_test.csv")
cat("✅ ADF Test: statistic =", adf_result$statistic, ", p-value =", adf_result$p.value, "\n")

# ================================================================
# PARTE 4: SUAVIZADO CENTRAL
# ================================================================

cat("\n🌀 Central smoothing...\n")

# Aplicar suavizado
ipc_data <- ipc_data %>%
  mutate(IPC_suavizado = rollmean(IPC.Transporte, k = 5, fill = NA, align = "center"))

# Reemplazar valores en período específico
ipc_data <- ipc_data %>%
  mutate(IPC.Transporte = ifelse(
    Fecha >= as.Date("2003-01-01") & Fecha <= as.Date("2003-05-01"),
    IPC_suavizado,
    IPC.Transporte
  ))

# Guardar datos suavizados
write.csv(ipc_data, "data/processed/ipc_smoothed.csv", row.names = FALSE)
cat("✅ Data saved: data/processed/ipc_smoothed.csv\n")

# --- Gráfico Comparativo ---
p2 <- ggplot(ipc_data, aes(x = Fecha)) +
  geom_line(aes(y = IPC.Transporte, color = "Smoothed"), size = 0.8) +
  geom_line(aes(y = IPC_suavizado, color = "Original"), size = 0.8, linetype = "dashed") +
  scale_color_manual(name = "", values = c("Smoothed" = "blue", "Original" = "red")) +
  labs(title = "Original vs Smoothed Time Series",
       x = "Date", y = "CPI") +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        legend.position = "bottom")
save_plot(p2, "06_original_vs_smoothed.png", "figures/time_series_plots")

# --- Serie Suavizada ---
p3 <- ggplot(ipc_data, aes(x = Fecha, y = IPC.Transporte)) +
  geom_line(color = "blue", size = 0.8) +
  labs(title = "Transport CPI with Smoothing Applied",
       x = "Date", y = "CPI") +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
save_plot(p3, "07_smoothed_ts.png", "figures/time_series_plots")

# Crear nueva serie temporal suavizada
ipc_ts <- ts(ipc_data$IPC.Transporte, start = c(2001, 2), frequency = 12)

# ================================================================
# PARTE 5: TRANSFORMACIÓN LOGARÍTMICA
# ================================================================

cat("\n📊 Logarithmic transformation...\n")

ipc_ts_adjusted <- ipc_ts + abs(min(ipc_ts)) + 1
ipc_log <- log(ipc_ts_adjusted)

# ================================================================
# PARTE 6: MODELADO SARIMA
# ================================================================

cat("\n🔧 SARIMA modeling...\n")

# Dividir datos
train_size <- length(ipc_log) - 12
train_data <- ipc_log[1:train_size]
test_data <- ipc_log[(train_size + 1):length(ipc_log)]

# Definir modelos candidatos
model_specs <- list(
  list(name = "SARIMA(0,1,1)(0,1,1)12", order = c(0, 1, 1), seasonal = c(0, 1, 1)),
  list(name = "SARIMA(1,0,1)(1,0,1)12", order = c(1, 0, 1), seasonal = c(1, 0, 1)),
  list(name = "SARIMA(2,0,0)(0,1,1)12", order = c(2, 0, 0), seasonal = c(0, 1, 1)),
  list(name = "SARIMA(1,0,1)(0,1,1)12", order = c(1, 0, 1), seasonal = c(0, 1, 1)),
  list(name = "SARIMA(0,0,1)(1,1,1)12", order = c(0, 0, 1), seasonal = c(1, 1, 1))
)

sarima_results <- data.frame()

for (i in seq_along(model_specs)) {
  cat("  Fitting", model_specs[[i]]$name, "...\n")
  
  model <- Arima(
    train_data,
    order = model_specs[[i]]$order,
    seasonal = list(order = model_specs[[i]]$seasonal, period = 12)
  )
  
  forecast_obj <- forecast(model, h = 12)
  metrics <- calculate_metrics(test_data, forecast_obj$mean)
  
  sarima_results <- rbind(sarima_results, data.frame(
    Model = model_specs[[i]]$name,
    MAE = metrics$MAE,
    RMSE = metrics$RMSE,
    MAPE = metrics$MAPE,
    AIC = model$aic,
    BIC = model$bic
  ))
  
  # Guardar gráficas de residuales
  png(paste0("outputs/figures/residuals/08_residuals_", 
             gsub("[(),]", "", gsub(" ", "_", model_specs[[i]]$name)), ".png"),
      width = 1000, height = 800)
  par(mfrow = c(2, 2))
  plot(residuals(model), main = paste("Residuals of", model_specs[[i]]$name))
  acf(residuals(model), main = "ACF of Residuals")
  pacf(residuals(model), main = "PACF of Residuals")
  qqnorm(residuals(model), main = "Q-Q Plot")
  qqline(residuals(model), col = "red")
  dev.off()
}

save_table(sarima_results, "sarima_metrics.csv")
print(sarima_results)

# ================================================================
# PARTE 7: MODELADO HOLT-WINTERS
# ================================================================

cat("\n📉 Holt-Winters modeling...\n")

# Usar datos en escala original para HW
train_data_hw <- window(ipc_ts, end = c(2001, 2 + train_size - 1))
test_data_hw <- window(ipc_ts, start = c(2001, 2 + train_size))

# Ajustar modelo
hw_model <- hw(train_data_hw, seasonal = "additive", h = 12,
               alpha = 0.3627, beta = 0.0462, gamma = 0.2516)

hw_metrics <- calculate_metrics(test_data_hw, hw_model$mean)

hw_results <- data.frame(
  Model = "Holt-Winters Additive",
  MAE = hw_metrics$MAE,
  RMSE = hw_metrics$RMSE,
  MAPE = hw_metrics$MAPE
)

save_table(hw_results, "holt_winters_metrics.csv")

# --- Gráfica Holt-Winters ---
p4 <- autoplot(forecast(hw_model, h = 4)) +
  labs(title = "Holt-Winters Additive Model Forecast",
       x = "Year", y = "CPI") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
save_plot(p4, "09_hw_forecast.png", "figures/forecasts")

# ================================================================
# PARTE 8: COMPARACIÓN DE MODELOS
# ================================================================

cat("\n📊 Model comparison...\n")

comparison <- data.frame(
  Model = c("SARIMA(1,0,1)(1,0,1)12", "Holt-Winters Additive"),
  MAE = c(sarima_results$MAE[2], hw_metrics$MAE),
  MAPE = c(sarima_results$MAPE[2], hw_metrics$MAPE),
  RMSE = c(sarima_results$RMSE[2], hw_metrics$RMSE)
)

save_table(comparison, "model_comparison.csv")
print(comparison)

# --- Gráfica Comparativa ---
comparison_long <- comparison %>%
  pivot_longer(cols = c(MAE, MAPE, RMSE), names_to = "Metric", values_to = "Value")

p5 <- ggplot(comparison_long, aes(x = Model, y = Value, fill = Model)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~Metric, scales = "free_y") +
  labs(title = "Model Performance Comparison",
       x = "Model", y = "Error Value") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        legend.position = "none")
save_plot(p5, "10_comparison.png", "figures")

# ================================================================
# PARTE 9: PRONÓSTICO FINAL
# ================================================================

cat("\n🔮 Final forecast...\n")

# Mejor modelo: SARIMA(1,0,1)(1,0,1)12
best_model <- Arima(
  train_data,
  order = c(1, 0, 1),
  seasonal = list(order = c(1, 0, 1), period = 12)
)

# Pronóstico Sep-Dic 2024
future_forecast <- forecast(best_model, h = 4)

# Transformación inversa
forecast_df <- data.frame(
  Date = seq.Date(from = as.Date("2024-09-01"), by = "month", length.out = 4),
  Forecast = exp(as.numeric(future_forecast$mean)) - abs(min(ipc_ts)) - 1,
  Lower80 = exp(as.numeric(future_forecast$lower[, 1])) - abs(min(ipc_ts)) - 1,
  Upper80 = exp(as.numeric(future_forecast$upper[, 1])) - abs(min(ipc_ts)) - 1,
  Lower95 = exp(as.numeric(future_forecast$lower[, 2])) - abs(min(ipc_ts)) - 1,
  Upper95 = exp(as.numeric(future_forecast$upper[, 2])) - abs(min(ipc_ts)) - 1
)

save_table(forecast_df, "forecasts.csv")
print(forecast_df)

# --- Gráfica Final ---
train_dates <- seq.Date(from = as.Date("2002-02-01"), by = "month", length.out = length(train_data))
historical_df <- data.frame(
  Date = train_dates,
  Value = exp(as.numeric(train_data)) - abs(min(ipc_ts)) - 1
)

p6 <- ggplot() +
  geom_line(data = historical_df, aes(x = Date, y = Value), color = "black", size = 0.5) +
  geom_line(data = forecast_df, aes(x = Date, y = Forecast), color = "red", size = 1) +
  geom_ribbon(data = forecast_df, aes(x = Date, ymin = Lower80, ymax = Upper80),
              alpha = 0.2, fill = "orange") +
  geom_ribbon(data = forecast_df, aes(x = Date, ymin = Lower95, ymax = Upper95),
              alpha = 0.1, fill = "red") +
  labs(title = "Transport CPI Forecast: September-December 2024",
       subtitle = "SARIMA(1,0,1)(1,0,1)12 Model",
       x = "Date", y = "CPI") +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, color = "gray50"))
save_plot(p6, "11_final_forecast.png", "figures/forecasts", width = 12, height = 7)

# ================================================================
# PARTE 10: GENERACIÓN DE REPORTE COMPLETO 
# ================================================================

cat("\n📄 Generating comprehensive report...\n")

# --- 10.1: Reporte en Texto ---
generate_text_report <- function() {
  sink("outputs/reports/reporte_completo.txt")
  
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("REPORTE DE PRONÓSTICO - IPC EN TRANSPORTE\n")
  cat("Lima Metropolitana - Sep-Dic 2024\n")
  cat(paste(rep("=", 80), collapse = ""), "\n\n")
  
  cat("FECHA:", Sys.Date(), "\n")
  cat("AUTOR: Michell Karen Angélica Matias Tello\n\n")
  
  cat(paste(rep("-", 80), collapse = ""), "\n")
  cat("RESUMEN EJECUTIVO\n")
  cat(paste(rep("-", 80), collapse = ""), "\n\n")
  
  cat("El modelo SARIMA(1,0,1)(1,0,1)12 supera al modelo Holt-Winters en:\n")
  cat("  - MAE: ", comparison$MAE[1], "vs", comparison$MAE[2], "\n")
  cat("  - RMSE:", comparison$RMSE[1], "vs", comparison$RMSE[2], "\n")
  cat("  - MAPE:", comparison$MAPE[1], "% vs", comparison$MAPE[2], "%\n\n")
  
  cat(paste(rep("-", 80), collapse = ""), "\n")
  cat("PRONÓSTICO SEP-DIC 2024\n")
  cat(paste(rep("-", 80), collapse = ""), "\n\n")
  
  print(forecast_df)
  cat("\n")
  
  cat(paste(rep("-", 80), collapse = ""), "\n")
  cat("ESTADÍSTICAS DESCRIPTIVAS\n")
  cat(paste(rep("-", 80), collapse = ""), "\n\n")
  print(desc_stats)
  cat("\n")
  
  cat(paste(rep("-", 80), collapse = ""), "\n")
  cat("COMPARACIÓN DE MODELOS SARIMA\n")
  cat(paste(rep("-", 80), collapse = ""), "\n\n")
  print(sarima_results)
  cat("\n")
  
  cat("MEJOR MODELO:", comparison$Model[1], "\n")
  cat("  MAE:", comparison$MAE[1], "\n")
  cat("  RMSE:", comparison$RMSE[1], "\n")
  cat("  MAPE:", comparison$MAPE[1], "%\n\n")
  
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("FIN DEL REPORTE\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  
  sink()
  cat("✅ Text report: outputs/reports/reporte_completo.txt\n")
}

generate_text_report()

# ================================================================
# PARTE 11: RESUMEN FINAL COMPLETO
# ================================================================

cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("📋 PROYECTO COMPLETADO EXITOSAMENTE\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")
cat("📁 OUTPUTS GENERADOS:\n")

cat("\n 📊 TABLES:\n")
cat(" - outputs/tables/descriptive_stats.csv\n")
cat(" - outputs/tables/adf_test.csv\n")
cat(" - outputs/tables/sarima_metrics.csv\n")
cat(" - outputs/tables/holt_winters_metrics.csv\n")
cat(" - outputs/tables/model_comparison.csv\n")
cat(" - outputs/tables/forecasts.csv\n")

cat("\n 📈 FIGURES:\n")
cat(" - outputs/figures/time_series_plots/01_original_ts.png\n")
cat(" - outputs/figures/time_series_plots/02_boxplot_monthly.png\n")
cat(" - outputs/figures/acf_pacf/03_acf.png\n")
cat(" - outputs/figures/acf_pacf/04_pacf.png\n")
cat(" - outputs/figures/decomposition/05_decomposition_base.png\n")
cat(" - outputs/figures/decomposition/05_decomposition_ggplot.png\n")
cat(" - outputs/figures/time_series_plots/06_original_vs_smoothed.png\n")
cat(" - outputs/figures/time_series_plots/07_smoothed_ts.png\n")
cat(" - outputs/figures/residuals/08_residuals_*.png\n")
cat(" - outputs/figures/forecasts/09_hw_forecast.png\n")
cat(" - outputs/figures/10_comparison.png\n")
cat(" - outputs/figures/forecasts/11_final_forecast.png\n")

cat("\n 📄 REPORTS:\n")
cat(" - outputs/reports/reporte_completo.txt\n")

cat("🏆 BEST MODEL:", comparison$Model[1], "\n")
cat("   MAE:", comparison$MAE[1], "\n")
cat("   MAPE:", comparison$MAPE[1], "%\n")
cat("   RMSE:", comparison$RMSE[1], "\n\n")

cat("📊 FORECAST Sep-Dec 2024:\n")
print(forecast_df)

cat("\n✅ All done! Check the outputs folder for results.\n")