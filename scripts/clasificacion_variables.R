# clasificacion_variables.R — Parte A: clasificación de las variables de clientes.csv.
#
# El archivo data/clientes.csv tiene 12 clientes y 7 variables (más el id).
# El objetivo: clasificar cada variable (numérica continua/discreta, categórica
# binaria/ordinal/nominal) y verificar la clasificación en código.
#
# Regla del capítulo 3: el tipo que infiere el lenguaje es una pista, no la
# clasificación — el criterio (¿tiene sentido la mitad del valor? ¿hay orden
# entre las categorías?) decide.
#
# Uso (desde la raíz del repositorio):  Rscript scripts/clasificacion_variables.R

clientes <- read.csv("data/clientes.csv", stringsAsFactors = FALSE)

# ---------------------------------------------------------------------------
# 1. Estructura del archivo
# ---------------------------------------------------------------------------
cat(sprintf("Dimensiones: %d filas × %d columnas\n", nrow(clientes), ncol(clientes)))
print(clientes)

# ---------------------------------------------------------------------------
# 2. Tipos inferidos (str) — la pista que da el lenguaje
# ---------------------------------------------------------------------------
str(clientes)
# TODO 1: ¿qué columnas llegan como número (int) y cuáles como texto
#         (character)? Anótalo para el informe. Ojo con satisfaccion: llega
#         como número y es ordinal ("4 no es el doble de 2") — la justificación
#         va en el informe.
# Resultado: int -> edad, numero_hijos, ingresos_mensuales, satisfaccion
#            chr -> cliente_id, genero, nivel_educacion, ciudad

# ---------------------------------------------------------------------------
# 3. Valores únicos — ¿cuántas categorías hay y cuáles son?
# ---------------------------------------------------------------------------
# TODO 2: completa el bucle para imprimir, por columna, cuántos valores únicos
#         hay y cuáles son. Pista: for (columna in names(clientes)) { ... } con
#         unique() y length(). ¿Cuántas categorías tiene genero?
cat("\nValores únicos por columna:\n")
for (columna in names(clientes)) {
  u <- unique(clientes[[columna]])
  cat(sprintf("%s: %d únicos -> %s\n", columna, length(u), paste(u, collapse = ", ")))
}
# genero tiene 3 categorías (Femenino, Masculino, Otro): nominal, no binaria.

# ---------------------------------------------------------------------------
# 4. Declarar el orden de las variables ordinales
# ---------------------------------------------------------------------------
# Una ordinal se guarda como texto y su orden natural se pierde: alfabéticamente
# "Posgrado" iría antes que "Primaria", que no tiene sentido. En R, eso se
# declara con el factor ordenado.
#
# TODO 3: convierte nivel_educacion con factor(..., levels = c(...), ordered = TRUE).
#         Comprueba con min(): debe devolver "Primaria".
clientes$nivel_educacion <- factor(clientes$nivel_educacion,
  levels = c("Primaria", "Secundaria", "Universidad", "Posgrado"),
  ordered = TRUE)
cat("\nnivel_educacion — niveles:", levels(clientes$nivel_educacion), "\n")
print(min(clientes$nivel_educacion))   # Primaria

# TODO 4: haz lo mismo con satisfaccion (escala 1–5 como etiquetas ordenadas).
#         Prueba extra: ¿qué pasa si en levels escribes "Postgrado" (con t) para
#         nivel_educacion? Cuenta los faltantes con sum(is.na(...)) — la trampa
#         del typo es silenciosa.
clientes$satisfaccion <- factor(clientes$satisfaccion,
  levels = 1:5, ordered = TRUE)
cat("satisfaccion — niveles:", levels(clientes$satisfaccion), "\n")
print(min(clientes$satisfaccion))      # 2 (menor valor observado; nadie puso 1)

# Verificación de que el orden quedó declarado (Ord.factor)
str(clientes)

# Prueba extra: el typo "Postgrado" convierte "Posgrado" en NA, sin avisar
prueba <- factor(read.csv("data/clientes.csv", stringsAsFactors = FALSE)$nivel_educacion,
  levels = c("Primaria", "Secundaria", "Universidad", "Postgrado"),
  ordered = TRUE)
cat("Faltantes por el typo 'Postgrado':", sum(is.na(prueba)), "\n")   # 2

# ---------------------------------------------------------------------------
# 5. Resumen de la clasificación (para el informe)
# ---------------------------------------------------------------------------
# TODO 5: completa el resumen con el tipo de cada variable (el criterio que
#         justifica cada clasificación va en el informe).
clasificacion <- c(
  cliente_id         = "Categórica nominal",
  edad               = "Numérica continua",
  numero_hijos       = "Numérica discreta",
  genero             = "Categórica nominal",
  nivel_educacion    = "Categórica ordinal",
  ciudad             = "Categórica nominal",
  ingresos_mensuales = "Numérica continua",
  satisfaccion       = "Categórica ordinal"
)
cat("\nResumen de la clasificación:\n")
for (variable in names(clasificacion)) {
  cat(sprintf("  %-18s %s\n", variable, clasificacion[[variable]]))
}