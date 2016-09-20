require(plyr)
require(stringr)
require(Hmisc)

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
train <- combine[1:891,]
test <- combine[892:1309,]

# data partition
set.seed(23)
training.rows <- createDataPartition(train$Survived,
                                     p = 0.8, list = FALSE)
train.batch <- train[training.rows, ]
test.batch <- train[-training.rows, ]