#
# Shiny Server Page

library(shiny)
library(here)
library(janitor)
library(tidyverse)
library(leaflet)
library(tmap)
library(shinythemes)
library(sf)
library(shinyWidgets)
library(data.table)
library(DT)
library(rsconnect)

# Load data
sightings_data <- read_csv(here("industry_whale_sightings", "data","IndustrySightings_vsr.csv")) %>% 
  clean_names()
cinms <- read_sf(here("industry_whale_sightings",  "data", "cinms_py2", "cinms_py.shp"))
mbnms <- read_sf(here("industry_whale_sightings",  "data", "mbnms_py2", "mbnms_py.shp"))
cbnms <- read_sf(here("industry_whale_sightings",  "data", "cbnms_py2", "CBNMS_py.shp"))
gfnms <- read_sf(here("industry_whale_sightings",  "data", "gfnms_py2", "GFNMS_py.shp"))
ocnms <- read_sf(here("industry_whale_sightings",  "data", "ocnms_py2", "ocnms_py.shp"))
ship_lanes <- read_sf(here("industry_whale_sightings",  "data", "shipping_lanes", "Offshore_Traffic_Separation.shp"))


# Define server logic 
shinyServer(function(input, output, session) {

  
  
  
  
  # new column for the popup label
  
  sightings_data <- mutate(sightings_data, cntnt=paste0(' <strong>Date: </strong> ', date,
                                                        ' <strong>Species Sighted: </strong> ', species,
                                                        ' <strong>Number Sighted: </strong> ', num_sighted,
                                                        ' <strong>Company: </strong> ', company,
                                                        ' <strong>Vessel: </strong> ', vessel,
                                                        ' <strong>Vessel Type: </strong> ', vessel_type,
                                                        ' <strong>Notes: </strong> ', notes)) 
  
  
  # Create color palettes for each data view
  species_pal <- colorFactor(pal = c("#00637C","#0C6B02", "#94026D", "#63666A"), domain = c("Humpback", "Blue", "Fin", "Unidentified"))

  company_pal <- colorFactor(pal = c("#c90076", "#c27ba0", "#6a329f", "#8e7cc3", "#16537e", "#6fa8dc", "#2986cc", "#76a5af", "#8fce00", "#38761d", "#ce7e00", "#f1c232", "#f44336", "#990000", "#744700"), domain = c("Evergreen", "K-Line", "MOL", "NYK", "MSC", "Maersk", "CMA CGM", "ONE", "Hapag Lloyd", "Matson", "Scot Gemi Isletmeciligi AS", "Eastern Pacific Shipping", "Wan Hai", "Andriaki Shipping Co", "APL"))
  
  ### Begin Interactive Map ####
  

  
# Reactivity expression for company, species, and year selection
  
 
  
  spco_reactive <- reactive({ 
    sightings_data %>%
      filter(company %in% c(input$co_select)) %>% 
      filter(species %in% c(input$sp_select)) %>% 
      filter(year %inrange% c(input$years))
  })
 
  observe({
    if (input$selectall > 0) {
      
      if (input$selectall %% 2 == 0) {
        updateCheckboxGroupInput(
          session = session,
          inputId = 'co_select',
          label = NULL,
          choices = unique(sightings_data$company),
          selected = c(sightings_data$company))
        
      } else {
        updateCheckboxGroupInput(session = session,
                                 inputId = 'co_select',
                                 label = NULL,
                                 choices = unique(sightings_data$company),
                                 selected = "")
      }}
  })
  #Create a reactive expression that returns either species or company view options
  
  observe({
    
    leafletProxy("map", data = spco_reactive) %>% 
      clearMarkers() %>% 
      clearControls()
    
    proxy <- leafletProxy("map", data = spco_reactive)
    
    view_by <- input$view_by
    
    if (view_by){
      view_by <- "Company"
      proxy %>%
        addCircleMarkers(data = spco_reactive(), ~long, ~lat,
                         color = ~company_pal(company),
                         radius = ~num_sighted,
                         popup = ~as.character(cntnt),
                         stroke = FALSE, fillOpacity = 0.8) %>% 
        addLegend("bottomright",
                  pal = company_pal,
                  values = sightings_data$company,
                  title = "Company",
                  opacity = 1)
    } else {
      view_by <- "Species"
      proxy %>% 
        addCircleMarkers(data = spco_reactive(), ~long, ~lat,
                         color = ~species_pal(species),
                         radius = ~num_sighted,
                         popup = ~as.character(cntnt),
                         stroke = FALSE, fillOpacity = 0.8) %>% 
        addLegend("bottomright",
                  pal = species_pal,
                  values = sightings_data$species,
                  title = "Species",
                  opacity = 1)
    }
    
    
  })
  

  # Create basemap
  
  output$map <- renderLeaflet({   
    leaflet() %>% 
      addTiles() %>%
      setView( lng = -119, lat = 38, zoom = 5) %>% 
      addPolygons(data = cinms, group = "National Marine Sanctuaries", fillColor = "darkcyan", weight = 2, color = "darkcyan") %>%
      addPolygons(data = mbnms, group = "National Marine Sanctuaries", fillColor = "darkcyan", weight = 2, color = "darkcyan") %>%
      addPolygons(data = ship_lanes, group = "Vessel Traffic Separation Zones", fillColor = "light teal", weight = 2, color = "blue") %>%
      addPolygons(data = cbnms, group = "National Marine Sanctuaries", fillColor = "darkcyan", weight = 2, color = "darkcyan") %>%
      addPolygons(data = gfnms, group = "National Marine Sanctuaries", fillColor = "darkcyan", weight = 2, color = "darkcyan") %>%
      addPolygons(data = ocnms, group = "National Marine Sanctuaries", fillColor = "darkcyan", weight = 2, color = "darkcyan") %>%
      hideGroup("National Marine Sanctuaries") %>% 
    hideGroup("Vessel Traffic Separation Zones") %>% 
      addLayersControl(
        overlayGroups = c("National Marine Sanctuaries", "Vessel Traffic Separation Zones")
      )

  })
  

  #### End Interactive Map ###
  
  
  
  ### Begin Data Table ###

  
  output$data <-DT::renderDataTable(datatable(
    sightings_data[,c(1,3,4,5,6, 7,8,12)],filter = 'top',
    colnames = c("Date", "Company", "Vessel", "Vessel Type", "Data Collector", "Species","Number Sited", "Notes"),
    style = "auto",
    rownames = TRUE
  ))
  
  })



 

### End Data Table ###