rm(list = ls())

cat("=== INICIANDO PIPELINE ===\n")

# =========================
# 1. SETEO DE DIRECTORIOS
# =========================

required_dirs <- c(
  "data/processed",
  "outputs/graficos",
  "outputs/tablas"
)

for (dir in required_dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    cat(paste("Creando carpeta:", dir, "\n"))
  }
}

# =========================
# 2. EJECUCION DE SCRIPTS
# =========================

scripts <- c(
  "scripts/01_clean_data.R",
  "scripts/02_feature_engineering.R",
  "scripts/03_analysis.R",
  "scripts/04_modeling.R",
  "scripts/05_plots.R"
)

for (s in scripts) {
  cat(paste("\n--- Ejecutando:", s, "---\n"))
  source(s)
}

# =========================
# 3. FIN
# =========================

cat("\n=== PIPELINE COMPLETADO ===\n")