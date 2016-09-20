require(caret)
require(party)

# 3 fold cross validation
cv.ctrl <- trainControl(method = "repeatedcv", repeats = 3,
                        summaryFunction = twoClassSummary,
                        classProbs = TRUE)

# logistic regression
Titanic.logit.1 <- glm(Survived ~ Sex + Class + Age + FamilySize + Embarked,
      data = train.batch, family=binomial("logit"))

# generalized liner model tuning
set.seed(35)

glm.tune.1 <- train(Survived ~ Sex + Class + Age + FamilySize + Embarked,
                    data = train.batch,
                    method = "glm",
                    metric = "ROC",
                    trControl = cv.ctrl)

Survived <- predict(glm.tune.1, test)
predictions <- data.frame(Survived)
predictions$Survived <- revalue(predictions$Survived, c("Survived"="1","Perished"="0"))
predictions$PassengerId <- df.test$PassengerId
write.csv(predictions[,c("PassengerId","Survived")],
          file="glm.csv",row.names=FALSE)