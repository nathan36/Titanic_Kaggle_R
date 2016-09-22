# Example preprocessing script.
require(plyr)
require(stringr)
require(Hmisc)
require(caret)

train$Survived <- as.factor(train$Survived)
train$Pclass <- as.factor(train$Pclass)
test$Pclass <- as.factor(test$Pclass)

cache('train')
cache('test')

# combine test and train data
test$Survived <- NA
combine <- rbind(train, test)
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

# split train and test data
train.set <- combine[1:891,]
test.set <- combine[892:1309,]

cache('train.set')
cache('test.set')

# data partition
set.seed(23)
training.rows <- createDataPartition(train.set$Survived,
                                     p = 0.8, list = FALSE)
train.batch <- train.set[training.rows, ]
test.batch <- train.set[-training.rows, ]

cache('train.batch')
cache('test.batch')