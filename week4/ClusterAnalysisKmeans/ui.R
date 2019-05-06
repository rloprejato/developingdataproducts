#' CLuster Analysis with k-means
library(shiny)
shinyUI(fluidPage(
        titlePanel("Cluster Analysis with k-means"),
        sidebarLayout(
                sidebarPanel(
                        #textInput("fileurl", 
                        #          "Insert url to download data.csv", 
                        #          value= "https://archive.ics.uci.edu/ml/machine-learning-databases/00292/Wholesale%20customers%20data.csv"),
                        numericInput(
                                "n_out",
                                "Numbers of top value to eliminate",
                                value = 5,
                                min = 0,
                                max = 20,
                                step = 1
                        ),
                        checkboxInput("rescale", "Rescale variables", value = TRUE),
                        numericInput(
                                "kmin",
                                "Minimum number of clusters",
                                value = 2,
                                min = 2,
                                max = 20,
                                step = 1
                        ),
                        numericInput(
                                "kmax",
                                "Maximum number of clusters",
                                value = 20,
                                min = 3,
                                max = 20,
                                step = 1
                        ),
                        numericInput(
                                "cluster",
                                "Choose number of clusters",
                                value = 5,
                                min = 2,
                                max = 20,
                                step = 1
                        ),
                        submitButton("Submit")
                        
                        
                        
                ),
                mainPanel(
                        h4("The data for this analysis is available at the following link"),
                        textOutput("link"),
                        plotOutput("plot1"),
                        h3("Number of rows"),
                        textOutput("nrow"),
                        h2("Heatmap for the choosen number of clusters"),
                        plotOutput("plot2"),
                        h5("You can find the code and documentation for this ap at the link below"),
                        h6("https://github.com/rloprejato/developingdataproducts")
                )
        )
))