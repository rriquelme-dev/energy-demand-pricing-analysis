rm(list = ls())

library(openxlsx)
library(dplyr)
library(janitor)

# Lectura
data_raw <- read.xlsx(
  "data/raw/BASE DE DATOS - Variables Relevantes del MEM 2026-02.xlsx",
  sheet = "Base de Datos",
  startRow = 5
)

# Limpieza nombres
data_raw <- data_raw %>%
  clean_names()

# Selección
data <- data_raw %>%
  select(
    anio = ano,
    mes,
    demanda = demanda_local,
    precio = precio_monomico_energia_potencia_transporte,
    cobertura = percent_cobertura,
    cmo = costo_marginal_operado_cmo,
    tipo_cambio = tipo_de_cambio
  ) %>%
  filter(!is.na(anio), !is.na(mes))

# Guardado
write.csv2(
  data,
  "data/processed/mem_clean.csv",
  row.names = FALSE
)