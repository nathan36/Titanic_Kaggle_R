# Example preprocessing script.
require(plyr)
require(stringr)
require(Hmisc)
require(caret)

train.raw <- train
test.raw <- test
rm(train,test);gc()

train.raw$Survived <- as.factor(train.raw$Survived)
train.raw$Pclass <- as.factor(train.raw$Pclass)
train.raw$Sex <- as.factor(train.raw$Sex)

test.raw$Pclass <- as.factor(test.raw$Pclass)
test.raw$Sex <- as.factor(test.raw$Sex)

cache('train.raw')
cache('test.raw')

# combine test and train data
test.raw$Survived <- NA
combine <- rbind(train.raw, test.raw)
combine$Title <- getTitle(combine)

# replace missing values in Age with median age on a per-title basis
titles.na <- c("Dr", "Master", "Mr", "Mrs", "Miss", "Ms")
combine$Age <- imputeMedian(combine$Age, combine$Title,
                             titles.na)

# replace missing values in Embarked with most common value
combine$Embarked[which(combine$Embarked=="")]<-'S'
combine$Embarked <- as.factor(combine$Embarked)

# replace missing values in Fare with median fare by Pclass
combine$Fare[ which( combine$Fare == 0 )] <- NA
combine$Fare <- imputeMedian(combine$Fare, combine$Pclass,
                              as.numeric(levels(combine$Pclass)))

# Title consolidation
combine$Title <- changeTitles(combine,
                               c("Capt","Col","Dona","Don","Dr",
                               "Jonkheer","Lady","Major",
                               "Rev","Sir"),
                               "Noble")
combine$Title <- changeTitles(combine, c("the Countess","Ms"),"Mrs")
combine$Title <- changeTitles(combine, c("Mlle","Mme"),"Miss")
combine$Title <- as.factor(combine$Title)

## add remaining features to training data frame
combine <- featureEngrg(combine)

col.keeps <- c("Survived", "Sex", "Boat.dibs", "Age", "Title",
                 "Class", "Fare", "Embarked", "FamilySize", "FamilyID")
combine <- combine[col.keeps]
cache('combine')

# split train and test data
train.set <- combine[1:891,]
test.set <- combine[892:1309,]

cache('train.set')
cache('test.set')

# # data partition
# set.seed(23)
# training.rows <- createDataPartition(train.set$Survived,
#                                      p = 0.8, list = FALSE)
# train.batch <- train.set[training.rows, ]
# test.batch <- train.set[-training.rows, ]

# cache('train.batch')
# cache('test.batch')