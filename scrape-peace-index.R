source(here::here("setup.R"))
library(rvest)
library(httr)
library(jsonlite)

# init a blank data frame to put survey dates in
survey_dates <- tibble(file = "", survey = "")

# test page
pagenumber <- 270

# when it is working, change this to for(pagenumber in 1:400) {
for(pagenumber in 1:400) {
  for(i in 1:12){
    # when this works, wrap everything in tryCatch() to skip over errors
  #tryCatch(
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
      str_replace(" ", "%20") %>% 
      str_replace("Hebrew", "English")
    
    survey <- html_text %>%
      str_extract("Survey dates:.*<") %>% 
      str_remove("<") %>% 
      str_remove("Survey dates:")
    print(survey)
    # merge with survey date records 
    survey_dates %<>% full_join(tibble(file = file, survey = survey))
    
    file.url <- paste0("http://www.peaceindex.org/", file)
    
    # only download if we don't have it already
    tryCatch(if(!str_remove(file, "files/") %in% list.files(path = here("files") ) ){
    download.file(file.url, destfile = file)
    }, error = function(e) e)
}
}

save(survey_dates, file = here("data/survey_dates.Rdata"))

# FIXME
## unzip not working, idk why
## for(i in list.files(here("files") ) )...
unzip(here("data/p1201_Hebrew.zip"), exdir = here("data"))
# /FIXME


## https://www.r-bloggers.com/how-to-open-an-spss-file-into-r/
## init with any random file
d <- read.spss(here("files/p1012_Hebrew.sav" ), to.data.frame=TRUE)

sav.files <- unique(str_extract( list.files(here("files")), ".*sav"))

# for(i in sav.files) {
for(i in sav.files[3]){
d %>% full_join(read.spss(here("files", i), 
                          to.data.frame=TRUE))
}

peace_index <- d
save(peace_index, file = here("data/peace_index.Rdata"))



