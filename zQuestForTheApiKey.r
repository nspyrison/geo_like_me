# ### Quest get API credentials to geocode!
# ## OLD:
# run_old <- FALSE
# if (run_old) {
#   library('ggmap')
#   geocode("rio de janeiro")
#   ?register_google
#   
#   cat("To obtain an API key and enable services, go to https://cloud.google.com/maps-platform/. This documentation shows you how to input the requisite information (e.g. your API key) into R, and it also shows you a few tools that can help you work with the credentialing.")
#   browseURL("https://cloud.google.com/maps-platform/")
# }

cat("Alternatively, use opencage to geocode: \n")
if (!require("opencage")) install.packages("opencage")
library("opencage")
browseURL("https://docs.ropensci.org/opencage/")
browseURL("https://opencagedata.com/pricing")

cat("Store your API key in your .Renviron, (NOT YOUR .R SCRIPTS):")
if (Sys.getenv("OPENCAGE_KEY") == ""){ ## R> ""
  cat("Enter your key in the following line, we'll copy text to clip board and 
      open your .Renviron, then paste the line, save, and close. \n")
  myOpenCageKey <- "<paste your key here>"
  writeClipboard(paste0("OPENCAGE_KEY=", myOpencageKey))
  if (require("usethis")) usethis::edit_r_environ()
} 

cat("Great job, you are done, let's test it out: \n")
output <- opencage::opencage_forward(placename = "Sarzeau")
print(output$time_stamp) ## R> [1] "2020-02-19 17:24:15 AEDT"  -- Rejoice!
