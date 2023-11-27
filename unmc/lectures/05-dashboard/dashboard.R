library(shiny)
library(shinydashboard)
library(plotly)

ui <- dashboardPage(
  dashboardHeader(title = "My Data Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("My control Center", tabName = "control", 
               icon = icon("dashboard")),
      menuItem("My county crime", tabName = "countyCrime", 
               icon = icon("th")),
      menuItem("My interactive map", tabName="map", icon= icon("air-freshener"))
    )
  ),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "control",
              fluidRow(
                box(plotOutput("myPlot", height = 250)),
                box(
                  title = "Controls",
                  sliderInput("slider", 
                              "Number of observations:", 1, 100, 50)
                )
              )
      ),
      # Second tab content
      tabItem(tabName = "countyCrime",
              h2("My county crime map goes here"),
              fluidRow(
                box(plotOutput("myMap"), height = 450, width=500)
              )              
      ),
      # Third tab content
      tabItem(tabName = "map",
              h2("USA interactive map goes here"),
              fluidRow(
                box(plotlyOutput("myUSA"), height = 450, width=500)
              ),
              verbatimTextOutput("click")
      )      
    )
  )
)

server <- function(input, output) {
  set.seed(122)
  histdata <- rnorm(1000)
  
  output$myPlot <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
  
  output$myMap <- renderPlot({
    crimes <- read.csv("omaha-crimes.csv")
    load("omaps.RData") #obtained using get_map()
    ggmap(omaps) +
      geom_point(size=5, alpha = 1/2, aes(lon,lat, color=type), 
                 data = crimes) 
  })
  
  output$myUSA <- renderPlotly({
    # specify some map projection/options
    g <- list(
      scope = 'usa',
      projection = list(type = 'albers usa'),
      lakecolor = toRGB('white')
    )
    plot_ly(z = state.area, text = state.name, locations = state.abb,
            type = 'choropleth', locationmode = 'USA-states') %>%
      layout(geo = g)
  })

  output$click <- renderPrint({
    d <- event_data("plotly_click")
    if (is.null(d)) "Click on a state to view event data" else d
  })  
  
}

shinyApp(ui, server)