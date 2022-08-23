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



# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("flatly"),

    # Application title
    navbarPage("Maritime Shipping Whale Sightings", id="main",
               tabPanel("Map", leafletOutput("map", height=875),
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 75, left = "auto", right = 20, bottom = "auto",
                                      width = 250, height = "auto",
                                      
                                      h2("Data explorer"),
                                      
                                      radioGroupButtons(
                                        inputId = "view_by",
                                        label = "View sightings by:",
                                        selected = T,
                                        justified = TRUE, status = "primary",
                                        choices = c("Species" = F, "Company" = T)
                                      ),
                                      
                                   
                                      
                        )),
               tabPanel("Data", DT::dataTableOutput("data"))
              # tabPanel("About",includeMarkdown("README.md"))
              )
)
)
