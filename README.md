# Determinantes del Desarrollo Cantonal en Costa Rica

Análisis del Índice de Desarrollo Social 2023 (MIDEPLAN) y sus factores asociados: indicadores cantonales de pobreza y desarrollo humano (ArcGIS/PNUD 2011-2013) y Producto Interno Bruto cantonal (BCCR 2022).

## Contenido

- `desarrollo_cantonal.Rmd` — Reporte completo en RMarkdown (53 chunks)
- `desarrollo_cantonal.html` — Reporte renderizado autónomo (sin dependencias externas)
- `cache_data.R` — Script para recargar todos los datos desde las fuentes oficiales
- `data/` — Datos cacheados (IDS 2023, ArcGIS GeoJSON, PIB Cantonal BCCR)

## Fuentes

| Fuente | Datos | Año |
|--------|-------|-----|
| [MIDEPLAN - IDS 2023](https://www.mideplan.go.cr/indice-de-desarrollo-social) | Índice de Desarrollo Social y 5 dimensiones (84 cantones) | 2023 |
| [ArcGIS - PNUD/UCR/INEC](https://arcgis.mideplan.go.cr/arcgis/rest/services) | IDPHC, IDHC, IGFM, población (81 cantones) | 2011-2013 |
| [BCCR - PIB Regional](https://gee.bccr.fi.cr/indicadoreseconomicos/) | PIB, Valor Agregado, exportaciones, importaciones | 2019-2022 |

## Metodología

- Fusión por código de cantón (3 dígitos)
- Análisis exploratorio (distribuciones, top/bottom, por provincia)
- Matriz de correlaciones y pares
- PCA sobre las 5 dimensiones del IDS
- Regresión lineal múltiple con diagnóstico completo (VIF, Durbin-Watson, ANOVA)
- Mapas coropléticos con `sf` y `ggplot2`

## Requisitos

R 4.4+ con los paquetes: `dplyr`, `tidyr`, `ggplot2`, `corrplot`, `FactoMineR`, `factoextra`, `GGally`, `car`, `lmtest`, `sf`, `kableExtra`, `googlesheets4`, `httr`, `jsonlite`, `readxl`.

## Licencia

Datos: MIDEPLAN, PNUD/UCR/INEC y BCCR — uso académico.
