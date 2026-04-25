rm(list = ls())

library(dplyr)
library(ggplot2)
library(tidyr)

data <- read.csv2("data/processed/mem_features.csv")

data$fecha <- as.Date(data$fecha)

# Tendencia
ggplot(data, aes(x = fecha, y = valor_energia)) +
  geom_line(color = "blue") +
  geom_smooth(method = "loess", se = FALSE, color = "red") +
  labs(
    title = "Tendencia del valor de energía",
    x = "Fecha",
    y = "USD"
  )

# Estacionalidad
data %>%
  group_by(mes) %>%
  summarise(valor_promedio = mean(valor_energia, na.rm = TRUE)) %>%
  ggplot(aes(x = factor(mes), y = valor_promedio, group = 1)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Estacionalidad mensual",
    x = "Mes",
    y = "USD"
  )

# STL
ts_demanda <- data %>%
  arrange(fecha) %>%
  pull(demanda) %>%
  ts(start = c(min(data$anio), min(data$mes)), frequency = 12)

descomposicion <- stl(ts_demanda, s.window = "periodic")

stl_df <- data.frame(
  fecha = data$fecha,
  tendencia = descomposicion$time.series[, "trend"],
  estacionalidad = descomposicion$time.series[, "seasonal"],
  residuo = descomposicion$time.series[, "remainder"]
)

stl_long <- stl_df %>%
  pivot_longer(-fecha, names_to = "componente", values_to = "valor")

ggplot(stl_long, aes(x = fecha, y = valor)) +
  geom_line(color = "steelblue") +
  facet_wrap(~ componente, scales = "free_y") +
  theme_minimal()