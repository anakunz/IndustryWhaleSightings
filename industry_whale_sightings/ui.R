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




# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("spacelab"),

    # Application title
    navbarPage("Maritime Shipping Whale Sightings", id="main",
               tabPanel("Map", leafletOutput("bbmap", height=1000)),
               tabPanel("Data", DT::dataTableOutput("data")),
               tabPanel("About",includeMarkdown("readme.md")))
)
)
