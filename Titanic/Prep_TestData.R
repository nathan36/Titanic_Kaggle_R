# get titles
df.test$Title <- getTitle(df.test)

# impute missing Age values
df.test$Title <- changeTitles(df.test, c("Dona", "Ms"), "Mrs")
titles.na.test <- c("Master", "Mrs", "Miss", "Mr")
df.test$Age <- imputeMedian(df.test$Age, df.test$Title, titles.na.test)

# consolidate titles
df.test$Title <- changeTitles(df.test, c("Col", "Dr", "Rev"), "Noble")
df.test$Title <- changeTitles(df.test, c("Mlle", "Mme"), "Miss")
df.test$Title <- as.factor(df.test$Title)

# impute missing fares
df.test$Fare[ which( df.test$Fare == 0)] <- NA
df.test$Fare <- imputeMedian(df.test$Fare, df.test$Pclass,
                                as.numeric(levels(df.test$Pclass)))
# add the other features
df.test <- featureEngrg(df.test)

# data prepped for predictions
test.keeps <- train.keeps[-1]
test <- df.test[test.keeps]