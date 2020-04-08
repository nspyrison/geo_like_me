library(maptools)

nz <- readShapeSpatial("./fit5147_data/NZL_adm1/NZL_adm0.shp")
plot(nz)

##Move the 3 files (ne_110m_land.shp, ne_110m_land.shx and ne_110m_land.dbf) to your working directory.

world <- readShapeSpatial("./fit5147_data/ne_110m_land1/ne_110m_land.shp")
plot(world)
#Let’s plot it in another way (with ggplot).

library(ggplot2)
world_shp <- readShapePoly("./fit5147_data/ne_110m_land1/ne_110m_land.shp")
ggplot(
  world_shp,
  aes(
    x = long,
    y = lat,
    group = group
  )
) + 
  geom_path()

# Head into the detail of world_shp.
# You may get confused about the stored structure.
# You can use fortify() to transfer it to our familiar tabular format.
# Note: this is not necessary.

head(world_shp)
str(world_shp)
summary(world_shp)
world_map <- fortify(world_shp) # convert into a tabular structure
tibble::tibble(world_map)
str(world_map)
summary(world_map)

#And use the tabular format to plot.
ggplot(
  world_map,
  aes(
    x=long,
    y=lat,
    group=group
  )
) +
  geom_path()


#########

library(ggmap) # Load the shapes and transform
library(maptools)

area <- readShapePoly("./fit5147_data/ne_10m_parks_and_protected_lands/ne_10m_parks_and_protected_lands_area.shp")
area.points <- fortify(area) # transform to tabular structure
tibble::tibble(area.points)
#Now let’s have a look at how the parks distribute.

# Add some colour
library(RColorBrewer)
colors <- brewer.pal(9,"BuGn")

margin = 15
bbox1 <- c(
  left = -118 - margin, 
  bottom = 37.5 - margin, 
  right = -118 + margin, 
  top = 37.5 + margin
)

# Get the underlying map, it may take a while to get (from stamen)
# Remmerber? Google Map needs an API key...
mapImage <- get_stamenmap(
  bbox = bbox1,
  color = "color",
  maptype = "terrain",
  zoom = 6
)

# Plot the base map
plot(mapImage)
#Then the parks without the base map.

# And the parks without the map...
p <- ggplot()
# a blank
p + 
  geom_polygon(
    aes(x = long, y = lat, group = group),
    data = area.points,
    color = colors[9],
    fill = colors[6],
    alpha = 0.5
  ) +
  labs(x = "Longitude", y = "Latitude")

# And we can stack them layer by layer.

# Put the shapes on top of the map
ggmap(mapImage) +
  geom_polygon(
    aes(x=long, y=lat, group=group),
    data = area.points,
    color = colors[9],
    fill = colors[6],
    alpha = 0.5
  ) +
  labs(x = "Longitude", y = "Latitude")

###

# We still forget something.

# Remember the unexpected NZ at the beginning? 
# (islands split across wrap of the world)

# ggplot2 hack
# ?map_data
# nz <- map_data("nz")

## reproducing the error with the shape file:
nz <- readShapePoly("./fit5147_data/NZL_adm1/NZL_adm0.shp")
nz_map <- fortify(nz)
#Prepare a map of NZ
gg_nz <- ggplot(nz_map, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "gold", colour = "gold")
gg_nz + coord_quickmap() #  approximating the aspect ratio 
#gg_nz + coord_map() # faster variant; ploting with cartesian coordinates


## address the issue with ggplot2::map_data()
nz <- map_data("nz")
gg_get_nz <- ggplot(nz, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "gold", colour = "gold")
gg_get_nz + coord_quickmap()

