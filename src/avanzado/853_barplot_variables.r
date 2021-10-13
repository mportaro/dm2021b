#####################################################################
# Ubicación de los FE en la jerarquía de variables
#####################################################################
# Armar un dataset con las importancias para cada variable en cada modelo
require("data.table")
require("stringr")
require("ggplot2")

setwd("~/buckets/b1/" )
experimento = 'E1027'

# Leo los archivos de importancias y los integro en un dataframe
files  <- list.files( pattern="[a-zA-Z0–9_]+imp_[0-9]+\\.txt", 
                      path=paste0("./work/", experimento, "/"), recursive = TRUE)

df.imp <- fread(paste0("./work/", experimento, "/", files[1]))
df.imp <- copy(df.imp[, c("Feature", "Gain")])
names(df.imp)[names(df.imp) == "Gain"] <- paste0(substr(files[1], 1, 5), "_", 
                                                 substr(str_extract(files[1], pattern = "_[0-9]+\\."), 2, 
                                                        nchar(str_extract(files[1], pattern = "_[0-9]+\\."))-1))
for(file in files[2:length(files)])
  #for(file in files[2:5])
{
  df <- fread(paste0("./work/", experimento, "/", file))
  df <- copy(df[, c("Feature", "Gain")])
  names(df)[names(df) == "Gain"] <- paste0(substr(file, 1, 5), "_", 
                                           substr(str_extract(file, pattern = "_[0-9]+\\."), 2, 
                                                  nchar(str_extract(file, pattern = "_[0-9]+\\."))-1))
  df.imp <- merge(df.imp, df, by=c("Feature"), all.y = TRUE)
}

# Calculo la media de las importancias para cada variable (en un campo al final del data frame)
df.imp$row.mean = rowMeans(df.imp[,c(-1)])

# Las ordeno de mayor a menor importancia
df.imp = df.imp[order(df.imp$row.mean, decreasing=TRUE)]
View(df.imp)
# Tomo sólo las primeras 15 variables
df.imp.15 = df.imp[1:15, ]
df.imp.15 = df.imp[order(df.imp.15$row.mean, decreasing=FALSE)]
var.list = df.imp[1:15, Feature]

# Simple Horizontal Bar Plot with Added Labels
# Uniform color
barplot(height=df.imp.15$row.mean, names=df.imp.15$Feature,
        col="#69b3a2",
        horiz=T, las=1, cex.axis = 0.6, cex.names = 0.6
)

# Basic barplot reorder(day, -perc)
ggplot(data=df.imp.15, aes(x=reorder(Feature, row.mean), y=row.mean)) +
  geom_bar(stat="identity", fill="steelblue") + xlab('Variables') + ylab("Promedio Importancia") + theme_minimal()+ coord_flip()
