require(plyr)
require(stringr)
require(Hmisc)

getTitle <- function(data) {
  title.dot.start <- regexpr("\\,[A-Z ]{1,20}\\.", data$Name, TRUE)
  title.comma.end <- title.dot.start+
        attr(title.dot.start, "match.length")-1
  data$Title <- substr(data$Name, title.dot.start+2, title.comma.end-1)
  return (data$Title)
}

df.train$Title <- getTitle(df.train)
unique(df.train$Title)

# function for replacing missing values in features
imputeMedian <- function(impute.var, filter.var, var.levels) {
    for (v in var.levels) {
        impute.var[which(filter.var == v)] <- impute(impute.var[
            which(filter.var == v)])
    }
    return(impute.var)
}

# replace missing values in Age with median age on a per-title basis
titles.na.train <- c("Dr", "Master", "Mr", "Mrs", "Miss")
df.train$Age <- imputeMedian(df.train$Age, df.train$Title,
                             titles.na.train)

# replace missing values in Embarked with most common value
df.train$Embarked[which(is.na(df.train$Embarked))]<-'S'

# replace missing values in Fare with median fare by Pclass
df.train$Fare[ which( df.train$Fare == 0 )] <- NA
df.train$Fare <- imputeMedian(df.train$Fare, df.train$Pclass,
                              as.numeric(levels(df.train$Pclass)))

# function for assigning new title value to old title
changeTitles <- function(data, old.titles, new.title) {
    for (honorific in old.titles) {
        data$Title[which(data$Title == honorific)] <- new.title
    }
    return(data$Title)
}

# Title consolidation
df.train$Title <- changeTitles(df.train,
                               c("Capt","Col","Don","Dr",
                               "Jonkheer","Lady","Major",
                               "Rev","Sir"),
                               "Noble")
df.train$Title <- changeTitles(df.train, c("the Countess","Ms"),"Mrs")
df.train$Title <- changeTitles(df.train, c("Mlle","Mme"),"Miss")
df.train$Title <- as.factor(df.train$Title)

## test a character as an EVEN single digit
isEven <- function(x) x %in% c("0","2","4","6","8")
## test a character as an ODD single digit
isOdd <- function(x) x %in% c("1","3","5","7","9")

## function to add features to training or test data frames
featureEngrg <- function(data) {
  ## Using Fate ILO Survived because term is shorter and just sounds good
  data$Fate <- data$Survived
  ## Revaluing Fate factor to ease assessment of confusion matrices later
  data$Fate <- revalue(data$Fate, c("1" = "Survived", "0" = "Perished"))
  ## Boat.dibs attempts to capture the "women and children first"
  ## policy in one feature.  Assuming all females plus males under 15
  ## got "dibs' on access to a lifeboat
  data$Boat.dibs <- "No"
  data$Boat.dibs[which(data$Sex == "female" | data$Age < 15)] <- "Yes"
  data$Boat.dibs <- as.factor(data$Boat.dibs)
  ## Family consolidates siblings and spouses (SibSp) plus
  ## parents and children (Parch) into one feature
  data$Family <- data$SibSp + data$Parch
  ## Fare.pp attempts to adjust group purchases by size of family
  data$Fare.pp <- data$Fare/(data$Family + 1)
  ## Giving the traveling class feature a new look
  data$Class <- data$Pclass
  data$Class <- revalue(data$Class,
                        c("1"="First", "2"="Second", "3"="Third"))
  ## First character in Cabin number represents the Deck
  data$Deck <- substring(data$Cabin, 1, 1)
  data$Deck[ which( is.na(data$Deck ))] <- "UNK"
  data$Deck <- as.factor(data$Deck)
  ## Odd-numbered cabins were reportedly on the port side of the ship
  ## Even-numbered cabins assigned Side="starboard"
  data$cabin.last.digit <- str_sub(data$Cabin, -1)
  data$Side <- "UNK"
  data$Side[which(isEven(data$cabin.last.digit))] <- "port"
  data$Side[which(isOdd(data$cabin.last.digit))] <- "starboard"
  data$Side <- as.factor(data$Side)
  data$cabin.last.digit <- NULL
  return (data)
}

## add remaining features to training data frame
df.train <- featureEngrg(df.train)

train.keeps <- c("Fate", "Sex", "Boat.dibs", "Age", "Title",
                 "Class", "Deck", "Side", "Fare", "Fare.pp",
                 "Embarked", "Family")
df.train.munged <- df.train[train.keeps]
