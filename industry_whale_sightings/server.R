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
shinyServer(function(input, output, session) {

  
  ### Interactive Map ####
  
  # Load data
  sightings_data <- read_csv(here("data","IndustrySightings_aggregate.csv")) %>% 
    clean_names()
  cinms <- read_sf(here( "data", "cinms_py2", "cinms_py.shp"))
  mbnms <- read_sf(here( "data", "mbnms_py2", "mbnms_py.shp"))
  ship_lanes <- read_sf(here("data", "shipping_lanes", "Offshore_Traffic_Separation.shp"))
  
  # Create color palette
  species_pal <- colorFactor(pal = c("#0C6B02", "#94026D", "#00637C", "#63666A"), domain = c("Fin", "Humpback", "Blue", "Unidentified"))

  company_pal <- colorFactor(pal = c("#c90076", "#c27ba0", "#6a329f", "#8e7cc3", "#16537e", "#6fa8dc", "#2986cc", "#76a5af", "#8fce00", "#38761d", "#ce7e00", "#f1c232", "#f44336", "#990000", "#744700"), domain = c("Evergreen", "K-Line", "MOL", "NYK", "MSC", "Maersk", "CMA CGM", "ONE", "Hapag Lloyd", "Matson", "Scot Gemi Isletmeciligi AS", "Eastern Pacific Shipping", "Wan Hai", "Andriaki Shipping Co", "APL"))
  
  # create basemap
  
  output$map <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>%
      setView( lng = -119, lat = 38, zoom = 5) %>% 
      addPolygons(data = cinms, group = "National Marine Sanctuaries", fillColor = "aquamarine") %>%
      addPolygons(data = mbnms, group = "National Marine Sanctuaries", fillColor = "chartreuse") %>%
      addPolygons(data = ship_lanes, group = "Shipping Lanes", fillColor = "teal") %>%
      hideGroup("National Marine Sanctuaries") %>% hideGroup("Shipping Lanes") %>% 
      addLayersControl(
        overlayGroups = c("National Marine Sanctuaries", "Shipping Lanes")
      )

  })
  
  
 #Create a reactive exp that returns either species or company

  
  observe({
    leafletProxy("map", data = sightings_data) %>% 
      clearMarkers()
    
    proxy <- leafletProxy("map")
    
    view_by <- input$view_by
    
      if (view_by){
        view_by <- "Company"
        proxy %>%
          addCircleMarkers(data = sightings_data, ~long, ~lat,
                           color = ~company_pal(company),
                           radius = ~num_sighted, 
                           stroke = FALSE, fillOpacity = 0.8)
        } else {
          view_by <- "Species"
          proxy %>% 
            addCircleMarkers(data = sightings_data, ~long, ~lat,
                             color = ~species_pal(species),
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