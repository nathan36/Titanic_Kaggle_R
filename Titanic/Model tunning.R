require(caret)

# logistic Regression
set.seed(23)
training.rows <- createDataPartition(df.train.munged$Survived,
                                     p = 0.8, list = FALSE)
train.batch <- df.train.munged[training.rows, ]
test.batch <- df.train.munged[-training.rows, ]

Titanic.logit.1 <- glm(Survived ~ Sex + Class + Age + Family + Embarked,
      data = train.batch, family=binomial("logit"))

cv.ctrl <- trainControl(method = "repeatedcv", repeats = 3,
                        summaryFunction = twoClassSummary,
                        classProbs = TRUE)

# generalized liner model tuning
set.seed(35)
glm.tune.1 <- train(Survived ~ Sex + Class + Age + Family + Embarked,
                    data = train.batch,
                    method = "glm",
                    metric = "ROC",
                    trControl = cv.ctrl)

# random forest
rf.grid <- data.frame(.mtry = c(2,3))
set.seed(35)
rf.tune <- train(Survived ~ Sex + Class + Age + Family + Embarked,
                 data = train.batch,
                 method = "rf",
                 metric = "ROC",
                 tuneGrid = rf.grid,
                 trControl = cv.ctrl)

# conditional inference trees
set.seed(35)
fit <- cforest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare +
                                       Embarked + Title + FamilySize + FamilyID,
                 data = train,
                 controls=cforest_unbiased(ntree=2000, mtry=3))