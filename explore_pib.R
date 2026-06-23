library(readxl)

f <- "data/pib_cantonal.xlsx"
df <- read_excel(f, sheet="Base_PIB_regional")
names(df)[1:11] <- c("anio", "region", "cod_prov", "provincia", "cod_cant", "canton", "valor_agregado", "impuestos", "pib", "exportaciones", "importaciones")

cat("Años disponibles:", sort(unique(df$anio)), "\n")
cat("Cantones por año:\n")
print(table(df$anio))
cat("Total filas:", nrow(df), "\n")

# Show a few rows for 2022
cat("\n2022 samples:\n")
print(head(df[df$anio == 2022, c("cod_prov","cod_cant","canton","pib")], 10))

# PIB per capita needs population - but we have it from ArcGIS or Censo 2022
# For now just save the PIB data
cat("\nPIB summary:\n")
print(summary(df$pib))
