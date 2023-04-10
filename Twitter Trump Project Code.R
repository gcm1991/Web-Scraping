rm(list = ls())
setwd("C:/Users/cayde/OneDrive/Data Science/R Projects/Twitter Trump Project")

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

API_key <- "0I2P9m5pAXQqIjnB3NaC2U4YR"
API_secret_key <- "Pn4MjDQJTazxrknIB9sI2J443pxdt3ltOakU3ylMyyovLX2osv"
Bearer_token <- "AAAAAAAAAAAAAAAAAAAAAAgFIAEAAAAAUpUVIx0caNvy8lSl%2FgzAWO0JEFk%3DeWmBIKwmHSryMB3nF9A8ah9V6UiSu4dVOi63PhZMgoJAYbqU8V"
Access_token <- "1308879406962823173-Oy22TabWQjzkWasZdowzVANVO1ltkq"
Access_token_secret <-  "sMIj15DQkw2z9jsOlojNJFt1tbgfPc4NavC3zEQy3RZlQ"

options(httr_oauth_cache=TRUE)
setup_twitter_oauth(consumer_key = API_key, consumer_secret = API_secret_key,
                    access_token = Access_token, access_secret = Access_token_secret)

tweets_at_trump_11_2 <- searchTwitter("@realDonaldTrump exclude:retweets", n=2500)

tweets_at_trump_df_11_2 <- tbl_df(map_df(tweets_at_trump_11_2, as.data.frame))

write.csv(tweets_at_trump_df_11_2, "Tweets at Trump 11_2.csv")

library(tm)

tweets_at_trump <- read.csv("Tweets at Trump Hand-labeled.csv")

#Removing Stop Words
corpus <- Corpus(VectorSource(tweets_at_trump$text))
handle <- "realdonaldtrump"
myStopWords <- c("trump", "president")
corpus_cleaned <- tm_map(corpus, removeWords, stopwords())

#Removing URL
remove_url <- function(x) gsub("http[^[:space:]]*", "",x)
corpus_cleaned <- tm_map(corpus_cleaned, content_transformer(remove_url))

#Removing anything other than english letters and space
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*","",x)
corpus_cleaned <- tm_map(corpus_cleaned, content_transformer(removeNumPunct))
corpus_cleaned <- tm_map(corpus_cleaned, content_transformer(tolower))
corpus_cleaned <- tm_map(corpus_cleaned, stripWhitespace)
corpus_cleaned <- tm_map(corpus_cleaned, stemDocument)

dtm <- DocumentTermMatrix(corpus_cleaned)

####

tweets_at_trump$text <- gsub("https://(.*)[.|/](.*)", "", tweets_at_trump$text)
tweets_at_trump$text <- gsub("<U(.*)[>]","", tweets_at_trump$text)
tweets_at_trump$text <- gsub("@\\w+","", tweets_at_trump$text)
tweets_at_trump$text <- gsub("#\\w+","", tweets_at_trump$text)
tweets_at_trump$text <- gsub("[[:punct:]]","", tweets_at_trump$text)

tweets_at_trump_text <- data.frame(text = sapply(corpus_cleaned, as.character), stringsAsFactors = FALSE)
tweets_at_trump$text <- tweets_at_trump_text$text
write.csv(tweets_at_trump, file = "Tweets at Trump.csv")


rm(list = ls())

tweets_at_trump <- readtext("Tweets at Trump Coded Cleaned Master.csv", text_field = "text")
corpus_tweets <- corpus(tweets_at_trump)

tweets_at_trump$sentiment <- replace(tweets_at_trump$sentiment, tweets_at_trump$sentiment == "y", "Positive")
tweets_at_trump$sentiment <- replace(tweets_at_trump$sentiment, tweets_at_trump$sentiment == "u", "Neutral")
tweets_at_trump$sentiment <- replace(tweets_at_trump$sentiment, tweets_at_trump$sentiment == "n", "Negative")

tweets_at_trump$dehumanizing <- replace(tweets_at_trump$dehumanizing, tweets_at_trump$dehumanizing == "y", "Yes")
tweets_at_trump$dehumanizing <- replace(tweets_at_trump$dehumanizing, tweets_at_trump$dehumanizing == "n", "No")

#Creating Training and Test Sets

train_set <- corpus_subset(corpus_tweets, data_set == "training")
validation_set <- corpus_subset(corpus_tweets, data_set == "validation")
test_set <- corpus_subset(corpus_tweets, data_set == "test")

dfm_train_set <- dfm(train_set)
dfm_validation_set <- dfm(validation_set)
dfm_test_set <- dfm(test_set)

#Training the Model

tmod_nb_d <- textmodel_nb(dfm_train_set, dfm_train_set$dehumanizing)
summary(tmod_nb_d)

tmod_nb_n <- textmodel_nb(dfm_train_set, dfm_train_set$sentiment)
summary(tmod_nb_n)

#Testing the Model

dfmat_matched_validation <- dfm_match(dfm_validation_set, features = featnames(dfm_train_set))
dfmat_matched_test <- dfm_match(dfm_test_set, features = featnames(dfm_train_set))

#Predicting Class

test_predictions_d <- predict(tmod_nb_d, newdata = dfmat_matched_test)
test_predictions_s <- predict(tmod_nb_n, newdata = dfmat_matched_test)

#Showing Results

actual_class <- dfmat_matched_validation$dehumanizing
predicted_class <- predict(tmod_nb_d, newdata = dfmat_matched_validation)
tab_class <- table(actual_class, predicted_class)
sjt.xtab(actual_class, predicted_class , file = "contingency.doc")


