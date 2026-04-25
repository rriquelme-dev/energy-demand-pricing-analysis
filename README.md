# ⚡ Análisis de Demanda y Precio de Energía (MEM Argentina)

## 📊 Descripción

Este proyecto analiza la relación entre la demanda eléctrica, el costo marginal y el precio de la energía en el Mercado Eléctrico Mayorista (MEM) de Argentina en el período 2018 a Febrero 2026.

El objetivo central es responder una pregunta clave:

> **¿El precio de la energía refleja realmente su costo?**

A través de análisis de series temporales y modelos econométricos, se busca identificar posibles distorsiones en la formación de precios.

---

## 📁 Estructura del Proyecto


01_data/

├── raw/        # Datos originales (Excel)

├── processed/  # Datos limpios y transformados

02_scripts/

├── 01_clean_data.R

├── 02_processing.R


├── 03_analysis.R

├── 04_modeling.R

├── 05_visualizations.R

├── run_all.R

03_output/

└── graficos/

            ├── descomposicion_stl.png
    
            ├── gap.png
    
            ├── gap_resumen.png
    
            ├── precio_vs_cmo.png



⚙️ Metodología



🔹 1. Preparación de datos

Limpieza del dataset original del MEM
Tratamiento de valores faltantes
Construcción de una serie temporal consistente



🔹 2. Ingeniería de variables

Se utilizaron y construyeron las siguientes variables clave:

* Demanda eléctrica (GWh)
* Precio monómico
* Costo marginal (CMO)
* Gap = Precio – Costo
* Variable dummy indicadora de reforma


🔹 3. Análisis de series temporales

### Descomposición STL para identificar tendencia, estacionalidad y ruido:

<p align="center">
  <img src="03_output/graficos/descomposicion_stl.png" width="700">
</p>

Hallazgos:

* Fuerte componente estacional (asociado a ciclos de demanda)
* Cambios estructurales en el tiempo


🔹 4. Modelado econométrico

Se estimó el siguiente modelo:

gap ~ demanda * post_reforma

Resultados principales:

* La demanda tiene un efecto significativo sobre el gap
* La variable de reforma no resulta estadísticamente significativa
* No se detecta un cambio estructural fuerte


🔹 5. Test de cambio estructural

Test de Chow:

p-valor ≈ 0.12
→ No se rechaza la hipótesis de estabilidad estructural

📈 Visualizaciones clave

### Evolución del Gap

<p align="center">
  <img src="03_output/graficos/gap.png" width="700">
</p>

### Precio vs Costo Marginal

<p align="center">
  <img src="03_output/graficos/precio_vs_cmo.png" width="700">
</p>

📌 Principales conclusiones

* El precio de la energía no refleja de manera consistente el costo marginal
* Existen desvíos significativos y variables en el tiempo
* La demanda tiene un rol relevante en la dinámica del sistema
* Los cambios regulatorios analizados no muestran impacto estadísticamente robusto

🧠 Interpretación

Los resultados sugieren la presencia de:

* Distorsiones regulatorias
* Esquemas de subsidios
* Mecanismos de fijación de precios que no responden plenamente a señales de mercado


🚀 Reproducibilidad

Para ejecutar todo el pipeline:

source("02_scripts/run_all.R")


🛠️ Herramientas utilizadas

R
tidyverse
ggplot2
forecast
strucchange
