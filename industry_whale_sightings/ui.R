#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
#library(here)
library(janitor)
library(tidyverse)
library(leaflet)
#library(tmap)
library(shinythemes)
library(sf)
library(shinyWidgets)
library(data.table)
library(DT)
library(rsconnect)

sightings_data <- read_csv("data/IndustrySightings_vsr_23.csv") %>% 
  clean_names()

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("flatly"),
       
       #Make background transparent for panel; hover to make bold again                     
                  tags$style("
        #controls {
          background-color: #FFFFFF;
          opacity: 0.75;
        }
        #controls:hover{
          opacity: 1;
        }
               "),

    # Application title
    navbarPage("Maritime Shipping Whale Sightings", id="nav",
               tabPanel(" Map", leafletOutput("map", height= 840),
                        icon = icon("map-location-dot"),
                        div(class="outer",
                            
                            tags$head(
                              # Include our custom CSS
                              tags$link(rel = "stylesheet", type = "text/css", href =  "styles.css"),
                              includeCSS("styles.css")
                            ),
                            
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 95, left = "auto", right = 40, bottom = "auto",
                                      width = 280, height = "auto",
                                      
                                      h2("  Data explorer"),
                                      
                                      radioGroupButtons(
                                        inputId = "view_by",
                                        label = "View sightings by:",
                                        selected = T,
                                        justified = TRUE, status = "primary",
                                        choices = c("Species" = F, "Company" = T)
                                      ),
                                      
                                      
                                      fluidRow(column(6, offset = 0,
                                                      checkboxGroupInput("co_select", "Select Company:",
                                                                         choices = unique(sightings_data$company),
                                                                         selected = c(sightings_data$company)),
                                                      
                                                      actionButton("selectall", label = "Select/Deselect All")),
                                               
                                               column(6, offset = 0,
                                                      checkboxGroupInput("sp_select", "Select Species:",
                                                                  choices = unique(sightings_data$species),
                                                                  selected = c(sightings_data$species)))),
                                      
                                      sliderInput("years", "Year",
                                                  min = 2018, max = 2023, step = 1,
                                                  value = c(2018, 2023), sep = ""),
                                    
                                     
                                      
                                   
                                      
                        ))),
               tabPanel("Data", 
                        icon = icon("pen-to-square"), 
                        DT::dataTableOutput("data")) ,
             #  tabPanel("About",includeMarkdown("/Users/anastasia/Desktop/NOAA/CMSF/IndustryWhaleSightings/About.Rmd"))
 
             
             
             tags$div(id = "cite", 'For questions contact anastasia.kunz@noaa.gov. 2022.')             
)

))
