# Informe — Clasificación de variables y población vs. muestra

**Para:** Gerencia de RetailAndina S.A. · **De:** Equipo de Business Intelligence
**Fecha:** ___/___/2026 · **Asunto:** Base de fidelización: tipos de variables y estimación por muestreo

---

## Resumen ejecutivo

Clasifiqué las 7 variables de la base de fidelización (más el identificador) y verifiqué esa clasificación en código, en Python y en R. Después estimé el ingreso mensual promedio de los 400 clientes con muestras de 20, usando tres diseños: conveniencia, aleatorio simple y estratificado por ciudad, y los comparé contra el parámetro real de 1330.72 USD. La muestra por conveniencia salió cerca del parámetro (+17.78) por casualidad, pero estaba formada solo por clientes de Quito. El aleatorio simple dio medias entre 1233.00 y 1491.50 USD según la semilla y el lenguaje. Antes de decidir con una muestra, la gerencia debe saber cómo se eligió y que un solo estudio tiene un margen de variación considerable.

## Parte A — Clasificación de las variables

| Variable | Tipo | Justificación (criterio) | Verificación en código |
|---|---|---|---|
| `cliente_id` | Categórica nominal | Es una etiqueta que identifica a cada cliente. No tiene orden ni tiene sentido operar con ella. | Texto (`object` en Python, `chr` en R); 12 valores únicos, uno por cliente. |
| `edad` | Numérica continua | La mitad del valor sí tiene sentido (la mitad de 34 años son 17). Se registra en años enteros, pero lo que se mide es el tiempo, que puede tomar cualquier valor. | `int64` (Python) e `int` (R); 12 valores únicos. |
| `numero_hijos` | Numérica discreta | Es un conteo: solo toma valores enteros y la mitad de 3 hijos no tiene sentido. | `int64` / `int`; 5 valores únicos (0, 1, 2, 3, 4). |
| `genero` | Categórica nominal | Tiene 3 categorías (Femenino, Masculino, Otro) sin orden entre ellas. Al ser más de dos, no es binaria. | Texto; 3 valores únicos. |
| `nivel_educacion` | Categórica ordinal | Hay un orden claro: Primaria < Secundaria < Universidad < Posgrado, pero la distancia entre niveles no es medible. | Texto; 4 valores únicos. Declaré el orden con `CategoricalDtype(ordered=True)` en Python (dtype `category`) y con `factor(..., ordered = TRUE)` en R (`Ord.factor w/ 4 levels`). En ambos, el mínimo fue "Primaria". |
| `ciudad` | Categórica nominal | Quito, Guayaquil y Cuenca son categorías sin orden. | Texto; 3 valores únicos. |
| `ingresos_mensuales` | Numérica continua | Es una cantidad de dinero: la mitad del valor sí tiene sentido y puede tomar cualquier valor. | `int64` / `int`; 12 valores únicos. |
| `satisfaccion` | Categórica ordinal | Es una escala de 1 a 5 con orden, pero "4 no es el doble de 2": la distancia entre puntos no es medible. | `int64` / `int`; 4 valores únicos (4, 3, 5, 2). Declaré el orden 1 a 5 (`category` en Python, `Ord.factor w/ 5 levels` en R); el mínimo fue 2, el menor valor observado, porque nadie puso 1. |

**P1.** El dtype de `satisfaccion` fue `int64` en Python e `int` en R, es decir, los dos lenguajes la leyeron como número. Eso no basta para clasificarla porque el dtype solo dice cómo se guardó el dato, no qué significa. Con el criterio, la variable es ordinal: hay orden, pero la distancia entre un 2 y un 4 no equivale al doble. Si una ordinal queda como texto sin declarar el orden, el programa la ordena alfabéticamente, por ejemplo con "Posgrado" antes de "Primaria", y operaciones como `min()` dan resultados sin sentido. Además, comprobé que un error de escritura en las categorías es silencioso: al escribir "Postgrado" con t, los 2 clientes con "Posgrado" se convirtieron en valores faltantes (`Faltantes por el typo 'Postgrado': 2`, en Python y en R) sin ningún aviso.

## Parte B — Población vs. muestra

### La población y su parámetro

| Concepto | Valor |
|---|---|
| Población (N) | 400 clientes (Quito 200, Guayaquil 120, Cuenca 80) |
| Variable de interés | `ingresos_mensuales` |
| Parámetro poblacional (media) | 1330.72 USD |

Se muestrea aunque el parámetro exista porque aquí la población es pequeña y se pudo calcular el valor real, lo que sirve de espejo para juzgar las muestras. En un caso real, estudiar a todos los clientes suele ser demasiado costoso o lento, y por eso se estima a partir de una muestra.

### Los tres diseños

**Python** (`sample(20, random_state=1)` y `groupby("ciudad").sample(frac=0.05, random_state=1)`):

| Diseño | n | Media estimada | Composición por ciudad | Diferencia vs. parámetro |
|---|---|---|---|---|
| Conveniencia (`head`) | 20 | 1348.50 | Quito 20 | +17.78 |
| Aleatorio simple (`sample`) | 20 | 1336.00 | Cuenca 8, Quito 8, Guayaquil 4 | +5.28 |
| Estratificado (`groupby` + 5 %) | 20 | 1287.50 | Quito 10, Guayaquil 6, Cuenca 4 | −43.22 |

