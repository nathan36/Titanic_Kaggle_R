library('ProjectTemplate'); load.project()

require(caret)
require(party)
require(pROC)

# 3 fold cross validation
cv.ctrl <- trainControl(method = "repeatedcv", repeats = 3,
                        summaryFunction = twoClassSummary,
                        classProbs = TRUE)

# random forest
rf.grid <- data.frame(.mtry = c(2,3))

set.seed(35)
rf.tune <- train(Survived ~ Sex + Class + Age + FamilySize + Embarked + FamilyID,
                 data = train.batch,
                 method = "rf",
                 metric = "ROC",
                 tuneGrid = rf.grid,
                 trControl = cv.ctrl)

rf.yhat <- predict(rf.tune, test.batch)

Survived <- predict(rf.tune, test.set)
predictions <- data.frame(Survived)
predictions$Survived <- revalue(predictions$Survived, c("Survived"="1","Perished"="0"))
rf.y <- predictions$Survived

# predictions$PassengerId <- test$PassengerId
# write.csv(predictions[,c("PassengerId","Survived")],
#           file="rf.csv",row.names=FALSE)