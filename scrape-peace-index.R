source(here::here("setup.R"))
library(rvest)
library(httr)
library(jsonlite)

# init a blank data frame to put survey dates in
survey_dates <- tibble(file = "", survey = "")

# test page
pagenumber <- 270

# change this to for(pagenumber in 1:400) {
for(pagenumber in 1:1000) {
  for(i in 1:12){
    ## define url
    url <- paste0(
      "http://www.peaceindex.org/indexMonthEng.aspx?num=",
      pagenumber,
      "&monthname=",
      month.name[i]
    )
    print(url)
    
    # DEALING WITH HTML
    html_raw <- GET(url)
    html_text <- httr::content(html_raw, as = "text")
    
    # Is there even a file in that html content? 
    print(str_extract_all(html_text, "fileToDownload.*"))
    
    file <- html_text %>%
      str_extract("fileToDownload=\".*?\"") %>%
      str_remove("fileToDownload=\"files.") %>%
      str_remove_all("\"") %>% 
      str_replace(" ", "%20")
    
    survey <- html_text %>%
      str_extract("Survey dates:.*<") %>% 
      str_remove("<") %>% 
      str_remove("Survey dates:")
    print(survey)
    # merge with survey date records 
    survey_dates %<>% full_join(tibble(file = file, survey = survey))
    
    file.url <- paste0("http://www.peaceindex.org/", file)
    
    # only download if it exists and we don't have it already
    if(!is.na(file) & !file %in% list.files(path = here("files") ) ){
    download.file(file.url, destfile = here("files", file) )
    }
}
}

save(survey_dates, file = here("data/survey_dates.Rdata"))

## unzip not working, idk why
unzip(here("data/p1201_Hebrew.zip"), exdir = here("data"))
