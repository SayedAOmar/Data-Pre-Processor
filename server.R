library(shinydashboard)
library(data.table)
library(dplyr)
library(ggplot2)
library(gridExtra)
library('broom')
library(Hmisc)
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
    selected_features  <<- input$feature_selection
    feature_action(input,output)
  })
  observeEvent(input$add_feature_action,{
      Processes <- input$feature_action_view
      column    <- input$feature_name
      action    <- input$feature_action
      value     <- input$feature_action_value
      record    <- paste0("##",column,">",action,">",value)
      updateTextAreaInput(session,"feature_action_view", label = "Your Processes are : ", value = paste(Processes,record), placeholder = NULL)
  })
  observeEvent(input$apply_config,{
      apply_config(input,output)
      apply_config_message(input,output,session)
  })
  observeEvent(input$feature_name,{
    output$feature_action_value <- renderUI({
      if(class(dataset[[input$feature_name]]) == "numeric" | class(dataset[[input$feature_name]]) == "integer" | class(dataset[[input$feature_name]]) == "logical")
      {
        selectInput("feature_action_value", 'Select Value to process', c("no value","zero","mean","mode","median"), selected = NULL, multiple = FALSE,selectize = TRUE, width = NULL, size = NULL)
      }
      else
      {
        selectInput("feature_action_value", 'Select Value to process', c("no value","zero","mode"), selected = NULL, multiple = FALSE,selectize = TRUE, width = NULL, size = NULL)
      }
    })
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
  dataset      <<- df
  selected_features  <<- colnames(df)
  return(df)
}
######################################################################  Variables Histogram
variables_histogram           <- function(input,output)
{
  output$variables_histogram  <- renderDataTable(head(dataset,5))
}
######################################################################  Selecting Features (Variables)
feature_selection_view      <- function(input,output)
{
  features                  <- colnames(dataset)
  output$feature_selection  <- renderUI({
    selectInput("feature_selection", 'Select Variables to work on', features, selected = NULL, multiple = TRUE,selectize = TRUE, width = NULL, size = NULL)
  })
}
######################################################################  Features (Variables) Actions
feature_action                <- function(input,output)
{
  features                    <- selected_features
  output$feature_name         <- renderUI({
    selectInput("feature_name", 'Select Variables to process', features, selected = NULL, multiple = FALSE,selectize = TRUE, width = NULL, size = NULL)
  })
  output$feature_action       <- renderUI({
    selectInput("feature_action", 'Select Action to apply',c("fillna","dropna"), selected = NULL, multiple = FALSE,selectize = TRUE, width = NULL, size = NULL)
  })
}
######################################################################  Features (Variables) Actions
feature_action_view           <- function(input,output)
{
  output$feature_actions_view <- renderUI({
    textAreaInput("feature_action_view","Your Processes are : ", value = "", width = NULL, height = NULL, cols = NULL, rows = 11, placeholder = "Your Processes Appears here", resize = "none")
  })
}
######################################################################  Apply configuration Message
apply_config_message    <- function(input,output,session)
{
  raw_config            <- input$feature_action_view
  if (raw_config == "")
  {
    raw_message         <- "You didn't select any action to apply"
  }
  else
  {
    raw_message         <- "your selected actions will be applied ..."
  }
  if (length(input$feature_selection)<1)
  {
    selected_message    <- "You didn't select features"
  }
  else 
  {
    selected_message    <- paste( unlist(input$feature_selection), collapse=', ')
    selected_message    <- paste0(" Your Selected Features are [ ",selected_message," ] ")
  }
  message               <- paste0(selected_message,", and ",raw_message)
  updateTextAreaInput(session,"feature_action_view", label = "Your Processes are : ", value = "", placeholder = NULL)
  feature_selection_view(input,output)
  feature_action(input,output)
  showModal(modalDialog(
      title     = "Configuration",
      message,
      easyClose = TRUE,
      footer    = NULL
  ))
}
######################################################################  Apply Configuration
apply_config              <- function(input,output)
{
  raw_config              <- input$feature_action_view
  if (length(input$feature_selection)>0)
  {
    dataset               <<- dataset[,input$feature_selection]
  }
  if (raw_config != "")
  {
    new_raw               <- unlist(strsplit(raw_config,"##"))
    for(row in new_raw)
    {
      if(row !=" ")
      {
        new_row           <- unlist(strsplit(row,">"))
        column            <- new_row[1]
        action            <- new_row[2]
        value             <- new_row[3]
        col_class         <- class(dataset[[column]])
        if(action == "fillna")
        {
          if(value == "median" | value == "median ")
          {
              value           <- median(dataset[[column]],na.rm=TRUE)
          }
          else if(value == "mean" | value == "mean ")
          {
              value           <- mean(dataset[[column]],na.rm=TRUE)
          }
          else if(value == "mode" | value == "mode ")
          {
            uniq            <- unique(dataset[[column]])
            value           <- uniq[which.max(tabulate(match(dataset[[column]], uniq)))]
          }
          else if(value == "zero" | value == "zero ")
          {
            value           <- 0
          }
          else if (value == "no value" | value =="no value ")
          {
            value           <- ""
          }
          if(value != "")
          {
            dataset[[column]][is.na(dataset[[column]])] <- value
          }
        }
        else if (action == "dropna")
        {
          # Drop column or row goes here 
        }
      }
    }
  }
}
