
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
|### OBJETIVO DEL PROYECTO 2: Modelar la evolución de una magnitud económica del sistema eléctrico argentino a partir de variables operativas (demanda) y de precio.|
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
### Lo que iría a Linkedin sería: "Construir un modelo que permita analizar y predecir el valor económico del sistema eléctrico argentino a partir de la interacción entre demanda y precios.""


rm(list=ls())

setwd("C:/Users/Ramiro/Documents/Portfolio/Financial Forecast Project/03_output")

# Cargar paquetes necesarios

install.packages("broom")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("janitor")
install.packages("lubridate")
install.packages("Metrics")
install.packages("openxlsx")
install.packages("readr")
install.packages("rmarkdown")
install.packages("tidyr")
install.packages("tsibble")


library(tsibble)
library(ggplot2)
library(dplyr)
library(readr)
library(lubridate)
library(broom)
library(openxlsx)
library(Metrics)
library(rmarkdown)
library(janitor)
library(tidyr)

## Lectura de datos

data_raw <- read.xlsx(
  "C:/Users/Ramiro/Documents/Portfolio/Financial Forecast Project/01_data/raw/BASE DE DATOS - Variables Relevantes del MEM 2026-02.xlsx",
  sheet = "Base de Datos",
  startRow = 5
)

## Inspección de variables 

head(data_raw, 3)

## Limpieza de nombre de columnas

data_raw <- data_raw %>%
  clean_names()


## Selección de variables

data <- data_raw %>%
  select(
    anio = ano,
    mes,
    demanda = demanda_local,
    precio = precio_monomico_energia_potencia_transporte,
    cobertura = percent_cobertura,
    cmo = costo_marginal_operado_cmo,
    tipo_cambio = tipo_de_cambio 
  )

## Limpieza mínima

data <- data %>%
  filter(!is.na(anio), !is.na(mes))

## check de variables

head(data)

## Formato fechas

data$mes <- as.Date(data$mes, origin = "1899-12-30")

## Agregar columna fecha

data <- data %>%
  mutate(
    fecha = as.Date(mes)  # ya viene como fecha mensual
  )

## convierto columna mes en valor del mes

data$mes <- format(data$mes, "%m")

data$mes <- as.numeric(data$mes)

## Crear variable valor_energía ( si dá razonable es el CORAZÓN del proyecto) Ojo quue en algun lado hay que aclarar que este valor es el precio de la energia pagado por la demanda

data <- data %>%
  mutate(
  	valor_energia = demanda * precio
  	)

## Variable dummy post reforma regulatoria

data <- data %>%
  mutate(
    post_reforma = ifelse(fecha >= as.Date("2025-11-01"), 1, 0)
  )

#agregar columna de cmo en USD

data <- data %>%
  mutate(
    cmo_usd = cmo / tipo_cambio
  )


## Validaciones

summary(data)
any(is.na(data))

## Guardado del dataset

write.csv2(
  data,
  "C:/Users/Ramiro/Documents/Portfolio/Financial Forecast Project/01_data/processed/mem_clean.csv",
  row.names = FALSE
)

## Análisis de tendencia:

ggplot(data, aes(x = fecha, y = valor_energia)) +
  geom_line(color = "blue") +
  geom_smooth(method = "loess", se = FALSE, color = "red") +
  labs(
    title = "Tendencia del valor de energía",
    x = "Fecha",
    y = "Valor (USD)"
  )

## El valor outlier que observo es porque se dió lo siguiente en Jul'22

##  anio mes  demanda precio cobertura      cmo      fecha valor_energia post_reforma
##1 2022   7 12639.62 127.71 0.2850862 31996.23 2022-07-01       1614206            0


## Validación de outlier

data %>% 
  filter(valor_energia == max(valor_energia))

## Estacionalidad mensual

data %>%
  group_by(mes) %>%
  summarise(valor_promedio = mean(valor_energia, na.rm = TRUE)) %>%
  ggplot(aes(x = factor(mes), y = valor_promedio, group = 1)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Estacionalidad mensual del valor de energía",
    x = "Mes",
    y = "Valor promedio (USD)"
  )


## Comparativa Precio vs CMO USD (## Me deberia mostrar si el sistema está subsidiado o si el costo real supera al precio)

