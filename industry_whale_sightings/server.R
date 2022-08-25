#
# Shiny Server Page

library(shiny)
library(tidyverse)
library(here)
library(janitor)
library(sf)
library(sp)
library(tmap)
library(DT)

# Define server logic 
shinyServer(function(input, output, session) {

  
  ### Interactive Map ####
  
  # Load data
  sightings_data <- read_csv(here("data","IndustrySightings_aggregate.csv")) %>% 
    clean_names()
  cinms <- read_sf(here( "data", "cinms_py2", "cinms_py.shp"))
  mbnms <- read_sf(here( "data", "mbnms_py2", "mbnms_py.shp"))
  ship_lanes <- read_sf(here("data", "shipping_lanes", "Offshore_Traffic_Separation.shp"))
  
  # new column for the popup label
  
  sightings_data <- mutate(sightings_data, cntnt=paste0(' <strong>Date: </strong> ', date,
                                                        ' <strong>Species Sighted: </strong> ', species,
                                                        ' <strong>Number Sighted: </strong> ', num_sighted,
                                                        ' <strong>Company: </strong> ', company,
                                                        ' <strong>Vessel: </strong> ', vessel,
                                                        ' <strong>Vessel Type: </strong> ', vessel_type,
                                                        ' <strong>Notes: </strong> ', notes)) 
  
  
  # Create color palettes for each data view
  species_pal <- colorFactor(pal = c("#0C6B02", "#94026D", "#00637C", "#63666A"), domain = c("Fin", "Humpback", "Blue", "Unidentified"))

  company_pal <- colorFactor(pal = c("#c90076", "#c27ba0", "#6a329f", "#8e7cc3", "#16537e", "#6fa8dc", "#2986cc", "#76a5af", "#8fce00", "#38761d", "#ce7e00", "#f1c232", "#f44336", "#990000", "#744700"), domain = c("Evergreen", "K-Line", "MOL", "NYK", "MSC", "Maersk", "CMA CGM", "ONE", "Hapag Lloyd", "Matson", "Scot Gemi Isletmeciligi AS", "Eastern Pacific Shipping", "Wan Hai", "Andriaki Shipping Co", "APL"))
  

  spco_reactive <- reactive({ 
    sightings_data %>%
      filter(company %in% c(input$co_select)) %>% 
      filter(species %in% c(input$sp_select))
  })
  
  # Create basemap
  
  output$map <- renderLeaflet({   
    leaflet() %>% 
      addTiles() %>%
      setView( lng = -119, lat = 38, zoom = 5) %>% 
      addPolygons(data = cinms, group = "National Marine Sanctuaries", fillColor = "aquamarine") %>%
      addPolygons(data = mbnms, group = "National Marine Sanctuaries", fillColor = "chartreuse") %>%
      addPolygons(data = ship_lanes, group = "Shipping Lanes", fillColor = "light teal") %>%
      hideGroup("National Marine Sanctuaries") %>% hideGroup("Shipping Lanes") %>% 
      addLayersControl(
        overlayGroups = c("National Marine Sanctuaries", "Shipping Lanes")
      )
  })
  
  
 #Create a reactive expression that returns either species or company view options
  
  observe({

    leafletProxy("map", data = spco_reactive) %>% 
      clearMarkers() 
    
    proxy <- leafletProxy("map", data = spco_reactive)
    
    view_by <- input$view_by
    
      if (view_by){
        view_by <- "Company"
        proxy %>%
          addCircleMarkers(data = spco_reactive(), ~long, ~lat,
                           color = ~company_pal(company),
                           radius = ~num_sighted,
                           popup = ~as.character(cntnt),
                           stroke = FALSE, fillOpacity = 0.8)
        } else {
          view_by <- "Species"
          proxy %>% 
            addCircleMarkers(data = spco_reactive(), ~long, ~lat,
                             color = ~species_pal(species),
                             radius = ~num_sighted,
                             popup = ~as.character(cntnt),
                             stroke = FALSE, fillOpacity = 0.8)
        }

    
    })
  
  output$data <-DT::renderDataTable(datatable(
    sightings_data[,c(1,3,4,5,6, 7,8,12)],filter = 'top',
    colnames = c("Date", "Company", "Vessel", "Vessel Type", "Data Collector", "Species","Number Sited", "Notes")
  ))
  
  })


#ceate a data object to display data --- NEED TO CHANGE FOR DATA PAGE this goes above the }) right above this

 

##### end data page