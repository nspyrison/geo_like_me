library(leaflet)

m <- leaflet() %>% 
  setView(lng = 145.0431, lat = -37.8773, zoom = 15) %>% 
  addTiles()
m

 
#You may already notice, the map is plotted in the “Viewer” tab instead of the normal “Plots” tab.
#This is because the leaflet R package is still using the leaflet javascript package and the “Viewer” tab is basically a small web browser.

#You can also customise your tile.
m %>% addProviderTiles("Stamen.Toner")

######


#Lets look at vet schools in victoria.
data <- read.csv("./fit5147_data/vet_schools_in_victoria.csv")
tibble::tibble(data)
summary(data)

#This data set has about 3k obs, lets consider the first 30 obs.
leaflet(data = data[1:30, ]) %>% addTiles() %>%
  addMarkers(~longitude, ~latitude, popup = ~as.character(location)) 
#Click on the markers, find out what’s the text about.

#What happens when we try the  whole data set?
leaflet(data = data) %>% addTiles() %>%
  addMarkers(~longitude, ~latitude, popup = ~as.character(location)) 
#That’s terrible…

#But our map is interactive, we should be able to cluster the data and allow the user to zoom into the details.
leaflet(data = data) %>% addTiles() %>%
  addMarkers(
    ~longitude, 
    ~latitude, 
    popup = ~as.character(location),
    clusterOptions = markerClusterOptions()
  )
# ahhh, much better!

#######

# Let's look at household heating, US 2009

data <- read.csv("./fit5147_data/Household-heating-by-State-2008.csv", header=T) 
names(data)[4] <- "MobileHomes"
ag <- aggregate(MobileHomes ~ States, FUN = mean, data = data)
ag$States <- tolower(ag$States)
#Let’s prepare the map data and link the two data sets.

library(maps)
mapStates <- map("state", fill = TRUE, plot = FALSE)
# find the related rate for each state
rates <- ag$MobileHomes[match(mapStates$names, ag$States)] 
#Now, it is time to use leaflet.

library(leaflet)
cpal <- colorNumeric("Reds", rates) # prepare the color mapping

run_dead_end <- F
if (run_dead_end){
  leaflet(mapStates) %>% # create a blank canvas
    addTiles() %>% # add tile
    addPolygons( # draw polygons on top of the base map (tile)
      stroke = FALSE, 
      smoothFactor = 0.2, 
      fillOpacity = 1,
      color = ~cpal(rates) # use the rate of each state to find the correct color
    ) 
  #You may also notice some parts are not colored.
  
  #Let’s check out why.
  mapStates$names
  ag$States
}

#Data processing again.
# split the string with : as seperator
spliteNames <- strsplit(mapStates$names, ":") 
# get first part of the origin string;
# e.g. get washington from washington:san juan island
firstPartNames <- lapply(spliteNames, function(x) x[1])  
rates <- ag$MobileHomes[match(firstPartNames, ag$States)]

leaflet(mapStates) %>% # create a blank canvas
  addTiles() %>% # add tile
  addPolygons( # draw polygons on top of the base map (tile)
    stroke = FALSE, 
    smoothFactor = 0.2, 
    fillOpacity = 1,
    color = ~cpal(rates) # use the rate of each state to find the correct color
  )


#####

# Let's look at GDP by country

library(rgdal)
world_map <- readOGR("./fit5147_data/ne_50m_admin_0_countries/ne_50m_admin_0_countries.shp")
gdp_data <- read.csv("./fit5147_data/WorldGDP.csv")

#Match the gdp to each country.
rates <- gdp_data$GDP[match(world_map$admin, gdp_data$Name)]
#Create the map

library(leaflet)
qpal <- colorQuantile("Reds", rates, 12) # prepare the color mapping

leaflet(world_map) %>% # create a blank canvas
  addTiles() %>% # add tile
  addPolygons( # draw polygons on top of the base map (tile)
    stroke = FALSE, 
    smoothFactor = 0.2, 
    fillOpacity = 1,
    color = ~qpal(rates) # use the rate of each state to find the correct color
  )

