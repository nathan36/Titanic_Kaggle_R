library('ProjectTemplate'); load.project()

require(caret)
require(party)

# 3 fold cross validation
cv.ctrl <- trainControl(method = "repeatedcv", repeats = 3,
                        summaryFunction = twoClassSummary,
                        classProbs = TRUE)

# generalized liner model tuning
set.seed(35)

glm.tune <- train(Survived ~ .,
                    data = train.batch,
                    method = "glm",
                    metric = "ROC",
                    trControl = cv.ctrl)

glm.yhat <- predict(glm.tune, train.set)

Survived <- predict(glm.tune, test.set)
predictions <- data.frame(Survived)
predictions$Survived <- revalue(predictions$Survived, c("Survived"="1","Perished"="0"))
glm.y <- predictions$Survived

# predictions$PassengerId <- test$PassengerId
# write.csv(predictions[,c("PassengerId","Survived")],
#           file="reports/glm.csv",row.names=FALSE)