### Quest get API credentials to geocode!
old <- F
if (old) {
  library('ggmap')
  geocode("rio de janeiro")
  ?register_google
  
  cat("To obtain an API key and enable services, go to https://cloud.google.com/maps-platform/. This documentation shows you how to input the requisite information (e.g. your API key) into R, and it also shows you a few tools that can help you work with the credentialing.")
  browseURL("https://cloud.google.com/maps-platform/")
}

cat("Alternatively, use opencage to geocode:")
if(F){
  install.packages("opencage")
}
library("opencage")
browseURL("https://docs.ropensci.org/opencage/")

cat("Want to store API key in your .Renviron:")
if (Sys.getenv("OPENCAGE_KEY") == ""){ # R> ""
  writeClipboard("OPENCAGE_KEY=<YOURKEY HERE>")
  usethis::edit_r_environ()
} 

output <- opencage::opencage_forward(placename = "Sarzeau")
print(output$time_stamp) # Weeee; [1] "2020-02-19 17:24:15 AEDT"