data %>%
  ggplot(aes(x = fecha)) +
  geom_line(aes(y = precio, color = "Precio (USD/MWh)")) +
  geom_line(aes(y = cmo_usd, color = "CMO (USD/MWh)")) +
  labs(
    title = "Precio vs Costo Marginal Operado",
    x = "Fecha",
    y = "USD/MWh",
    color = "Variable"
  ) +
  scale_color_manual(
    values = c(
      "Precio (USD/MWh)" = "blue",
      "CMO (USD/MWh)" = "red"
    )
  )



## Gap entre Precio y Costo

data <- data %>%
  mutate(gap = precio - cmo_usd)

## Análisis del gap

ggplot(data, aes(x = fecha, y = gap)) +
  geom_line(color = "darkgreen") +
  labs(
    title = "Diferencia entre Precio y Costo Marginal Operado",
    subtitle = "Gap = Precio - CMO (USD/MWh)",
    x = "Fecha",
    y = "USD/MWh"
  )

ggsave(
  filename = "gap_diferencia_precio_cmo.png",
  plot = grafico_gap,
  width = 8,
  height = 5,
  dpi = 300
)


## Promedio antes vs después de reforma

resumen_gap <- data %>% 
  group_by(post_reforma) %>%
  summarise(
    gap_promedio = mean(gap, na.rm = TRUE),
    volatilidad_gap = sd(gap, na.rm = TRUE)
  )


## Grafico de barras

ggplot(resumen_gap, aes(x = factor(post_reforma), y = gap_promedio, fill = factor(post_reforma))) +
  geom_col() +
  scale_fill_manual(
    values = c("0" = "steelblue", "1" = "darkorange"),
    labels = c("Pre reforma", "Post reforma")
  ) +
  labs(
    title = "Gap promedio: Pre vs Post reforma",
    x = "Período",
    y = "USD/MWh",
    fill = "Período"
  )

 ## Comparación entre promedio y volatilidad

resumen_long <- resumen_gap %>%
  pivot_longer(
    cols = c(gap_promedio, volatilidad_gap),
    names_to = "metric",
    values_to = "value"
  )


## gráfico comparativo

ggplot(resumen_long, aes(x = factor(post_reforma), y = value, fill = metric)) +
  geom_col(position = "dodge") +
  scale_x_discrete(
    labels = c("0" = "Pre reforma", "1" = "Post reforma")
  ) +
  scale_fill_manual(
    values = c("gap_promedio" = "steelblue", "volatilidad_gap" = "darkred"),
    labels = c("Promedio", "Volatilidad")
  ) +
  labs(
    title = "Gap: promedio y volatilidad",
    x = "Período",
    y = "USD/MWh",
    fill = "Métrica"
  )


ggsave(
  filename = "gap_promedio_volatilidad.png",
  plot = grafico_gap,
  width = 8,
  height = 5,
  dpi = 300
)


#==================
# DESCOMPOSICION SERIE TEMPORAL
#==================

# Preparar la serie

ts_demanda <- data %>%
  arrange(fecha) %>%
  pull(demanda) %>%
  ts(start = c(min(data$anio), min(data$mes)), frequency = 12)


descomposicion <- stl(ts_demanda, s.window = "periodic")

plot(descomposicion)

# Esto te va a dar 3 componentes:
	# trend → tendencia de largo plazo
	# seasonal → patrón mensual repetitivo
	# remainder → ruido / shocks

# Lo llevo a dataframe

stl_df <- data.frame(
  fecha = data$fecha,
  tendencia = descomposicion$time.series[, "trend"],
  estacionalidad = descomposicion$time.series[, "seasonal"],
  residuo = descomposicion$time.series[, "remainder"]
)

# Gráfico

ggplot(stl_df, aes(x = fecha)) +
  geom_line(aes(y = tendencia, color = "Tendencia")) +
  geom_line(aes(y = estacionalidad, color = "Estacionalidad")) +
  geom_line(aes(y = residuo, color = "Ruido")) +
  scale_color_manual(values = c(
    "Tendencia" = "blue",
    "Estacionalidad" = "darkgreen",
    "Ruido" = "red"
  )) +
  labs(
    title = "Descomposición STL de la Demanda Eléctrica",
    x = "Fecha",
    y = "MW",
    color = "Componente"
  ) +
  theme_minimal()

  # Análisis de los residuos

  var(stl_df$residuo, na.rm = TRUE)

  acf(stl_df$residuo, na.action = na.pass)

  # Si hay autocorrelación en el residuo → el modelo STL no capturó todo
  