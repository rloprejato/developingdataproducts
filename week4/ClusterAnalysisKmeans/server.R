#' CLuster Analysis with k-means
library(shiny)
library(ggplot2);library(dplyr);library(tidyr);library(RColorBrewer);

#' function - eliminate top N customers
top.n.custs <- function (data,cols,n=5) {
        idx.to.remove <-integer(0)
        for (c in cols){
                col.order <-order(data[,c],decreasing=T) 
                idx <-head(col.order, n)
                idx.to.remove <-union(idx.to.remove,idx)
        }
        return(idx.to.remove)
}

#' function - create df with total within SS by Varius K
avg.totw.ss <- function(data, kmin=2, kmax=20){
        
        rng<-kmin:kmax
        tries <-100
        avg.totw.ss <-integer(length(rng))
        for(v in rng){ 
                v.totw.ss <-integer(tries)
                for(i in 1:tries){
                        k.temp <-kmeans(data,centers=v)
                        v.totw.ss[i] <-k.temp$tot.withinss
                }
                avg.totw.ss[v-(kmin-1)] <-mean(v.totw.ss)
        }
        return(data.frame(rng = rng, avg.totw.ss = avg.totw.ss ))
}

# Create the palette for heatmap
hm.palette <-colorRampPalette(rev(brewer.pal(10, 'RdYlGn')),space='Lab')

#'Load data from the Berkley UCI Machine Learning Repository
fileurl <- "https://archive.ics.uci.edu/ml/machine-learning-databases/00292/Wholesale%20customers%20data.csv"
download.file(fileurl, destfile = "Wholesale customers data.csv")
dataset <- read.csv("Wholesale customers data.csv",header=T)

shinyServer(function(input, output) {
set.seed(12345)
output$link <- renderText({link <- fileurl})        
        
#'check the checkboxInput - outliers
output$plot1 <- renderPlot({

top.custs <- top.n.custs(data = dataset,cols=3:8,n=input$n_out)
length(top.custs)
data.rm.top<-dataset[-c(top.custs),]

output$nrow <- renderText({nrow <- dim(data.rm.top)[1]})

if(input$rescale) {
        rescale_df <- data.rm.top %>%
                mutate(Fresh_scal = scale(Fresh),
                       Milk_scal = scale(Milk),
                       Grocery_scal = scale(Grocery),
                       Frozen_scal = scale(Frozen),
                       Detergents_Paper_scal = scale(Detergents_Paper),
                       Delicassen_scal = scale(Delicassen)) %>%
                select(-c(1:8))
} else{rescale_df <- data.rm.top}

#'It’s important to try other values for K
df_SS <- avg.totw.ss(rescale_df, input$kmin, input$kmax)


plot(df_SS$rng,df_SS$avg.totw.ss,type="b", main="Total Within SS by Various K",
     ylab="Average Total Within Sum of Squares",
     xlab="Value of K")
})

output$plot2 <- renderPlot({
        
        top.custs <- top.n.custs(data = dataset,cols=3:8,n=input$n_out)
        length(top.custs)
        data.rm.top<-dataset[-c(top.custs),]
        
        if(input$rescale) {
                rescale_df <- data.rm.top %>%
                        mutate(Fresh_scal = scale(Fresh),
                               Milk_scal = scale(Milk),
                               Grocery_scal = scale(Grocery),
                               Frozen_scal = scale(Frozen),
                               Detergents_Paper_scal = scale(Detergents_Paper),
                               Delicassen_scal = scale(Delicassen)) %>%
                        select(-c(1:8))
        } else{rescale_df <- data.rm.top}
                
        k <-kmeans(rescale_df, centers=input$cluster)
        center <- k$centers
        cluster <- c(1:input$cluster)
        center_df <- data.frame(cluster, center)
        center_reshape <- gather(center_df, features, values, Fresh_scal:Delicassen_scal)
        
        ggplot(data = center_reshape, aes(x = features, y = cluster, fill = values)) +
                scale_y_continuous(breaks = seq(1, 7, by = 1)) +
                geom_tile() +
                coord_equal() +
                scale_fill_gradientn(colours = hm.palette(90)) +
                theme_classic()
})

})