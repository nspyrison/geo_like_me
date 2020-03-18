### Coalate data -----
library('tidyverse')

filenames <- dir("./gapminder_data/")[grepl(".csv", dir("./gapminder_data/"))]
var_names <-c("fertility.children_pw", "co2_emmsions.tonnes_pp", 
              "tertiary_tuition.pct_gdp_pp", "gini.0_1", 
              "human_development_index.0_1", "income.gdp_ppp_inflation_adj",
              "population_density.pp_sqkm", "population", "suicide_p10kp",
              "surface_area.sqkm")
gm_dat <- NULL
for (i in 1:length(filenames)){
  .df <- read.csv(paste0('./gapminder_data/', filenames[i]), 
                     sep = ",", stringsAsFactors = F)
  .df <- pivot_longer(.df, -country, names_to = "year", values_to = var_names[i])
  if (is.null(gm_dat)){
    gm_dat <- .df
  } else {
    gm_dat <- left_join(gm_dat, .df, by = c("country", "year"), )
  }
}
gm_dat$year <- as.integer(gsub("[X]", "", gm_dat$year))
if (length(gm_dat) == 0 | is.null(gm_dat)) warning("DATA NOT LOADED!!!")
str(gm_dat)

### Geocode countries -----
uCountries <- unique(gm_dat$country); length(uCountries)
selectedCountries <- sample(uCountries,size = 4, replace = FALSE)
df_selectedGeocodings <- NULL
## Note that this loop, does pull against your opencage quota (2,500 req/day)
for (i in 1:length(selectedCountries)){ #length(countries)) {
  .gc <- opencage::opencage_forward(placename = selectedCountries[i])
  .country <- as.character(selectedCountries[i])
  .lat     <- as.numeric(.gc$results$geometry.lat[1])
  .lng     <- as.numeric(.gc$results$geometry.lng[1])
  .NE_lat  <- as.numeric(.gc$results$bounds.northeast.lat[1])
  .NE_lng  <- as.numeric(.gc$results$bounds.northeast.lng[1])
  .SW_lat  <- as.numeric(.gc$results$bounds.southwest.lat[1])
  .SW_lng  <- as.numeric(.gc$results$bounds.southwest.lng[1])
  .df      <- data.frame(country = .country, 
                         lat = .lat, lng = .lng,
                         NE_lat = .NE_lat, NE_lng = .NE_lng,
                         SW_lat = .SW_lat, SW_lng = .SW_lng, 
                         stringsAsFactors = F)
  df_selectedGeocodings <- rbind(df_selectedGeocodings, .df)
}
plot_dat <- left_join(dplyr::filter(gm_dat, country %in% selectedCountries),
                      df_selectedGeocodings, 
                      by = "country", suffix = c(".gm", ".gc"))
str(plot_dat)

### Filter and reorder columns
## Drop columnwise incomplete; do we need to back fill new countries or check earlier?
colsToDrop <- apply(plot_dat, 2, function(.col){sum(is.na(.col)) >= 100})
plot_dat <- plot_dat[, !colsToDrop]
.dim  <- select(plot_dat, 
               country, year, lat, lng, NE_lat, NE_lng, SW_lat, SW_lng, population)
.fact <- select(plot_dat,
               -country, -year, -lat, -lng, -NE_lat, -NE_lng, -SW_lat, -SW_lng, -population)
plot_dat <- cbind(.dim, .fact)

### Map ----
library('ggmap')
for (i in 1:4){
  (.row <- plot_dat[i,])
  (.targ <- c(left = .row$SW_lng, bottom = .row$SW_lat, 
              right = .row$NE_lng, top = .row$NE_lat))
  gmap <- get_stamenmap(.targ, zoom = 5, maptype = "terrain") %>% ggmap() 
  
  assign(paste0("gg", i), gmap + theme(axis.title.x = element_blank(),
                                       axis.text.x  = element_blank(),
                                       axis.ticks.x = element_blank(),
                                       axis.title.y = element_blank(),
                                       axis.text.y  = element_blank(),
                                       axis.ticks.y = element_blank()))
}


### Inlay hist ----
# Specify position of plot2 (in percentages of plot1)
gg_inlay_histogram <- function(ggplot, 
                               dat      = plot_dat, ##TODO NEED TO GO TO FULL COUNTRY DAT FOR HISTOGRAM
                               country  = selectedCountries[1],
                               variable = "population",
                               xleft    = 0.01, 
                               xright   = 0.4,
                               ybottom  = 0.6, 
                               ytop     = 0.99) {
  max_yr      <- max(dat$year)
  sub_dat     <- dat[which(dat$year == max_yr), ]
  sub_dat$col <- ifelse(sub_dat$country == country, "red", "grey70")
  targ        <- sub_dat[which(sub_dat$country == country),]

  ### Calculate position in plot1 coordinates
  l1   <- ggplot_build(ggplot)
  x1   <- targ$SW_lng
  x2   <- targ$NE_lng
  y1   <- targ$SW_lat
  y2   <- targ$NE_lat
  xdif <- x2 - x1
  ydif <- y2 - y1
  xmin <- x1 + (xleft * xdif)
  xmax <- x1 + (xright * xdif)
  ymin <- y1 + (ybottom * ydif)
  ymax <- y1 + (ytop * ydif) 
  tick_breaks <- as.numeric(c(min(sub_dat[variable]), targ[variable], max(sub_dat[variable])))
  browser()
  
  # Make ggplot2
  (gg2 <- ggplot(sub_dat) + 
    geom_histogram(mapping = aes(get(variable), fill = I(col))) + 
    theme_minimal() + 
    theme(panel.background = element_rect(fill = "white", 
                                          colour = "black",
                                          size = .5, linetype = "solid"),
          axis.ticks.x = element_line(size=1),
          axis.title.y = element_blank(),
          axis.text.y  = element_blank(),
          axis.ticks.y = element_blank(),
          axis.line    = element_blank(),
          panel.border     = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background  = element_rect(fill = "white")
          ) + 
      scale_x_continuous(name = variable, 
                         breaks = tick_breaks)
  )
  # + theme(axis.title.x = element_text(colour = "red", size = rel(1.5)))
  
  (gg_inlay = ggplot + 
      ggmap::inset(grob = ggplotGrob(gg2),
                   xmin = xmin, xmax = xmax, 
                   ymin = ymin, ymax = ymax)
  )
  return(gg3)
}


out1 <- gg_inlay_histogram(gg1, plot_dat, selectedCountries[1])
out2 <- gg_inlay_histogram(gg2, plot_dat, selectedCountries[2])
out3 <- gg_inlay_histogram(gg3, plot_dat, selectedCountries[3])
out4 <- gg_inlay_histogram(gg4, plot_dat, selectedCountries[4])

(GG <- gridExtra::grid.arrange(out1, out2, out3, out4, ncol = 2))
