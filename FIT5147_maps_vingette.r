library(maps) 
map("nz")# what a cute country
#Location, location, location
#Here, we are going to introduce 3 different ways to define a location in ggmap.

####
library(ggmap)# load ggmap

# Define location 3 ways
# 1. location/address
myLocation1 <- "Melbourne"
myLocation1

# 2. lat/long
myLocation2 <- c(lon=-95.3632715, lat=29.7632836)# not "Melbourne"
myLocation2

# 3. an area or bounding box (4 points), lower left lon, 
# lower left lat, upper right lon, upper right lat
# (a little glitchy for google maps)
myLocation3 <- c(-130, 30, -105, 50)
myLocation3

library(tmaptools)
# Convert location/address to its lat/long coordinates:
geocode_OSM("Melbourne")
# Yes, Melbourne is where it's supposed to be in, in Australia
# longitude 144.96316
# latitude -37.81422

# or help(get_stamenmap) 
# also try ?get_googlemap, ?get_openstreetmap and ?get_cloudmademap
#####
?get_stamenmap 
place <- "rio de janeiro"
bbox <- c(left = -97.1268, bottom = 31.536245, right = -97.099334, top = 31.559652)
google <- get_stamenmap(bbox = bbox)
ggmap(google)

bbox <- bb2bbox(attr(google, "bb"))

get_stamenmap(bbox, zoom = 12,maptype = "terrain")            %>% ggmap()
get_stamenmap(bbox, zoom = 12,maptype = "terrain-background") %>% ggmap()
get_stamenmap(bbox, zoom = 12,maptype = "terrain-labels")     %>% ggmap()
get_stamenmap(bbox, zoom = 12,maptype = "terrain-lines")      %>% ggmap()
get_stamenmap(bbox, zoom = 12,maptype = "toner")              %>% ggmap()
get_stamenmap(bbox, zoom = 12,maptype = "toner-2010")         %>% ggmap()
get_stamenmap(bbox, zoom = 12,maptype = "toner-2011")         %>% ggmap()
get_stamenmap(bbox, zoom = 12,maptype = "toner-background")   %>% ggmap()
get_stamenmap(bbox, zoom = 12,maptype = "toner-hybrid")       %>% ggmap()
get_stamenmap(bbox, zoom = 12,maptype = "toner-labels")       %>% ggmap()
get_stamenmap(bbox, zoom = 12,maptype = "toner-lines")        %>% ggmap()
get_stamenmap(bbox, zoom = 12,maptype = "toner-lite")         %>% ggmap()
get_stamenmap(bbox, zoom = 12,maptype = "watercolor")         %>% ggmap()
####

myLocation4 <- geocode_OSM("Melbourne")
bboxVector <- as.vector(myLocation4$bbox)

bbox1 <- c(
  left = bboxVector[1], 
  bottom = bboxVector[2], 
  right = bboxVector[3], 
  top = bboxVector[4]
)

myMap <- get_stamenmap(
  bbox = bbox1, 
  maptype = "watercolor",
  zoom = 13
)
ggmap(myMap)


##### Different projection types

require(mapproj)
# get map data (lat &amp;amp; lon for boundaries in this case)
m <- map("usa", plot = FALSE) 

map(m, project = "mercator") # try mercator first
map.grid(m) # draw graticules

# change the projection to albers
map(m, project = "albers", par=c(39,45))
map.grid(m) # draw graticules to compare more easily
#####

# get unprojected world limits
m <- map('world', plot = FALSE)
# center on New York
map(m, proj = 'azequalarea', orient = c(41,-74,0))
map.grid(m, col = 2) # draw graticules

###
map(m, proj = 'orth', orient = c(41,-74,0))
map.grid(m, col = 2, nx = 6, ny = 5, label = FALSE, lty = 2)
points(
  mapproject(
    list(y = 41, x = -74)
  ),
  col = 3,
  pch = "x",
  cex = 2
)# centre on NY
###
map("state", proj='bonne', param=45)
data(state)
text(
  mapproject(
    state.center
  ),
  state.abb
)
###You may also want to try:
  
  map("state", proj = 'bonne', param = 45)
text(
  mapproject(
    state.center,
    proj = 'bonne',
    param = 45
  ),
  state.abb
)

