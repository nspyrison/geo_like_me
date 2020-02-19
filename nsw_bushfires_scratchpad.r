### NS numbast hackathon scratchpad
cat("R map packages include 'leaflet', 'ggmap', 'RgoogleMaps', 'mapsapi'")
cat("after breif review of websites, will focus on leaflet and ggmap first.")

if (F){
  install.packages('leaflet')
  install.packages('ggmap')
}

### LEAFLET -----
library('leaflet') 
browseURL("https://rstudio.github.io/leaflet/")

# _Eample 1 -----
m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
m  # Print the map

# without pipes
m <- leaflet()
m <- addTiles(m)
m <- addMarkers(m, lng=174.768, lat=-36.852, popup="The birthplace of R")
m

cap("interactive, no API, pan, zoom, and works in shiny. I am mostly sold already.")



### _NSW bushfires init -----
#NSW: (-)31.2532? S, 146.9211? E
m2 <- addTiles(leaflet()) # default map view
m2 <- setView(m2, lng = 147, lat = -36, zoom = 6)
m2 <- addMarkers(m2, lng = 147, lat = -36, popup = "center of the map")
fire_icon <- awesomeIcons(icon = "fire", library = "glyphicon", markerColor = "red")
## library expects c("glyphicon", "ion", "fa")
(m2 <- addAwesomeMarkers(m2, lng = 146, lat = -36, icon = fire_icon, 
                         popup = "Stays when clicked!", label = "Tooltip on hover!"))
(m2 <- addAwesomeMarkers(m2, lng = c(143, 144, 145), lat = rep(-37, 3), icon = fire_icon, 
                        popup = "Stays when clicked!",            # single value 
                        label = paste0("Tooltip on hover!",1:3))) # or length of data.





?awesomeIcons
cat("this site has a table of fires, lets grab with copypasta!")
browseURL("https://www.rfs.nsw.gov.au/fire-information/fires-near-me")

if (F){
  cat("following datapasta instructions:")
  browseURL("https://github.com/milesmcbain/datapasta#installation")
  install.packages("datapasta")
  cat("now go to rStudio options to set a default:
  Tools -> Addins -> Browse Addins, then click Keyboard Shortcuts...
      set your favorite format to cntl + shift + t (cntl + capital T")
  cat("ok, tribble errored, and data.frame didn't work well. C+P into excel wroked well, read from excel .csv...")
}

cat("After data cleaned a bit; read and first map")
dat <- read.csv2("./nsw_fires_clean.csv", sep = ",", stringsAsFactors = F)
str(dat)
cat("no lat long! Yuck! geocoding in ggmap needs api...")

ggmap::geocode(dat$Location[1])


  


### GGMAP -----
library('ggmap')
