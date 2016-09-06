require(plyr)
require(stringr)
require(Hmisc)

# function for extracting title for name
getTitle <- function(data) {
  title.dot.start <- regexpr("\\,[A-Z ]{1,20}\\.", data$Name, TRUE)
  title.comma.end <- title.dot.start + attr(title.dot.start, "match.length")-1
  data$Title <- substr(data$Name, title.dot.start+2, title.comma.end-1)
  return (data$Title)
}

# function for replacing missing values in features
imputeMedian <- function(impute.var, filter.var, var.levels) {
    for (v in var.levels) {
        impute.var[which(filter.var == v)] <- impute(impute.var[
            which(filter.var == v)])
    }
    return(impute.var)
}

# combine test and train data
df.test$Survived <- NA
combine <- rbind(df.train, df.test)
combine$Title <- getTitle(combine)

# replace missing values in Age with median age on a per-title basis
titles.na <- c("Dr", "Master", "Mr", "Mrs", "Miss")
combine$Age <- imputeMedian(combine$Age, combine$Title,
                             titles.na)

# replace missing values in Embarked with most common value
combine$Embarked[which(is.na(combine$Embarked))]<-'S'

# replace missing values in Fare with median fare by Pclass
combine$Fare[ which( combine$Fare == 0 )] <- NA
combine$Fare <- imputeMedian(combine$Fare, combine$Pclass,
                              as.numeric(levels(combine$Pclass)))

# function for assigning new title value to old title
changeTitles <- function(data, old.titles, new.title) {
    for (honorific in old.titles) {
        data$Title[which(data$Title == honorific)] <- new.title
    }
    return(data$Title)
}

# Title consolidation
combine$Title <- changeTitles(combine,
                               c("Capt","Col","Don","Dr",
                               "Jonkheer","Lady","Major",
                               "Rev","Sir"),
                               "Noble")
combine$Title <- changeTitles(combine, c("the Countess","Ms"),"Mrs")
combine$Title <- changeTitles(combine, c("Mlle","Mme"),"Miss")
combine$Title <- as.factor(combine$Title)

# function to add features to training or test data frames
featureEngrg <- function(data) {
  data$Survived <- revalue(data$Survived, c("1"="Survived","0"="Perished"))
  # Boat.dibs attempts to capture the "women and children first"
  data$Boat.dibs <- "No"
  data$Boat.dibs[which(data$Sex == "female" | data$Age < 15)] <- "Yes"
  data$Boat.dibs <- as.factor(data$Boat.dibs)
  # Collapsing siblings and spo(SibSp) into one featureuses
  data$FamilySize <- data$SibSp + data$Parch + 1
  # Group related family by surname
  data$Surname <- sapply(data$Name,
                FUN=function(x) {strsplit(x, split='[,.]')[[1]][1]})
  data$FamilyID <- paste(as.character(data$FamilySize), data$Surname, sep="")
  data$FamilyID[data$FamilySize <= 2] <- 'Small'
  famIDs <- data.frame(table(data$FamilyID))
  famIDs <- famIDs[famIDs$Freq <= 2,]
  data$FamilyID[data$FamilyID %in% famIDs$Var1] <- 'Small'
  data$FamilyID <- factor(data$FamilyID)
  # Giving the traveling class feature a new look
  data$Class <- data$Pclass
  data$Class <- revalue(data$Class,
                        c("1"="First", "2"="Second", "3"="Third"))
  return (data)
}

## add remaining features to training data frame
combine <- featureEngrg(combine)

col.keeps <- c("Survived", "Sex", "Boat.dibs", "Age", "Title",
                 "Class", "Fare", "Embarked", "FamilySize", "FamilyID")
combine <- combine[col.keeps]

# split train and test data
train <- combine[1:891,]
test <- combine[892:1309,]
