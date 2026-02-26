# A.- Introducción al Análisis de Clustering 

Este proyecto tiene como objetivo explorar los patrones de similitud y la estructura de agrupamiento en un conjunto de secuencias de proteínas mediante técnicas de **clustering jerárquico**. El análisis utiliza datos derivados de alineamientos de secuencias (BLASTP) para construir dendrogramas que visualicen la organización de los datos basada en distancias numéricas.

Es fundamental comprender que este análisis es de naturaleza **exploratoria y fenética** (basada en similitud actual). Los dendrogramas generados **no son árboles filogenéticos**, no modelan procesos evolutivos, ancestros comunes ni tasas de sustitución, sino que reflejan niveles de disimilitud estadística entre las secuencias.

---

## Consideraciones Críticas en el Análisis

### 1. Definición de la Métrica de Disimilitud
El pilar del clustering es la transformación de datos biológicos en una matriz de distancias matemáticas.
*   **Origen de los datos:** Se utilizaron *bitscores* de un análisis BLASTP "all-vs-all". El *bitscore* es una medida de similitud de alineamiento que permite comparaciones consistentes entre pares.
*   **Normalización y Transformación:** Para obtener una escala comparable, los puntajes se normalizaron y se transformaron en una matriz de disimilitud ($D$) mediante la fórmula $D = 1 - S$.
*   **Interpretación Estadística:** Un valor de $0$ indica identidad o similitud máxima en el alineamiento, mientras que un valor cercano a $1$ indica una alta disimilitud numérica. Esta métrica mide qué tan "lejos" está una secuencia de otra en el espacio de los datos, sin inferir necesariamente una distancia temporal o evolutiva.

### 2. Impacto del Método de Agrupamiento (Linkage)
Se aplicaron cuatro algoritmos de aglomeración (`single`, `complete`, `average`, `ward.D2`). Cada uno impone una lógica distinta sobre cómo se fusionan los grupos, lo que altera la topología del dendrograma resultante:

*   **Single Linkage (Vecino más cercano):** Fusiona grupos basados en la distancia mínima entre cualquier par de elementos.
    *   *Limitación:* Propenso al **encadenamiento** (*chaining*), lo que suele oscurecer la estructura jerárquica real de los datos.
*   **Complete Linkage (Vecino más lejano):** Considera la distancia máxima entre miembros de los clústeres.
    *   *Tendencia:* Genera clústeres compactos y es útil para encontrar grupos bien delimitados, aunque es sensible a valores atípicos (*outliers*).
*   **Average Linkage (UPGMA):** Calcula el promedio de todas las distancias entre pares de los dos clústeres.
    *   *Nota técnica:* Aunque es común en estudios biológicos por su equilibrio estadístico, en este contexto se utiliza estrictamente para representar la distancia promedio de los datos, sin asumir la existencia de un "reloj molecular".
*   **Ward's Method (Ward.D2):** Minimiza la varianza total (suma de cuadrados) dentro de los clústeres.
    *   *Tendencia:* Es el método más robusto para identificar clústeres esféricos y compactos, facilitando la visualización de grupos de proteínas con perfiles de similitud altamente consistentes.

### 3. Interpretación y Validación de los Resultados
*   **Consistencia de Grupos:** La robustez de un clúster no se determina por un solo árbol, sino por su persistencia a través de diferentes métodos. Si un conjunto de proteínas se agrupa consistentemente en los cuatro dendrogramas, existe una **alta confianza estadística** en su similitud intrínseca.
*   **Correlación Cofenética:** Para evaluar la fidelidad del dendrograma, se compara la matriz de distancias del árbol con la matriz de disimilitud original. Esto permite identificar qué método de *linkage* distorsiona menos la estructura original de los datos.
*   **Alcance del Estudio:** Los resultados permiten identificar subfamilias de proteínas y grupos funcionales basados en la conservación de su secuencia primaria, proporcionando una base para hipótesis biológicas que deberán ser validadas posteriormente con métodos filogenéticos o experimentales.

# B.- Análisis Visual y Discusión de los Dendrogramas

A continuación, se presentan los dendrogramas generados por los cuatro métodos de clustering jerárquico. La inspección visual permite evaluar la capacidad de cada algoritmo para agrupar las secuencias basándose en su matriz de distancias, sin que esto implique necesariamente una reconstrucción de su historia evolutiva.

#### 4.1 Visualización de los Árboles

| Método | Dendrograma | Características Visuales |
| :--- | :---: | :---: |
| **Single Linkage** | ![Single](../results/plots/01_hclust_NA.png) | Marcado efecto de "encadenamiento" (chaining). |
| **Complete Linkage** | ![Complete](../results/plots/02_hclust_NA.png) | Estructura de clústeres más compactos y definidos. |
| **Average Linkage** | ![Average](../results/plots/03_hclust_NA.png) | Estructura balanceada basada en distancias promedio. |
| **Ward's Method** | ![Ward](../results/plots/04_hclust_NA.png) | Clústeres con jerarquía clara y mínima varianza interna. |

#### 4.2 Discusión de Resultados

1. **¿Cuál es el árbol más informativo para identificar grupos de similitud?**
    * **Ward.D2 (Plot 04) y Average Linkage (Plot 03)** resultan ser los más útiles para la interpretación visual de grupos.
    * **Razón:** El método de **Ward** es altamente eficiente para definir grupos discretos al minimizar la varianza dentro de cada clúster, lo que facilita la identificación de conjuntos de proteínas con características similares. Por su parte, **Average Linkage (UPGMA)** ofrece un compromiso estadístico al considerar la distancia promedio entre todos los miembros de los grupos, lo que suele generar una estructura jerárquica más equilibrada. Es importante notar que, aunque estos métodos agrupen proteínas de especies cercanas, **no deben interpretarse como inferencias filogenéticas**, ya que el clustering se basa en similitud fenética (distancia actual) y no en modelos de sustitución evolutiva o búsqueda de ancestros comunes.

2. **¿Cuál es el árbol menos informativo para la clasificación?**
    * **Single Linkage (Plot 01)**.
    * **Razón:** Este método presenta un fuerte efecto de **"encadenamiento"**. En lugar de formar grupos compactos y separados, las secuencias se añaden una a una a un núcleo central. Esto resulta en una estructura poco clara que dificulta la distinción de familias o clases funcionales, ya que no logra establecer fronteras nítidas entre los diferentes niveles de similitud de las proteínas.

3. **¿Cuántos árboles muestran agrupaciones consistentes con la taxonomía conocida?**
    * **Evaluación:** La consistencia se mide observando si las proteínas de organismos relacionados (nombres en las hojas) quedan agrupadas en los mismos niveles de la jerarquía.
    * **Tendencia General:**
        * **Ward y Average** muestran la mayor consistencia con las clasificaciones taxonómicas tradicionales, ya que la similitud en las secuencias de estas proteínas suele correlacionarse con la cercanía biológica de las especies.
        * **Complete Linkage** también logra recuperar grupos coherentes, aunque tiende a forzar fronteras muy rígidas que pueden separar elementos relativamente similares.
        * **Single Linkage** falla en representar la jerarquía taxonómica debido a su tendencia a la linealidad.
    * **Conclusión:** Se observa que **3 de los 4 métodos** (Ward, Average y Complete) logran recuperar agrupaciones que coinciden con la clasificación biológica esperada. Sin embargo, se reitera que estos resultados son **fenogramas** (diagramas de similitud) y no **filogenias**, por lo que cualquier coincidencia con la historia evolutiva es una consecuencia de la conservación de las secuencias y no una prueba del proceso evolutivo *per se*.