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
shinyServer(function(input, output,session) {
  dataset_view(input,output) 
  observeEvent(input$dataset,{
    feature_selection_view(input,output)
    variables_histogram(input,output)
    feature_action(input,output)
    feature_action_view(input,output)
  })
  observeEvent(input$feature_selection,{
      selected_columns <<- list(input$feature_selection)
  })
  observeEvent(input$add_feature_action,{
      Processes <- input$feature_action_view
      column    <- input$feature_name
      action    <- input$feature_action
      value     <- input$feature_action_value
      record    <- paste0("##",column,">",action,">",value,"\n")
      updateTextAreaInput(session,"feature_action_view", label = "Your Processes are : ", value = paste(Processes,record), placeholder = NULL)
  })
})
######################################################################  View Dataset as table
dataset_view 	 <- function(input,output)
{
  output$dataset <- renderDataTable({
    df <- read_dataset(input,output)
    return(df)
  },options = list(scrollX = TRUE))
  
}
######################################################################  Read Uploaded Dataset
read_dataset 	 <- function(input,output)
{
  req(input$dataset)
  df           <- read.csv(input$dataset$datapath,header = input$header,sep = input$sep,quote = input$quote)
  dataset 		 <<- df
  return(df)
}
######################################################################  Variables Histogram
variables_histogram <- function(input,output)
{
  output$variables_histogram <- renderDataTable(head(dataset,5))
}
######################################################################  Selecting Features (Variables)
feature_selection_view   <- function(input,output)
{
  features          <- colnames(dataset)
  output$feature_selection <- renderUI({
    selectInput("feature_selection", 'Select Variables to work on', features, selected = NULL, multiple = TRUE,selectize = TRUE, width = NULL, size = NULL)
  })
}
######################################################################  Features (Variables) Actions
feature_action   <- function(input,output)
{
  features          <- colnames(dataset)
  output$feature_name <- renderUI({
    selectInput("feature_name", 'Select Variables to process', features, selected = NULL, multiple = FALSE,selectize = TRUE, width = NULL, size = NULL)
  })
  output$feature_action <- renderUI({
    selectInput("feature_action", 'Select Action to apply',c("fillna","dropna"), selected = NULL, multiple = FALSE,selectize = TRUE, width = NULL, size = NULL)
  })
  output$feature_action_value <- renderUI({
    selectInput("feature_action_value", 'Select Value to process', c("no value","mean","mode","median"), selected = NULL, multiple = FALSE,selectize = TRUE, width = NULL, size = NULL)
  })
}
######################################################################  Features (Variables) Actions
feature_action_view   <- function(input,output)
{
  output$feature_actions_view <- renderUI({
    textAreaInput("feature_action_view","Your Processes are : ", value = "", width = NULL, height = NULL, cols = NULL, rows = 11, placeholder = "Your Processes Appears here", resize = "none")
  })
}