###Let's look at the data first. We are going to use the ggmap built-in data set crime.

help(crime)
head(crime)
dim(crime)
tibble::tibble(crime)
summary(crime)
###This data set is pretty large, here, we will choose a subset from it and plot.

murder <- subset(crime, offense == "murder")
qmplot(lon, lat, 
       data = murder, 
       colour = I('red'),
       size = I(3),
       darken = .3
)

####
help(unemp)
head(unemp)
summary(unemp)
tibble::tibble(unemp)

help(county.fips)
head(county.fips)
#Let's pre-processing the data.

# We want to split the unemployed rate into 7 intervals ("<2%","2-4%","4-6%","6-8%","8-10%",">10%").

# use the version installed with maps library!
data(unemp)

# set up intervals
Intervals <- as.numeric(
  cut(
    unemp$unemp,
    c(0,2,4,6,8,10,100)
  )
)

###
# Then we need to match unemployment data to map regions by fips codes.

data(county.fips)
Matches <- Intervals[
  match(
    county.fips$fips,
    unemp$fips
  )
  ]
# After that, we can prepare the colour schema and plot the map.

colors <- c("#ffffd4","#fee391","#fec44f","#fe9929","#d95f0e","#993404")
# draw map
map("county", 
    col = colors[Matches], 
    fill = TRUE,
    resolution = 0,
    lty = 0,
    projection = "polyconic"
)
#State boundaries will make it better.

# draw state boundaries
map("state",
    col = "purple",
    fill = FALSE,
    add = TRUE,
    lty = 1,
    lwd = 0.3,
    projection = "polyconic"
)
#Never forget the title and legend.

# add title and legend
title("Unemployment by county, 2009")

Legend <- c("<2%","2-4%","4-6%","6-8%","8-10%",">10%")
legend("topright", Legend, horiz = TRUE, fill = colors)

# Change the intervals to ("<5%","5-10%","10-15%","15-20%","20-25%",">25%").

Intervals <- as.numeric(
  cut(
    unemp$unemp,
    c(0,5,10,15,20,25,100)
  )
)
Matches <- Intervals[
  match(
    county.fips$fips,
    unemp$fips
  )
  ]

map("county", 
    col = colors[Matches], 
    fill = TRUE,
    resolution = 0,
    lty = 0,
    projection = "polyconic"
)
map("state",
    col = "purple",
    fill = FALSE,
    add = TRUE,
    lty = 1,
    lwd = 0.3,
    projection = "polyconic"
)
title("Unemployment by county, 2009")
Legend <- c("<5%","5-10%","10-15%","15-20%","20-25%",">25%")
legend("topright", Legend, horiz = TRUE, fill = colors)

##########

library(geosphere)
map("state")
lat_ca <- 39.164141
lon_ca <- -121.640625

lat_me <- 45.213004
lon_me <- -68.906250

inter <- gcIntermediate(
  c(lon_ca,lat_ca),
  c(lon_me,lat_me),
  n = 50,
  addStartEnd=TRUE
)
lines(inter)


###

airports <- read.csv("http://datasets.flowingdata.com/tuts/maparcs/airports.csv", header = TRUE)
flights  <- read.csv("http://datasets.flowingdata.com/tuts/maparcs/flights.csv", header = TRUE, as.is = TRUE)

tibble::tibble(airports)
tibble::tibble(flights)
#Plot the map and flights.

# create a world map and limited it to around US areas.
xlim <- c(-171.738281, -56.601563)
ylim <- c(12.039321, 71.856229)
map(
  "world", 
  col="#f2f2f2", 
  fill=TRUE, 
  bg="white", 
  lwd=0.05, 
  xlim=xlim, 
  ylim=ylim
)

fsub <- flights[flights$airline == "AA",]

for(j in 1:length(fsub$airline)){
  air1 <- airports[
    airports$iata == fsub[
      j,]$airport1,]
  
  air2 <- airports[
    airports$iata == fsub[
      j,]$airport2,]
  
  inter <- gcIntermediate(
    c(
      air1[1,]$long,
      air1[1,]$lat
    ),
    c(
      air2[1,]$long,
      air2[1,]$lat
    ),
    n = 100,
    addStartEnd = TRUE
  )
  
  lines(inter, col="black", lwd=0.8)
}
