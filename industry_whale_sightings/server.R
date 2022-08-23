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
    clean_names()
  
  # Create color palette
  species_pal <- colorFactor(pal = c("#0C6B02", "#94026D", "#0383C2", "#A0AFB7"), domain = c("Fin", "Humpback", "Blue", "Unidentified"))

  company_pal <- colorFactor(pal = c("#c90076", "#c27ba0", "#6a329f", "#8e7cc3", "#16537e", "#6fa8dc", "#2986cc", "#76a5af", "#8fce00", "#38761d", "#ce7e00", "#f1c232", "#f44336", "#990000", "#744700"), domain = c("Evergreen", "K-Line", "MOL", "NYK", "MSC", "Maersk", "CMA CGM", "ONE", "Hapag Lloyd", "Matson", "Scot Gemi Isletmeciligi AS", "Eastern Pacific Shipping", "Wan Hai", "Andriaki Shipping Co", "APL"))
  
  # begin map
  
  output$map <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>%
      setView( lng = -119, lat = 38, zoom = 5) # %>%
     # addCircleMarkers(data = sightings_data,  ~long, ~lat, 
                       #size = , 
                    #   radius = 3,
                    #   color = ~species_pal(species),
                     #  stroke = FALSE, fillOpacity = 0.8)
  })
  
 #Create a reactive exp that returns either species or company
view_by <- input$view_by

proxy <- leafletProxy("map")
  
 observe({
   leafletProxy("map", data = sightings_data) %>% 
     clearMarkers()  
   
   proxy %>% 
     if (input$view_by == "Species") {
       addCircleMarkers(data = sightings_data, ~long, ~lat,
                        color = ~species_pal(species),
                        radius = ~num_sighted, 
                        stroke = FALSE, fillOpacity = 0.8) 
       }
   else (input$view_by == "Company") {
     addCircleMarkers(data = sightings_data, ~long, ~lat,
                      color = ~company_pal(company),
                      radius = ~num_sighted, 
                      stroke = FALSE, fillOpacity = 0.8) 
     }
   }) 
 })


#ceate a data object to display data --- NEED TO CHANGE FOR DATA PAGE this goes above the }) right above this

# output$data <-DT::renderDataTable(datatable(
#   sightings_data[,c(-1,-23,-24,-25,-28:-35)],filter = 'top',
#   colnames = c("Blood Bank Name", "State", "District", "City", "Address", "Pincode","Contact No.",
#               "Mobile","HelpLine","Fax","Email", "Website","Nodal Officer", "Contact of Nodal Officer",
#              "Mobile of Nodal Officer", "Email of Nodal Officer","Qualification", "Category", "Blood Component Available",
#              "Apheresis", "Service Time", "Lat", "Long.")
# ))

##### end data page