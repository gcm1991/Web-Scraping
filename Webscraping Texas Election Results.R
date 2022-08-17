rm(list = ls())

setwd("E:/Graduate Studies/Misc/RM/Marshall")

library(tidyverse)
library(rvest)

#### To scrape primaries or general just change the url 
##### To scrape a different year, change the year in the set_values code (lines 23-24)

url <- "https://imis.county.org/imis/TACMember/Elections/General_Election_Results.aspx"
session <- html_session(url)
form <- html_form(session)[[1]]

counties <- names(form$fields[[30]]$options)
election_results <- data.frame()

for(county in 1:length(counties)){
  
  form <- set_values(form, "ctl01$TemplateBody$WebPartManager1$gwpciNewReportDisplayCommon$ciNewReportDisplayCommon$ParamSheet1$Input1$ctl00" = county*10,
                     "ctl01$TemplateBody$WebPartManager1$gwpciNewReportDisplayCommon$ciNewReportDisplayCommon$ParamSheet1$Input0$ctl00" = 2020)
  
  session <- submit_form(session = session, form = form, submit = "ctl01$TemplateBody$WebPartManager1$gwpciNewReportDisplayCommon$ciNewReportDisplayCommon$ParamSheet1$SubmitButton")
  
  #form <- html_form(session)[[1]]
  
  results <- html_table(session, fill = TRUE)
  
  column_webpage <- c("X1", "X2", "X3", "X4")
  
  
  k <- 1
  i <- 1
  
  for(i in 1:length(results[[3]][[column_webpage[k]]])){
    column <- county*4 - 3
    
    for(k in 1:length(column_webpage)){
      election_results[i,column] <- results[[3]][[column_webpage[k]]][i]
      column <- column + 1
    }
  }
  
  print(counties[county])
  
}

view(election_results)

write.csv(election_results, file = "Texas General Election 2020 (raw).csv")




## Use this code if the website has missing counties
##### 2016 Primaries (seperate bc Kimberly is missing. Kimberly is at place "134" in the county vector. For future data sets if a county is missing, just replace the 134 in both if statements with the index of the missing county)

counties <- names(form$fields[[30]]$options)
 primaries_2016 <- data.frame()
 
for(county in 1:length(counties)){

  form <- set_values(form, "ctl01$TemplateBody$WebPartManager1$gwpciNewReportDisplayCommon$ciNewReportDisplayCommon$ParamSheet1$Input1$ctl00" = county*10,
                     "ctl01$TemplateBody$WebPartManager1$gwpciNewReportDisplayCommon$ciNewReportDisplayCommon$ParamSheet1$Input0$ctl00" = 2016)

  session <- submit_form(session = session, form = form, submit = "ctl01$TemplateBody$WebPartManager1$gwpciNewReportDisplayCommon$ciNewReportDisplayCommon$ParamSheet1$SubmitButton")

  #form <- html_form(session)[[1]]

  results <- html_table(session, fill = TRUE)

  column_webpage <- c("X1", "X2", "X3", "X4")
   
if(county != 134){  #Checks to see if the county is not missing. Put missing county or list of missing counties here
   k <- 1
    i <- 1
  
     for(i in 1:length(results[[3]][[column_webpage[k]]])){
       column <- county*4 - 3
     
     for(k in 1:length(column_webpage)){
      primaries_2016[i,column] <- results[[3]][[column_webpage[k]]][i]
      column <- column + 1
     }
   }
} 
  
  if(county == 134){    #for missing counties fills the data with blanks. Put missing county or list of missing counties here
    k <- 1
    i <- 1
    
    for(i in 1:length(results[[3]][[column_webpage[k]]])){
      column <- county*4 - 3
      
      for(k in 1:length(column_webpage)){
        primaries_2016[i,column] <- " "
        column <- column + 1
      }
    }
  }  
  
  print(counties[county])
  
}

view(primaries_2016)

write.csv(primaries_2016, file = "Texas Primaries Election 2016 (Raw).csv")

############


