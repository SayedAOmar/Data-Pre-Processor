library(shinydashboard)
######################################################################  Header Component ##############################################################
header <- dashboardHeader(title = "Churnless")
#header$children[[2]]$children <-  tags$img(src='http://www.analyticspatrols.com/wp-content/uploads/2017/12/AnalyticsPatrols-Logo.jpg',height='55',width='200')
######################################################################  Sidebar Component #############################################################
sidebar <-dashboardSidebar(
  collapsed = FALSE,
  sidebarMenu(
    menuItem("Upload Dataset", icon = icon("upload"), tabName = "upload"),
    menuItem("Processing", tabName = "config", icon = icon("gear"))
  ),
  tags$img(src='http://www.analyticspatrols.com/wp-content/uploads/2017/12/AnalyticsPatrols-Logo.jpg',height='55',width='200', class="logo_bottom"),
  tags$style(type='text/css', ".logo_bottom { position:fixed;bottom:0px;left:0px;width:230px; }")
)
######################################################################  Body Component ##############################################################
body <- dashboardBody(
  tabItems(
    tabItem(
      tabName = "upload",
      fluidRow(
        box(
          width         = 12,
          title         = "Upload Dataset",
          status        = "success",
          solidHeader   = TRUE,
          collapsible   = TRUE,
          fileInput("dataset", "Choose file",
                    multiple = FALSE,
                    accept = c("text/csv",
                               "text/comma-separated-values",
                               ".csv")
          )
        )
      ),
      fluidRow(
        box(
          width       = 4,
          checkboxInput("header", "Header", TRUE),
          radioButtons("disp", "Display",
                       choices = c(Head  = "head",
                                   All   = "all"),
                       selected = "head")
        ),
        box(
          width       = 4,
          radioButtons("sep", "Separator",
                       choices = c(Comma     = ",",
                                   Semicolon = ";",
                                   Tab       = "\t"),
                       selected = ",")
        ),
        box(
          width       = 4 ,
          radioButtons("quote", "Quote",
                       choices = c(None           = "",
                                   "Double Quote" = '"',
                                   "Single Quote" = "'"),
                       selected = '"')
        )
      ),
      ## View the Uploaded Dataset
      fluidRow(
        box(
          width         = 12,
          title         = "Uploaded Dataset",
          status        = "success",
          solidHeader   = TRUE,
          collapsible   = TRUE,
          column(
            width       = 12,
            dataTableOutput("dataset")
          )
        )
      )
    ),
    tabItem(
      tabName = "config",
      fluidRow(
        
        box(
          width         = 4,
          height   	  = 460,
          title         = "Historical Churn Rate",
          status        = "success",
          solidHeader   = TRUE,
          collapsible   = TRUE,
          uiOutput('churn_rate')
        )
      )
    )
  )
)
######################################################################  Combin all parts together ###########################################################
ui <- dashboardPage(header,sidebar,body,skin = "green")
######################################################################  Run UI ##############################################################################
shinyUI(ui)