**R** (`set.seed(1)`, `sample()` y `slice_sample(prop = 0.05)`):

| Diseño | n | Media estimada | Composición por ciudad | Diferencia vs. parámetro |
|---|---|---|---|---|
| Conveniencia (`head`) | 20 | 1348.50 | Quito 20 | +17.78 |
| Aleatorio simple (`sample`) | 20 | 1318.00 | Cuenca 5, Guayaquil 7, Quito 8 | −12.72 |
| Estratificado (`slice_sample`) | 20 | 1226.00 | Cuenca 4, Guayaquil 6, Quito 10 | −104.72 |

Medias de 5 sorteos distintos del aleatorio simple (semillas 1 a 5):

| Semilla | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Media (Python) | 1336.00 | 1405.00 | 1235.00 | 1491.50 | 1288.00 |
| Media (R) | 1318.00 | 1287.50 | 1233.00 | 1385.50 | 1283.00 |

El aleatorio simple y el estratificado dan números distintos en Python y en R aunque usen la misma semilla, porque cada lenguaje usa un generador de números aleatorios diferente. La conveniencia da lo mismo en los dos porque no depende del azar.

**P2.** El parámetro poblacional vale 1330.72 USD. En Python, la conveniencia estimó 1348.50, el aleatorio simple 1336.00 y el estratificado 1287.50; en R estimaron 1348.50, 1318.00 y 1226.00. En los dos lenguajes el que quedó más cerca fue el aleatorio simple (+5.28 en Python y −12.72 en R) y el más lejos fue el estratificado (−43.22 y −104.72). Eso no alcanza para declarar un ganador, porque cada cifra viene de una sola corrida: con otras semillas el aleatorio simple dio entre 1233.00 y 1491.50, y el estratificado habría dado otros valores. El estratificado garantiza la composición de la muestra (10, 6 y 4), pero no que la media de ese sorteo concreto quede cerca del parámetro. La conveniencia quedó cerca (+17.78) por casualidad, como explico en P3. Un número cercano en una corrida no demuestra que el diseño sea bueno.

**P3.** La muestra por conveniencia tiene 20 filas, pero su defecto es el sesgo de selección: las 20 primeras filas son todas de Quito (Quito 20, Guayaquil 0, Cuenca 0), mientras que en la población Quito es el 50 %, Guayaquil el 30 % y Cuenca el 20 %. Lo delata la composición por ciudad, que no se parece en nada a la población, y no se parecería a la de un sorteo al azar. Eso importa porque una muestra solo de Quito no representa a Guayaquil ni a Cuenca, y si los ingresos de esas ciudades fueran distintos, la estimación quedaría desviada de forma sistemática. Que haya quedado cerca del parámetro (+17.78) fue casualidad. Tomar más filas con el mismo criterio no lo corrige, porque el problema no es el tamaño sino cómo se eligió: seguiría dependiendo del orden del archivo y no del azar.

**P4.** Las medias del sorteo aleatorio fueron distintas en cada semilla. En Python variaron entre 1235.00 y 1491.50 USD, unos 256 USD de diferencia (cerca del 19 % del parámetro), y en R entre 1233.00 y 1385.50, unos 152 USD (cerca del 11 %). Esto es variabilidad de muestreo: no tiene una dirección fija, porque unas medias quedaron por encima del parámetro y otras por debajo. Para una empresa que decide con un solo estudio, significa que el resultado podría haber sido otro si el sorteo hubiera sido distinto, así que conviene reportar la estimación junto con su incertidumbre y no tomarla como un valor exacto.

**P5.** Usaría la muestra por conveniencia solo en un piloto o prueba rápida, por ejemplo para probar si una encuesta se entiende, sin sacar conclusiones sobre toda la población. Usaría el aleatorio simple cuando quiera una conclusión sobre todos los clientes y no necesite garantizar que ningún subgrupo aparezca, por ejemplo para estimar el ingreso promedio general. Usaría el estratificado cuando haya subgrupos que deben aparecer, como las ciudades: garantiza 10 de Quito, 6 de Guayaquil y 4 de Cuenca, mientras que el sorteo simple dio 8, 4 y 8 en Python, y 8, 7 y 5 en R, es decir, composiciones que cambian de un sorteo a otro.

## Conclusiones

1. **El diseño decide, no el tamaño.** Las tres muestras tenían 20 filas, pero solo la de conveniencia quedó formada exclusivamente por Quito (20 de 20, frente al 50 % de la población). Con más filas elegidas con el mismo criterio, el sesgo seguiría igual.
2. **Una sola muestra no basta para estimar.** El aleatorio simple dio medias entre 1233.00 y 1491.50 USD según la semilla y el lenguaje, alrededor del parámetro de 1330.72 USD. El estratificado quedó más lejos del parámetro que los otros dos en ambos lenguajes (−43.22 en Python y −104.72 en R), lo que muestra que ningún diseño debe declararse "mejor" por una sola corrida.
3. **Recomendación a la gerencia.** Con esta base de 400 clientes y estos tres diseños, antes de aceptar un análisis basado en muestras conviene preguntar cómo se eligió la muestra y qué composición por ciudad tiene. Si las ciudades importan, pedir una muestra estratificada, y presentar cualquier estimación con su variabilidad y no como un único número.