readData <- function(file.path, column.types, missing.types) {
    read.csv(file=file.path, colClasses=column.types, na.strings=missing.types)
}
train.data.path <- "data/train.csv"
test.data.path <- "data/test.csv"
missing.types <- c("NA", "")
train.col.types <- c('integer',     # PassengerId
                     'factor',      # Survived
                     'factor',      # Pclass
                     'character',   # Name
                     'factor',      # Sex
                     'numeric',     # Age
                     'integer',     # SibSp
                     'integer',     # Parch
                     'character',   # Ticket
                     'numeric',     # Fare
                     'character',   # Cabin
                     'factor'       # Embarked
)
test.col.types <- train.col.types[-2]

train.data <- readData(train.data.path, train.col.types, missing.types)
df.train <- train.data

test.data <- readData(test.data.path, test.col.types, missing.types)
df.test <- test.data
#--------------------------------------------------------------------------

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
titles.na <- c("Dr", "Master", "Mr", "Mrs", "Miss", "Ms")
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
                               c("Capt","Col","Dona","Don","Dr",
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


# data partition
require(RSNNS)
require(caret)
require(neuralnet)

set.seed(23)
training.rows <- createDataPartition(train$Survived,
                                     p = 0.8, list = FALSE)
train.batch <- train[training.rows, ]
test.batch <- train[-training.rows, ]

# convert to dummy variables
train.batch.m <- model.matrix(~Survived+Sex+Boat.dibs+Age+Title+Class+Fare+Embarked+FamilySize, 
                    data=train.batch)
test.batch.m <- model.matrix(~Survived+Sex+Boat.dibs+Age+Title+Class+Fare+Embarked+FamilySize, 
                    data=test.batch)
test.m <- model.matrix(~Sex+Boat.dibs+Age+Title+Class+Fare+Embarked+FamilySize, 
                    data=test)

# train neural network
nn <- neuralnet(SurvivedSurvived~Sexmale+Boat.dibsYes+Age+TitleMiss+TitleMr+TitleMrs+TitleNoble
                    +ClassSecond+ClassThird+Fare+EmbarkedQ+EmbarkedS+FamilySize,
                data=train.batch.m, 
                hidden=2, 
                linear.output=FALSE)

# predict survivial
Survived <- round(compute(nn, test.m[,-1])$net.result)

# --------- working on rsnns mlp model ------------
# require(RSNNS)
# train.input <- as.matrix(train.batch[,-1])
# train.target <- as.matrix(train.batch[,1])
# test.input <- as.matrix(test.batch[,-1])
# test.target <- as.matrix(test.batch[,1])
# mlp.tune <- mlp(train.input, train.target)

# output result to csv
prediction <- data.frame(Survived)
prediction$PassengerId <- df.test$PassengerId
write.csv(prediction[,c("PassengerId","Survived")],
    file="Titanic_result.csv",row.names=FALSE)