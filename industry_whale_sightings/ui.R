#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(here)
library(janitor)
library(tidyverse)
library(leaflet)
library(tmap)
library(shinythemes)
library(sf)
library(sp)
library(shinyWidgets)

sightings_data <- read_csv(here("data","IndustrySightings_aggregate.csv")) %>% 
  clean_names()

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("flatly"),

    # Application title
    navbarPage("Maritime Shipping Whale Sightings", id="main",
               tabPanel("Map", leafletOutput("map", height=875),
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 80, left = "auto", right = 30, bottom = "auto",
                                      width = 275, height = "auto",
                                      
                                      h2("Data explorer"),
                                      
                                      radioGroupButtons(
                                        inputId = "view_by",
                                        label = "View sightings by:",
                                        selected = T,
                                        justified = TRUE, status = "primary",
                                        choices = c("Species" = F, "Company" = T)
                                      ),
                                      
                                      
                                      selectInput("co_select", "Filter by Company:",
                                                  choices = unique(sightings_data$company),
                                                  selectize = FALSE,
                                                  selected = c(sightings_data$company),
                                                  multiple = TRUE),
                                      
                                      selectInput("sp_select", "Filter by Species:",
                                                  choices = unique(sightings_data$species),
                                                  selectize = FALSE,
                                                  selected = c(sightings_data$species),
                                                  multiple = TRUE),
                                    
                                     
                                      
                                   
                                      
                        )),
               tabPanel("Data", DT::dataTableOutput("data"))
               #tabPanel("About",includeMarkdown("README.md"))
              )
)
)
