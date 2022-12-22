rm(list = ls())
setwd("E:/Graduate Studies/Seminars/Methodology/Computational Social Science/Twitter Research Project")

#1) Do this whenever you need to start a session#
library(stringr)
library(twitteR)
library(purrr)
library(tidytext)
library(dplyr)
library(tidyr)
library(lubridate)
library(scales)
library(broom)
library(ggplot2)

# 2) Get access to Twitter#

API_key <- "0I2P9m5pAXQqIjnB3NaC2U4YR"     
API_secret_key <- "Pn4MjDQJTazxrknIB9sI2J443pxdt3ltOakU3ylMyyovLX2osv"     
Bearer_token <- "AAAAAAAAAAAAAAAAAAAAAAgFIAEAAAAAUpUVIx0caNvy8lSl%2FgzAWO0JEFk%3DeWmBIKwmHSryMB3nF9A8ah9V6UiSu4dVOi63PhZMgoJAYbqU8V"   
Access_token <- "1308879406962823173-Oy22TabWQjzkWasZdowzVANVO1ltkq"
Access_token_secret <-  "sMIj15DQkw2z9jsOlojNJFt1tbgfPc4NavC3zEQy3RZlQ"

options(httr_oauth_cache=TRUE)
setup_twitter_oauth(consumer_key = API_key, consumer_secret = API_secret_key,
                    access_token = Access_token, access_secret = Access_token_secret)

#3 Scraping Tweets

#3.1) Scrape a user's tweets 
trump_tweets<- userTimeline("realDonaldTrump", n = 10)

trump_tweets_df <- tbl_df(map_df(trump_tweets, as.data.frame))

#write.csv(trump_tweets_df, "Trump Tweets.csv")

#3.2) Search for a hashtag
KHive <- searchTwitter("#KHive exclude:retweets", n=10)

KHive_df <- tbl_df(map_df(KHive, as.data.frame))

#write.csv(_df, ".csv")

#3.3) Search for all tweets directed to a user
tweets_at_trump_11_2 <- searchTwitter("@realDonaldTrump exclude:retweets", n=2500)

tweets_at_trump_df_11_2 <- tbl_df(map_df(tweets_at_trump_11_2, as.data.frame))

write.csv(tweets_at_trump_df_11_2, "Tweets at Trump 11_2.csv")

#4 Loading Tweets IN

tweets_at_trump <- read.csv(file = "Tweets at Trump Cumulative Coded.csv")

#5.1 Cleaning Tweets https://www.youtube.com/watch?v=qWmMKmPVtgk&ab_channel=DataScienceTutorials

library(tm)

#Removing Stop Words
corpus <- Corpus(VectorSource(tweets_at_trump$text))
corpus_cleaned <- tm_map(corpus, removeWords, stopwords())

#Removing Additional words
handle <- "realdonaldtrump"
corpus_10_3 <- tm_map(corpus_10_3, removeWords, handle)
myStopWords <- c("trump", "president")
corpus_10_3 <- tm_map(corpus_10_3, removeWords, myStopWords)

#Removing URL
remove_url <- function(x) gsub("http[^[:space:]]*", "",x)
corpus_10_3 <- tm_map(corpus_10_3, content_transformer(remove_url))

#Removing anything other than english letters and space
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*","",x)
corpus <- tm_map(corpus, content_transformer(removeNumPunct))
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, stemDocument)

dtm_10_3 <- DocumentTermMatrix(corpus_10_3)

####


tweets_at_trump$text <- gsub("https://(.*)[.|/](.*)", "", tweets_at_trump$text)
tweets_at_trump$text <- gsub("<U(.*)[>]","", tweets_at_trump$text)
tweets_at_trump$text <- gsub("@\\w+","", tweets_at_trump$text)
tweets_at_trump$text <- gsub("#\\w+","", tweets_at_trump$text)
tweets_at_trump$text <- gsub("[[:punct:]]","", tweets_at_trump$text)

unique(tweets_at_trump_df_10_5$id)

write.csv(tweets_at_trump, file = "Tweets at Trump Cumulative Coded Cleaned.csv")
#5.2 Bag of Words

ex_tweet <- "uwu I like to tweet about politics"

tweet_lengths <- 0

for(i in 1:nrow(tweets_at_trump)){
 length <- sapply(strsplit(tweets_at_trump[i,1], " "), length)
 tweet_lengths <- append(tweet_lengths, length)
  
}


tweets_at_trump_text <- data.frame(matrix(ncol = max(tweet_lengths), nrow = 7000))
tweets_at_trump_text[,1] <- tweets_at_trump[,1]

for(i in 1:nrow(tweets_at_trump)){
 tweet <- strsplit(tweets_at_trump[i,1], " ")
  for(j in 1:length(tweet[[1]])){
    tweets_at_trump_text[i,j] <- tweet[[1]][j]
  }
}

head(tweets_at_trump_text)

tweets_at_trump_text <- tweets_at_trump_text[is.na(tweets_at_trump_text)]

bag <- strsplit(ex_tweet, " ")
bag[[1]][3]
?strsplit
length(bag[[1]])

#6 Analyzing Tweets

#6.1 Word Cloud

library(wordcloud)

wordcloud(corpus_10_3)

#6.2 Sentiment Analysis

library("sentimentr")

sentiment_tweets_at_trump <- sentiment(tweets_at_trump$text)
sentiment_analysis <- data.frame(matrix(ncol = 2, nrow = length(tweets_at_trump$text)))
sentiment_analysis[,1] <- as.character(sentiment_analysis[,1])
colnames(sentiment_analysis) <- c("Tweet", "Sentiment Score")

sentiment_analysis[,1] <- tweets_at_trump$text
sentiment_analysis[,2] <- sentiment_tweets_at_trump$sentiment



#################################################

getwd()
setwd("E:/Graduate Studies/Seminars/Methodology/Computational Social Science/Twitter Research Project")

