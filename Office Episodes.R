rm(list = ls())

library(rvest)
library(ggplot2)

url <- "https://www.imdb.com/search/title/?series=tt0386676&view=simple&count=250&sort=user_rating,desc"
webpage <- read_html(url)

ratings <- html_elements(webpage, ".col-imdb-rating")
as.numeric(html_text(ratings, trim = TRUE))

episode <- html_elements(webpage, ".unbold+ a")
html_text(episode)

year <- html_elements(webpage, ".unbold~ .text-muted")
html_text(year)

office_data <- data.frame(html_text(episode), 
                            as.numeric(html_text(ratings, trim = TRUE)),
                            html_text(year))

names(office_data) <- c("episode", "rating", "year")

office_data$michael_scott <- "No"

michael_scott_years <- c("(2005)", "(2006)", "(2007)", "(2008)", "(2009)", "(2010)")
michael_scott_episodes <- c("Finale", "Goodbye, Michael", "Garage Sale", "Threat Level Midnight",
                            "Michael's Last Dundies", "The Search", "PDA", "Ultimatum",
                            "Training Day", "The Seminar", "Todd Packer")

office_data$michael_scott[office_data$year %in% michael_scott_years] <- "Yes"
office_data$michael_scott[office_data$episode %in% michael_scott_episodes] <- "Yes"

ggplot(data = office_data, mapping = aes(x = michael_scott, y = rating)) +
  geom_boxplot()

t.test(office_data$rating ~ office_data$michael_scott)

ggplot(data = office_data, mapping = aes(x = year, y = rating)) +
  geom_boxplot()


