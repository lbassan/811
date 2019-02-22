library(rvest)
library(httr)
library(jsonlite)
testurl <- "http://www.peaceindex.org/indexYearsEng.aspx?num=19"

# text page
pagenumber <- 270

# when it is working, change this to for(pagenumber in 1:400) {
for(pagenumber in 270) {
  for(i in 1:12){
    # when this works, wrap everything in tryCatch() to skip over errors
#  tryCatch(
    url <- paste0(
      "http://www.peaceindex.org/indexMonthEng.aspx?num=",
      pagenumber,
      "&monthname=",
      month.name[i]
    )
    url
    
    # DEALING WITH HTML
    d <- GET(url)
    
    html <- content(d, as = "text")
    # Is there even a file in that html content? 
    str_extract(html, "fileToDownload.*")
    
    file <- html %>%
      str_extract("fileToDownload=\".*?\"") %>%
      str_remove("fileToDownload=") %>%
      str_remove_all("\"") %>% 
      str_replace(" ", "%20")
    
    # FIXME
    survey <- html %>%
      str_extract("Survey dates:.")
    # /FIXME
    
    file.url <- paste0("http://www.peaceindex.org/", file)
    
    # only download if we don't have it already
    if(!str_remove(file, "files/") %in% list.files(path = here("files") ) ){
    download.file(file.url, destfile = file)
    }
}
}