actual_class <- dfmat_matched_validation$sentiment
predicted_class <- predict(tmod_nb_n, newdata = dfmat_matched_validation)
tab_class <- table(actual_class, predicted_class)
sjt.xtab(actual_class, predicted_class , file = "contingency.doc")


actual_class <- dfmat_matched_test$sentiment
table(actual_class, test_predictions_s)

length(test_predictions_s[test_predictions_s == "n"]) 
length(test_predictions_s[test_predictions_s == "y"]) 
length(test_predictions_s[test_predictions_s == "u"]) 

length(test_predictions_s[test_predictions_d == "n"]) 
length(test_predictions_s[test_predictions_d == "y"]) 


#Dictionary Targeted Sentiment Analysis
#######################################

dehumanzing_words <- c("dog", "shit", "karma", "suffer", "*clown", "get fucked", 
                       "no sympathy", "sociopath", "devil", "demon", "not human", 
                       "despicable", "cunt", "monster", "sicko", "scum*", "pig", 
                       "dog", "evil", "sheep", "psychopath", "demon", "insane",
                       "turd", "nuts", "psycho", "*tard*", "antichrist", "chimp*",
                       "monkey", "ape", "reptile")
toks_tweets <- tokens(corpus_tweets, remove_punct = TRUE)

toks_dehum <- tokens_keep(toks_tweets, pattern = phrase(dehumanzing_words), window = 5)

sum <- 0

for(i in 1:34452){
  file <- paste0("Tweets at Trump Coded Cleaned Master.csv.", i)
  if(length(toks_dehum[[file]])>0){sum <- sum + 1}
}

#Word Cloud
deh_tweets <- NA

for(i in 1:34452){
  file <- paste0("Tweets at Trump Coded Cleaned Master.csv.", i)
  if(length(toks_dehum[[file]])>0){deh_tweets <- append(deh_tweets, i)}
}

deh_tweets <- deh_tweets[-1]

dehumanizing_tweets <- tweets_at_trump[deh_tweets,]
dehumanizing_corpus <- corpus(dehumanizing_tweets)
dehumanizing_tokens <- tokens(dehumanizing_corpus, remove_punct = TRUE)
dfm_dehumanizing <- dfm(dehumanizing_tokens)

textplot_wordcloud(dfm_dehumanizing)

#################################
#Descriptive Statistics

des_deh <- table(tweets_at_trump$dehumanizing)
des_n <- table(tweets_at_trump$sentiment)

des_deh %>%
  kbl(col.names = c("Dehumanizing?", "Frequency")) %>%
  kable_styling()

des_n %>%
  kbl(col.names = c("Sentiment", "Frequency")) %>%
  kable_styling()

#####################
#Text Frequency

toks_tweets <- tokens(tweets_at_trump_cleaned$vocab)
dfmat_tweets <- dfm(toks_tweets)

tstat_freq <- textstat_frequency(dfmat_tweets)

head(tstat_freq, 100)


#######################
#Sentiment Analysis

rm(list = ls())

tweets_at_trump <- read.csv( file = "Tweets at Trump Coded Cleaned Master.csv")

sentiment_tweets_at_trump <- sentiment(get_sentences(tweets_at_trump$text))
tweets_at_trump$sentiment_score <- sentiment_tweets_at_trump$sentiment

coded_tweets <- tweets_at_trump[!is.na(tweets_at_trump$sentiment),]

sentiment_tweets_at_trump_coded <- sentiment(get_sentences(coded_tweets$text))
coded_tweets$sentiment_score <- sentiment_tweets_at_trump_coded$sentiment

aggregate(coded_tweets$sentiment_score,  by = list(coded_tweets$sentiment), FUN = mean)
aggregate(coded_tweets$sentiment_score,  by = list(coded_tweets$dehumanizing), FUN = mean)

t.test(coded_tweets$sentiment_score[coded_tweets$sentiment == "n"], coded_tweets$sentiment_score[coded_tweets$sentiment == "y"])
t.test(coded_tweets$sentiment_score[coded_tweets$dehumanizing == "y" & coded_tweets$sentiment == "n"], coded_tweets$sentiment_score[coded_tweets$dehumanizing == "n" & coded_tweets$sentiment == "n"])

table(tweets_at_trump$sentiment)

hist(coded_tweets$sentiment_score[coded_tweets$sentiment == "n" & coded_tweets$dehumanizing == "y"])
hist(coded_tweets$sentiment_score[coded_tweets$sentiment == "n" & coded_tweets$dehumanizing == "n"])

which(tweets_at_trump$sentiment == "n ")

density_dehumanizing <- density(coded_tweets$sentiment_score[coded_tweets$sentiment == "n" & coded_tweets$dehumanizing == "y"])
density_negative <- density(coded_tweets$sentiment_score[coded_tweets$sentiment == "n" & coded_tweets$dehumanizing != "y"])

plot(density_negative)
lines(density_dehumanizing)

toxicity <- head(sort(tweets_at_trump$sentiment_score), n = 100)

toxic_tweets <- tweets_at_trump[tweets_at_trump$sentiment_score <= toxicity[100],]
keep_toxic <- toxic_tweets$order

tweets_at_trump_full <- read.csv("Tweets at Trump Cumulative Coded.csv")

toxic_tweets_full <- tweets_at_trump_full[keep_toxic,]

