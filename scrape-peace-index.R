library(rvest)
library(httr)
library(jsonlite)
url <- "http://www.peaceindex.org/indexYearsEng.aspx?num=19"

d<-GET(url)

html <- content(d, as="text")

file <- html %>% 
  str_extract("fileToDownload=\".*?\"") %>%
  str_remove("fileToDownload=") %>% 
  str_remove_all("\"")

file <- paste0("http://www.peaceindex.org/", file)

download.file(file, destfile = "peaceindex.zip")
