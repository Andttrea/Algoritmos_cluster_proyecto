# Cargar librerias
library(cluster)
suppressPackageStartupMessages(library(factoextra))
suppressPackageStartupMessages(library(dendextend))
suppressPackageStartupMessages(library(ape))
suppressPackageStartupMessages(library(corrplot))

# Guardamos la matriz de disimilitud
dissimilarity_matrix <- readRDS(file = "results/dissimilarity_matrix.rds")
dissimilarity_matrix
matrix_dis <- readRDS(file = "results/matrix_dis.cvs")

# Correremos los cluster jerarquicos 
cluster_sin <- hclust(dissimilarity_matrix, method = "single")
cluster_com <- hclust(dissimilarity_matrix,method = "complete")
cluster_ave <- hclust(dissimilarity_matrix, method = "average")
cluster_war <- hclust(dissimilarity_matrix, method = "ward.D2")

# Función para plotear
plot_cluster <- function(cluster) {
  plot(cluster, hang = -1)
}

# Ploteamos
plot_cluster(cluster_sin)
plot_cluster(cluster_com)
plot_cluster(cluster_ave)
plot_cluster(cluster_war)

# Se cambia el dendograma en formato Newick 
sin_tree <- as.phylo(cluster_sin)
com_tree <- as.phylo(cluster_com)
ave_tree <- as.phylo(cluster_ave)
war_tree <- as.phylo(cluster_war)

# Se guardan los árboles Newick
write.tree(phy = sin_tree, file = "results/single.tree")
write.tree(phy = com_tree, file = "results/complete.tree")
write.tree(phy = ave_tree, file = "results/average.tree")
write.tree(phy = war_tree, file = "results/ward_D2.tree")

# Comparamos los distintos metodos jerarquicos y los dendogramas 

dendogram_1 <- as.dendrogram(cluster_sin)
dendogram_2 <- as.dendrogram(cluster_com)
dendogram_3 <- as.dendrogram(cluster_ave)
dendogram_4 <- as.dendrogram(cluster_war)

compare_tanglement <- function(dend_1, dend_2, dend_3, dend_4) {
  # Usar list() en lugar de c() para dendrogramas
  dends <- list(dend_1, dend_2, dend_3, dend_4)
  nombres <- c("Single", "Complete", "Average", "Ward")
  # Generar todas las combinaciones únicas de pares (C(4,2) = 6)
  combos <- combn(1:4, 2)
  
  for (k in 1:ncol(combos)) {
    i <- combos[1, k]
    j <- combos[2, k]
    
    titulo <- paste0(nombres[i], " vs ", nombres[j],
                     " | Entanglement: ",
                     round(entanglement(dendlist(dends[[i]], dends[[j]])), 3))
    
    tanglegram(dends[[i]], dends[[j]], main = titulo)
  }
}

compare_tanglement(dendogram_1, dendogram_2, dendogram_3, dendogram_4)

trees = dendlist("com"=dendogram_2, "sing"=dendogram_1, "ave"=dendogram_3, "ward"=dendogram_4)
baker = cor.dendlist(trees,method="baker")

corrplot(baker,
         method="circle",
         type="lower",
         tl.col = "black",
         tl.cex = 1.0,
         cl.cex = 1.0,
         addCoef.col = "white",
         number.cex = 1.0,
         col.lim=c(0.0,1),
         col=COL2("RdBu",n = 20)
)


# Para calcular el numero ideal de clusters haremos lo siguiente
# Creación de una función para cada método de busqueda y cada cluster jerárquico 
run_all <- function(matrix_dis, FUN, k_max, method_list) {
  methods <- c("gap_stat", "wss", "silhouette")
  for(method in method_list) {
    for(m in methods) {
      print(fviz_nbclust(matrix_dis, FUN = FUN, hc_method = method, method = m, k.max = k_max) +
        labs(subtitle = paste(method, "-", m)))
    }
  }
}

