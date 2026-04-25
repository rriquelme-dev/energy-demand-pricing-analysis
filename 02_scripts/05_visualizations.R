rm(list = ls())

library(dplyr)
library(ggplot2)
library(tidyr)

data <- read.csv2("data/processed/mem_features.csv")

data$fecha <- as.Date(data$fecha)

# Precio vs CMO
p1 <- ggplot(data, aes(x = fecha)) +
  geom_line(aes(y = precio, color = "Precio")) +
  geom_line(aes(y = cmo_usd, color = "CMO")) +
  scale_color_manual(values = c("Precio" = "blue", "CMO" = "red")) +
  labs(title = "Precio vs CMO", y = "USD/MWh")

ggsave("outputs/graficos/precio_vs_cmo.png", p1, width = 8, height = 5)

# Gap
p2 <- ggplot(data, aes(x = fecha, y = gap)) +
  geom_line(color = "darkgreen") +
  labs(title = "Gap Precio - CMO", y = "USD/MWh")

ggsave("outputs/graficos/gap.png", p2, width = 8, height = 5)

# Resumen gap
resumen <- data %>%
  group_by(post_reforma) %>%
  summarise(
    gap_promedio = mean(gap, na.rm = TRUE),
    volatilidad = sd(gap, na.rm = TRUE)
  )

resumen_long <- resumen %>%
  pivot_longer(-post_reforma, names_to = "metric", values_to = "value")

p3 <- ggplot(resumen_long, aes(x = factor(post_reforma), y = value, fill = metric)) +
  geom_col(position = "dodge") +
  scale_x_discrete(labels = c("0" = "Pre", "1" = "Post")) +
  labs(
    title = "Gap: promedio y volatilidad",
    x = "Período Reforma",
    y = "USD/MWh",
    fill = "Métrica"
  ) +
  labs(title = "Gap: promedio vs volatilidad")

ggsave("outputs/graficos/gap_resumen.png", p3, width = 8, height = 5)