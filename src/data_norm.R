# Cargar y eliminar comentarios del archivo de entrada BLASTP (format 7)
blast_data <- read.table("results/phosphatases_blastp_resuts_cut.tab", comment.char = "#", stringsAsFactors = FALSE)

# Para una mejor visualización asignaremos nombres a las columnas a nuestro blast_data
colnames(blast_data) <- c(
  "query",
  "subject",
  "pident",
  "length",
  "mismatch",
  "gapopen",
  "qstart",
  "qend",
  "sstart",
  "send",
  "evalue",
  "bitscore"
)

# Como paso de comprobación, usaremos unique para eliminar duplicados en el subject y el query si es que hubiera
# y formamos una lista
proteins <- unique(c(blast_data$query, blast_data$subject))
# Y calculamos la longitud final del vector
length_protein_vector <- length(proteins) 
# Como es esperado, debido a que fue un blastp contra si mismo, y teniendo 100 secuencias,
# tenemos 100 resultados no duplicados


# Crearemos una matrix inicializada en 0, de dimensiones length... x length..., y se le asigna
# nombre a las columnas y filas provinientes de la lista de las proteinas
similarity_matrix <- matrix(0, length_protein_vector, length_protein_vector, dimnames = list(proteins, proteins))

# Ahora crearemos la matriz de bits scores que se usara para la normalización y evitar la diagonal (i,i)
for(i in 1:nrow(blast_data)) {
  similarity_matrix[blast_data$query[i], blast_data$subject[i]] <- blast_data$bitscore[i]
}

# Pasamos a la normalización de los datos
temp <- similarity_matrix
# Creamos una matriz temporal y colocamos 0 en la diagnoal
diag(temp) <- 0
# Tomammos el valor máximo de la matrix de bitscores
max_bitscore <- max(temp)
 
# Normalizamos la matriz dividiendo todos los bitscores entre el valor de bitscore mas alto
normalized_matrix <- similarity_matrix/max_bitscore
normalized_matrix

# Haremos que la diagonal sea 1 cuando i=j, esto ayudara a que cuando hagamos la resta para calcular la distancia
# Esta sea igual a cero porque una proteina no puede estar lejos de si misma
diag(normalized_matrix) <- 1 
normalized_matrix

# Procedemos a converir las similitudes a disimilitudes haciendo lo siguiente:
# dij = 1 - Bij
# Asi mismo, convertiremos nuestra matrix ewn una que pueda ser le[ida por funcionde s de hclust()
dissimilarity_matrix <- as.dist(1 - normalized_matrix) 
dissimilarity_matrix
matrix_dis <- 1 - normalized_matrix

# Guardamos nuestra matrix de disimilitud
saveRDS(dissimilarity_matrix, file = "results/dissimilarity_matrix.rds")
saveRDS(matrix_dis, file = "results/matrix_dis.cvs")