# Se definen los métodos de clusters, son los mismos a los usados con hclust
method_list <- c("average", "complete", "ward.D2", "single")
run_all(matrix_dis = matrix_dis, FUN = hcut, k_max =  14, method_list = method_list)


# Vamos a sacar el agglomerative coeficient de todos nuestros arboles 

ag_coef_sin <- agnes(dissimilarity_matrix, method = "single")$ac
ag_coef_com <- agnes(dissimilarity_matrix, method = "complete")$ac
ag_coef_ave <- agnes(dissimilarity_matrix, method = "average")$ac
ag_coef_war <- agnes(dissimilarity_matrix, method = "ward")$ac

agglomerative_coeficient <- data.frame(Method = c("Single","Complete","Average","Ward's Method"), Coeficient = c(ag_coef_sin, ag_coef_com, ag_coef_ave, ag_coef_war))

agglomerative_coeficient

# Función para guardar todos los plots
save_all_plots <- function(output_dir = "results/plots", save = FALSE) {
  if (save == TRUE){
    # Crear directorio si no existe
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE)
    }
    
    plot_counter <- 1
    
    # 1. Plots de clustering jerárquico
    for (cluster in list(cluster_sin, cluster_com, cluster_ave, cluster_war)) {
      method_name <- c("single", "complete", "average", "ward")[match(cluster, list(cluster_sin, cluster_com, cluster_ave, cluster_war))]
      png(file.path(output_dir, paste0(sprintf("%02d", plot_counter), "_hclust_", method_name, ".png")), width = 11.25, height = 7.5, units = "in", res = 600)
      plot(cluster, hang = -1)
      dev.off()
      plot_counter <- plot_counter + 1
    }
    
    # 2. Tanglegrams (comparaciones de dendogramas)
    dends <- list(dendogram_1, dendogram_2, dendogram_3, dendogram_4)
    nombres <- c("Single", "Complete", "Average", "Ward")
    combos <- combn(1:4, 2)
    
    for (k in 1:ncol(combos)) {
      i <- combos[1, k]
      j <- combos[2, k]
      
      png(file.path(output_dir, paste0(sprintf("%02d", plot_counter), "_tanglegram_", nombres[i], "_vs_", nombres[j], ".png")), , width = 11.25, height = 7.5, units = "in", res = 600)
      tanglegram(dends[[i]], dends[[j]], 
                main = paste0(nombres[i], " vs ", nombres[j],
                            " | Entanglement: ",
                            round(entanglement(dendlist(dends[[i]], dends[[j]])), 3)))
      dev.off()
      plot_counter <- plot_counter + 1
    }
    
    # 3. Corrplot (Baker correlations)
    png(file.path(output_dir, paste0(sprintf("%02d", plot_counter), "_baker_correlations.png")), width = 11.25, height = 7.5, units = "in", res = 600)
    corrplot(baker,
            method = "circle",
            type = "lower",
            tl.col = "black",
            tl.cex = 1.0,
            cl.cex = 1.0,
            addCoef.col = "white",
            number.cex = 1.0,
            col.lim = c(0.0, 1),
            col = COL2("RdBu", n = 20))
    dev.off()
    plot_counter <- plot_counter + 1
    
    # 4. Optimal number of clusters plots
    method_list <- c("average", "complete", "ward.D2", "single")
    methods <- c("gap_stat", "wss", "silhouette")
    
    for (method in method_list) {
      for (m in methods) {
        plot <- fviz_nbclust(matrix_dis, FUN = hcut, hc_method = method, method = m, k.max = 14) +
          labs(subtitle = paste(method, "-", m))
        
        png(file.path(output_dir, paste0(sprintf("%02d", plot_counter), "_nbclust_", method, "_", m, ".png")), width = 11.25, height = 7.5, units = "in", res = 600)
        print(plot)
        dev.off()
        plot_counter <- plot_counter + 1
      }
    }
    
    cat("Todos los plots han sido guardados en:", output_dir, "\n")
    cat("Total de plots guardados:", plot_counter - 1, "\n")
  }
}

# Ejecutar la función
save_all_plots(save = TRUE)