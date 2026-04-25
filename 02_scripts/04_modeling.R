rm(list = ls())

library(dplyr)
library(strucchange)

data <- read.csv2("data/processed/mem_features.csv")

data$fecha <- as.Date(data$fecha)

# Modelo precio
modelo <- lm(precio ~ demanda + cmo_usd + post_reforma, data = data)
summary(modelo)

# Correlación
cor(data$precio, data$cmo_usd, use = "complete.obs")

# Modelo gap
modelo_gap <- lm(gap ~ demanda + post_reforma, data = data)
summary(modelo_gap)

# Interacción
modelo_gap2 <- lm(gap ~ demanda * post_reforma, data = data)
summary(modelo_gap2)

# Log
data <- data %>%
  mutate(gap_log = log(abs(gap) + 1))

modelo_log <- lm(gap_log ~ demanda + post_reforma, data = data)
summary(modelo_log)

# Chow test
sctest(
  gap ~ demanda,
  type = "Chow",
  point = which(data$post_reforma == 1)[1],
  data = data
)