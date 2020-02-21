### Coalate data -----
library('tidyverse')

filenames <- dir("./gapminder_data/")[grepl(".csv", dir("./gapminder_data/"))]
var_names <-c("fertility.children_pw", "co2_emmsions.tonnes_pp", 
              "tertiary_tuition.pct_gdp_pp", "gini.0_1", 
              "human_development_index.0_1", "income.gdp_ppp_inflation_adj",
              "population_density.pp_sqkm", "population", "suicide_p10kp",
              "surface_area.sqkm")
dat <- NULL
for (i in 1:length(filenames)){
  .df <- read.csv(paste0('./gapminder_data/', filenames[i]), 
                     sep = ",", stringsAsFactors = F)
  .df <- pivot_longer(.df, -country, names_to = "year", values_to = var_names[i])
  if (is.null(dat)){
    dat <- .df
  } else {
    dat <- left_join(dat, .df, by = c("country", "year"), )
  }
}
dat$year <- as.integer(gsub("[X]", "", dat$year))
str(dat)

### Geocode countries -----
countries <- unique(dat$country)
df_country <- NULL
for (i in 1:5){ #length(countries)) {
  .gc <- opencage::opencage_forward(placename = countries[i])
  .country <- as.character(countries[i])
  .lat    <- as.numeric(.gc$results$geometry.lat[1])
  .lng    <- as.numeric(.gc$results$geometry.lng[1])
  .NE_lat <- as.numeric(.gc$results$bounds.northeast.lat[1])
  .NE_lng <- as.numeric(.gc$results$bounds.northeast.lng[1])
  .SW_lat <- as.numeric(.gc$results$bounds.southwest.lat[1])
  .SW_lng <- as.numeric(.gc$results$bounds.southwest.lng[1])
  .df <- data.frame(country = .country, lat = .lat, lng = .lng,
                    NE_lat = .NE_lat, NE_lng = .NE_lng,
                    SW_lat = .SW_lat, SW_lng = .SW_lng)
  df_country <- rbind(df_country, .df)
}
dat <- left_join(dat, df_country, by = "country", suffix = c("", ".gc"))
str(dat)

### Map ----
library('ggmap')
for (i in 1:4){
  .row <- dat[i,]
  .targ <- c(left = .row$SW_lng, bottom = .row$SW_lat, 
             right = .row$NE_lng, top = .row$NE_lat)
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
                               country  = "Afghanistan",
                               variable = "fertility.children_pw",
                               xleft   = 0.01, 
                               xright  = 0.4,
                               ybottom = 0.6, 
                               ytop    = 0.99){ 
  sub_dat <- dat[which(dat$year == 2018), c(1, which(colnames(dat) == variable))]
  country_row <- which(sub_dat$country == country)
  sub_dat$col <- ifelse(sub_dat$country == country, "red", "grey70")
  targ <- df_country[which(df_country$country == country),]


  # Calculate position in plot1 coordinates
  # Extract x and y values from plot1
  l1 <- ggplot_build(ggplot)
  x1 <- targ$SW_lng
  x2 <- targ$NE_lng
  y1 <- targ$SW_lat
  y2 <- targ$NE_lat
  xdif <- x2 - x1
  ydif <- y2 - y1
  xmin  <- x1 + (xleft * xdif)
  xmax  <- x1 + (xright * xdif)
  ymin  <- y1 + (ybottom * ydif)
  ymax  <- y1 + (ytop * ydif) 
  
  # Make ggplot2

  tick_breaks <- as.numeric(c(min(sub_dat[,2]), sub_dat[country_row,2], max(sub_dat[,2])))
  (gg2 <- ggplot(sub_dat) + 
    geom_histogram(mapping = aes(fertility.children_pw, fill = I(col))) + 
    theme_minimal() + 
    theme(panel.background = element_rect(fill = "white", 
                                          colour = "black",
                                          size = .5, linetype = "solid"),
          axis.ticks.x = element_line(size=1),
          axis.title.y = element_blank(),
          axis.text.y  = element_blank(),
          axis.ticks.y = element_blank(),
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_rect(fill = "white"),
          axis.line = element_blank()) + 
      scale_x_continuous(name = variable, 
                         breaks = tick_breaks)
  )
  # + theme(axis.title.x = element_text(colour = "red", size = rel(1.5)))
  
  require('grid')
  #ggplot
  #print(gg2, vp = grid::viewport(0.136, 0.88, width = 0.2, height = 0.2))
  (gg3 = ggplot + ggmap::inset(grob =  ggplotGrob(gg2),
                               xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax))
  return(gg3)
}


out1 <- gg_inlay_histogram(gg1, countries[1])
out2 <- gg_inlay_histogram(gg2, countries[2])
out3 <- gg_inlay_histogram(gg3, countries[3])
out4 <- gg_inlay_histogram(gg4, countries[4])

gridExtra::grid.arrange(out1, out2, out3, out4, ncol = 2)
