#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(here)
library(janitor)
library(sf)
library(sp)
library(tmap)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  ### Interactive Map ####
  
  
  # Load data
  sightings_data <- read_csv(here("data","IndustrySightings_aggregate.csv")) %>% 
    clean_names() %>% 
    st_as_sf(coords = c("long", "lat"))
  
  # Color palette
  pal <- colorFactor(pal = c("#0C6B02", "#94026D", "#0383C2", "#A0AFB7"), domain = c("Fin", "Humpback", "Blue", "Unidentified"))
   
  
  output$map <- renderLeaflet({
    leaflet(sightings_data) %>% 
      addTiles() %>%
      ### need to add data here!!! 
      addLayersControl(
        overlayGroups = c("blocks","vessels","nms","bia", "phones")
      )
  })
  
  #ceate a data object to display data
  
  output$data <-DT::renderDataTable(datatable(
    sightings_data[,c(-1,-23,-24,-25,-28:-35)],filter = 'top',
    colnames = c("Blood Bank Name", "State", "District", "City", "Address", "Pincode","Contact No.",
                 "Mobile","HelpLine","Fax","Email", "Website","Nodal Officer", "Contact of Nodal Officer",
                 "Mobile of Nodal Officer", "Email of Nodal Officer","Qualification", "Category", "Blood Component Available",
                 "Apheresis", "Service Time", "Lat", "Long.")
  ))

})
