library(stringi)
library(tm)
library(RWeka)
library(dplyr)
library(magrittr)
library(e1071)

# specify the source and destination of the download
#destination_file <- "Coursera-SwiftKey.zip"
#source_file <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"

# execute the download
#download.file(source_file, destination_file)

# extract the files from the zip file
#unzip(destination_file)

# import the blogs and twitter datasets in text mode
blogs <- readLines("en_US.blogs.txt", encoding="UTF-8")
twitter <- readLines("en_US.twitter.txt", encoding="UTF-8")

# import the news dataset in binary mode
con <- file("en_US.news.txt", open="rb")
news <- readLines(con, encoding="UTF-8")
close(con)
rm(con)

# drop non UTF-8 characters
twitter <- iconv(twitter, from = "latin1", to = "UTF-8", sub="")
twitter <- stri_replace_all_regex(twitter, "\u2019|`","'")
twitter <- stri_replace_all_regex(twitter, "\u201c|\u201d|u201f|``",'"')

# sample data (100,000 of each)
sample_blogs   <- sample(blogs, 1000)
sample_news    <- sample(news, 1000)
sample_twitter <- sample(twitter, 1000)


n <- 2L
bigram_token <- function(x) NGramTokenizer(x, Weka_control(min = n, max = n))
n <- 3L
trigram_token <- function(x) NGramTokenizer(x, Weka_control(min = n, max = n))

length_is <- function(n) function(x) length(x)==n

# contruct single corpus from sample data
vc_blogs <-
  sample_blogs %>%
  data.frame() %>%
  DataframeSource() %>%
  VCorpus %>%
  tm_map( stripWhitespace )

vc_news <-
  sample_news %>%
  data.frame() %>%
  DataframeSource() %>%
  VCorpus %>%
  tm_map( stripWhitespace )

vc_twitter <-
  sample_twitter %>%
  data.frame() %>%
  DataframeSource() %>%
  VCorpus %>%
  tm_map( stripWhitespace )

vc_all <- c(vc_blogs, vc_news, vc_twitter)

# frequency unigrams
tdm_unigram <-
  vc_all %>%
  TermDocumentMatrix( control = list( removePunctuation = TRUE,
                                      removeNumbers = TRUE,
                                      wordLengths = c( 1, Inf) )
                      )

freq_unigram <- 
  tdm_unigram %>%
  as.matrix %>%
  rowSums

# write all unigrams to a list
# in order to create uniform levels of factors
unigram_levels <- unique(tdm_unigram$dimnames$Terms)

# trigram Term-Document Matrix
tdm_trigram <-
  vc_all %>%
  TermDocumentMatrix( control = list( removePunctuation = TRUE,
                                      removeNumbers = TRUE,
                                      wordLengths = c( 1, Inf),
                                      tokenize = trigram_token)
                      )

# aggregate frequencies
tdm_trigram %>%
  as.matrix %>%
  rowSums -> freq_trigram

# repeat by frequency
freq_trigram %<>%
  names %>%
  rep( times = freq_trigram )

# split the trigram into three columns
freq_trigram %<>%
  strsplit(split=" ")

# filter out those of less than three columns
freq_trigram <- do.call(rbind, 
                        Filter( length_is(3),
                                freq_trigram )
                        )


df_trigram <- data.frame(w1 = factor(freq_trigram[,1], levels = unigram_levels),
                         w2 = factor(freq_trigram[,2], levels = unigram_levels),
                         w3  = factor(freq_trigram[,3], levels = unigram_levels) )

tri_naiveBayes <- 
  naiveBayes( w3 ~ w1 + w2 ,
              df_trigram )

#save(tri_naiveBayes, unigram_levels, file = "tri_naiveBayes.RData")
save( df_trigram, unigram_levels, file = "freqdata.txt")

