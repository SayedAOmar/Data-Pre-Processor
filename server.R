library(shinydashboard)
library(data.table)
library(dplyr)
library(ggplot2)
library(gridExtra)
library('broom')
library(nloptr)
library(rpart)
library(caret)
options(shiny.maxRequestSize=30*1024^3)#limit 30MB
######################################################################  Server side processing ##############################################################
shinyServer(function(input, output) {
  dataset_view(input,output) 
})
######################################################################  View Dataset as table
dataset_view 	 <- function(input,output)
{
  output$dataset <- renderDataTable({
    df <- read_dataset(input,output)
    if(input$disp == "head") {
      return(df)
    }
    else {
      return(df)
    }
  },options = list(scrollX = TRUE))
  
}
######################################################################  Read Uploaded Dataset
read_dataset 	 <- function(input,output)
{
  req(input$dataset)
  df <- read.csv(input$dataset$datapath,
                 header = input$header,
                 sep    = input$sep,
                 quote  = input$quote)
  dataset 		 <<- df
  return(df)
}
