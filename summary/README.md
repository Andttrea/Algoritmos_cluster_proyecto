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
---
2. **¿Cuál es el árbol menos informativo para la clasificación?**
    * **Single Linkage (Plot 01)**.
    * **Razón:** Este método presenta un fuerte efecto de **"encadenamiento"**. En lugar de formar grupos compactos y separados, las secuencias se añaden una a una a un núcleo central. Esto resulta en una estructura poco clara que dificulta la distinción de familias o clases funcionales, ya que no logra establecer fronteras nítidas entre los diferentes niveles de similitud de las proteínas.
---
3. **¿Cuántos árboles muestran agrupaciones consistentes con la taxonomía conocida?**
    * **Evaluación:** La consistencia se mide observando si las proteínas de organismos relacionados (nombres en las hojas) quedan agrupadas en los mismos niveles de la jerarquía.
    * **Tendencia General:**
        * **Ward y Average** muestran la mayor consistencia con las clasificaciones taxonómicas tradicionales, ya que la similitud en las secuencias de estas proteínas suele correlacionarse con la cercanía biológica de las especies.
        * **Complete Linkage** también logra recuperar grupos coherentes, aunque tiende a forzar fronteras muy rígidas que pueden separar elementos relativamente similares.
        * **Single Linkage** falla en representar la jerarquía taxonómica debido a su tendencia a la linealidad.
    * **Conclusión:** Se observa que **3 de los 4 métodos** (Ward, Average y Complete) logran recuperar agrupaciones que coinciden con la clasificación biológica esperada. Sin embargo, se reitera que estos resultados son **fenogramas** (diagramas de similitud) y no **filogenias**, por lo que cualquier coincidencia con la historia evolutiva es una consecuencia de la conservación de las secuencias y no una prueba del proceso evolutivo *per se*.

---

#### 4. **¿Cuál es el árbol con el agglomerative coefficient más alto?**

*   **Resultado:** El análisis de los coeficientes de aglomeración (calculados mediante la función `agnes`) identifica al método **Ward.D2** con el score más alto (**0.9341933**), seguido muy de cerca por el método **Complete Linkage** (**0.9308426**).

*   **Interpretación Técnica:** 
    El *Agglomerative Coefficient* (AC) mide la fuerza de la estructura de agrupamiento encontrada. Un valor cercano a 1 indica que el algoritmo ha logrado identificar una estructura jerárquica muy clara y robusta en los datos. 
    *   **Ward.D2** obtiene el valor máximo porque su objetivo matemático es, precisamente, minimizar la varianza interna. Al forzar la creación de clústeres lo más compactos y cohesivos posibles, el algoritmo "maximiza" la percepción de una estructura organizada, lo que se refleja en un AC elevado.
    *   **Complete Linkage** también presenta un coeficiente alto debido a que utiliza la distancia máxima (el diámetro del clúster) para las fusiones, lo que evita el encadenamiento y favorece la formación de grupos bien definidos y compactos.

*   
    Es fundamental notar que un AC alto **no significa necesariamente que el árbol sea "biológicamente correcto"** o que represente una verdad evolutiva. Un coeficiente elevado simplemente indica que el método fue muy eficiente en encontrar una estructura bajo sus propios criterios matemáticos (en este caso, la compacidad). 
    Mientras que **Single Linkage** suele tener el AC más bajo debido al efecto de encadenamiento (que crea una estructura "laxa"), los valores superiores a 0.90 en Ward y Complete sugieren que la matriz de disimilitud de estas proteínas posee grupos de similitud intrínsecos muy fuertes que ambos algoritmos logran capturar con éxito.

---

### 5. Conclusiones Generales del Análisis de Clustering

Con el conocimiento adquirido durante el curso se nos permitió explorar la estructura de similitud de un conjunto de secuencias proteicas mediante técnicas de clustering jerárquico, transformando datos de alineamiento primario en representaciones gráficas de disimilitud. Tras evaluar los resultados obtenidos, se presentan las siguientes conclusiones:

#### 5.1. Naturaleza Fenética del Análisis
Es imperativo reiterar que los dendrogramas generados en este proyecto son **fenogramas** y no árboles filogenéticos. Mientras que una filogenia busca reconstruir la historia evolutiva y los ancestros comunes mediante modelos probabilísticos de sustitución, el clustering jerárquico se limita a agrupar objetos basándose en su **similitud numérica actual**. Por lo tanto, las agrupaciones observadas deben interpretarse como "clases de similitud de secuencia" y no como una crónica definitiva de la evolución de estas proteínas.

#### 5.2. Robustez y Estructura de los Datos
La consistencia observada en los métodos de **Ward.D2**, **Average** y **Complete Linkage** para recuperar grupos taxonómicos conocidos sugiere que la señal biológica de las secuencias es lo suficientemente fuerte como para trascender las diferencias algorítmicas. El hecho de que el método de **Ward.D2** haya obtenido el **Agglomerative Coefficient** más alto (0.9341) confirma la existencia de una estructura de grupos altamente cohesiva y bien definida en la matriz de disimilitud original, lo que facilita la identificación de familias proteicas discretas.

#### 5.3. Sensibilidad Metodológica
El análisis comparativo demostró que la elección del método de unión (*linkage*) altera drásticamente la topología del árbol:
*   El efecto de **encadenamiento** en el método *Single Linkage* resultó ser el menos informativo para la clasificación funcional, al no lograr establecer fronteras claras entre grupos.
*   Los métodos de **Ward** y **Average** demostraron ser las herramientas más eficaces para la visualización de la jerarquía biológica, proporcionando un equilibrio entre la compacidad de los clústeres y la preservación de las distancias promedio.

#### 5.4. Alcance y Aplicaciones Futuras
Este flujo de trabajo constituye una etapa de **exploración de datos (EDA)** fundamental. La identificación de clústeres consistentes permite proponer hipótesis sobre la función de proteínas no caracterizadas basándose en su proximidad estadística con proteínas conocidas. Sin embargo, para transformar estas observaciones en inferencias evolutivas válidas, los grupos identificados aquí deberían ser sometidos a análisis de máxima verosimilitud o inferencia bayesiana, utilizando modelos de evolución molecular que este análisis de clustering, por definición, no contempla.

En resumen, el clustering jerárquico ha demostrado ser una herramienta poderosa para organizar la complejidad de las secuencias proteicas en estructuras manejables e informativas, siempre que se mantenga una distinción clara entre la **similitud estadística** y la **relación evolutiva**.