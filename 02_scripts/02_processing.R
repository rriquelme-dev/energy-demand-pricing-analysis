rm(list = ls())

library(dplyr)
library(lubridate)
library(readr)

data <- read.csv2("data/processed/mem_clean.csv")

# Fecha
data$mes <- as.Date(data$mes, origin = "1899-12-30")

data <- data %>%
  mutate(
    fecha = as.Date(mes),
    mes = as.numeric(format(mes, "%m"))
  )

data$fecha <- as.Date(data$fecha)

# Variables derivadas
data <- data %>%
  mutate(
    valor_energia = demanda * precio,
    post_reforma = ifelse(fecha >= as.Date("2025-11-01"), 1, 0),
    cmo_usd = cmo / tipo_cambio,
    gap = precio - cmo_usd
  )

# Guardado
write.csv2(
  data,
  "data/processed/mem_features.csv",
  row.names = FALSE
)