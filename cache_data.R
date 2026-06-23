library(googlesheets4)
library(httr)
library(jsonlite)
library(dplyr)
library(readxl)

data_dir <- file.path("data")
gs_url <- "https://docs.google.com/spreadsheets/d/1C2oE-9FPHXF2SZxqkwwzGASlwBW5cYAlG0lXd4jl9KA/"

gs4_deauth()

# ---- 1. IDS Dimensiones Cantonales (Tabla 21 - all cantons) ----
ids21 <- read_sheet(gs_url, sheet = "Tabla 21", col_types = "c", col_names = FALSE, skip = 8)
ids21 <- ids21[, 1:9]
names(ids21) <- c("cod", "canton", "indice_salud", "indice_participa", "indice_seguridad",
                   "indice_educacion", "indice_economico", "ids_sin_normalizar", "ids_2023_final")
ids21 <- ids21[!is.na(ids21$cod) & !grepl("COD|MAXIMO|MINIMO|DIFERENCIA", ids21$cod) & nchar(ids21$cod) >= 2, ]
ids21 <- ids21 %>%
  mutate(
    across(c(indice_salud, indice_participa, indice_seguridad, indice_educacion,
             indice_economico, ids_sin_normalizar, ids_2023_final),
           ~ as.numeric(gsub(",", "", .))),
    cod_prov = substr(cod, 1, 1),
    cod_cant = substr(cod, 2, 3)
  )
write.csv(ids21, file.path(data_dir, "ids_dimensiones_cantonales.csv"), row.names = FALSE)
cat("IDS Dimensiones:", nrow(ids21), "rows\n")

# ---- 2. IDS Cantonal top/bottom (Tabla 22) ----
ids22 <- read_sheet(gs_url, sheet = "Tabla 22", col_types = "c", col_names = TRUE)
ids22 <- ids22[, 1:6]
ids22 <- ids22[!is.na(ids22[[1]]) & !grepl("POSICION|Tabla", ids22[[1]]), ]
names(ids22) <- c("posicion", "provincia", "cod", "canton", "ids_2023", "densidad_pob")
ids22 <- ids22 %>% filter(posicion != "") %>%
  mutate(
    posicion = as.numeric(posicion),
    ids_2023 = as.numeric(gsub(",", "", ids_2023)),
    densidad_pob = as.numeric(gsub(",", "", densidad_pob)),
    cod_prov = substr(cod, 1, 1),
    cod_cant = substr(cod, 2, 3)
  )
write.csv(ids22, file.path(data_dir, "ids_cantonal_2023_tabla22.csv"), row.names = FALSE)
cat("IDS Tabla22:", nrow(ids22), "rows\n")

# ---- 3. ArcGIS FeatureServer (IDPHC, IDHC, IGFM, población) ----
arcgis_url <- "https://services5.arcgis.com/bfuP6Bo71EVhNKCC/ArcGIS/rest/services/Indicadores_Cantonales_Consolidados/FeatureServer/0/query"
response <- GET(arcgis_url, query = list(where = "1=1", outFields = "*", returnGeometry = "false", f = "json"))
arcgis_data <- content(response, "parsed")
arcgis_features <- lapply(arcgis_data$features, function(f) as.data.frame(t(unlist(f$attributes))))
arcgis_df <- bind_rows(arcgis_features) %>% mutate(across(everything(), as.character))
write.csv(arcgis_df, file.path(data_dir, "indicadores_cantonales_arcgis.csv"), row.names = FALSE)
cat("ArcGIS indicators:", nrow(arcgis_df), "rows\n")

# ---- 4. GeoJSON for maps ----
response_geo <- GET(arcgis_url, query = list(where = "1=1", outFields = "COD_PROV,COD_CANT,NOM_PROV,NOM_CANT", returnGeometry = "true", f = "geojson"))
writeLines(content(response_geo, "text"), file.path(data_dir, "cantones_geometria.geojson"))
cat("GeoJSON saved\n")

# ---- 5. PIB Cantonal 2019-2022 (BCCR) ----
pib_url <- "https://gee.bccr.fi.cr/indicadoreseconomicos/Documentos/Sector%20Indices%20de%20Precios%20y%20de%20Cantidad/PIB,_VA_impuesto_X_M.xlsx"
GET(pib_url, write_disk(file.path(data_dir, "pib_cantonal.xlsx"), overwrite = TRUE))
pib <- read_excel(file.path(data_dir, "pib_cantonal.xlsx"), sheet = "Base_PIB_regional")
names(pib)[1:11] <- c("anio", "region", "cod_prov", "provincia", "cod_cant_d", "canton",
                       "valor_agregado", "impuestos", "pib", "exportaciones", "importaciones")
# Extract 3-digit canton code: first digit = province, last 2 = canton
pib <- pib %>%
  mutate(
    cod_prov = as.character(substr(as.character(cod_cant_d), 1, 1)),
    cod_cant = substr(as.character(cod_cant_d), 2, 3)
  )
write.csv(pib, file.path(data_dir, "pib_cantonal_completo.csv"), row.names = FALSE)
cat("PIB Cantonal:", nrow(pib), "rows, años:", paste(sort(unique(pib$anio)), collapse=" "), "\n")

cat("\nAll data cached!\n")
