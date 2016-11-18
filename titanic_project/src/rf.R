library('ProjectTemplate'); load.project()

require(caret)
require(party)
require(pROC)

combine$FamilyID2 <- combine$FamilyID
combine$FamilyID2 <- as.character(combine$FamilyID2)
combine$FamilyID2[combine$FamilySize <= 3] <- 'Small'
combine$FamilyID2 <- factor(combine$FamilyID2)
combine$FamilyID <- NULL

train.set <- combine[1:891,]
test.set <- combine[892:1309,]

# 3 fold cross validation
cv.ctrl <- trainControl(method = "repeatedcv", repeats = 3,
                        summaryFunction = twoClassSummary,
                        classProbs = TRUE)

# random forest
rf.grid <- data.frame(.mtry = c(sqrt(ncol(train.set))))

set.seed(35)
rf.tune <- train(Survived ~ .,
                 data = train.set,
                 method = "rf",
                 metric = "ROC",
                 tuneGrid = rf.grid,
                 trControl = cv.ctrl)

rf.yhat <- predict(rf.tune, train.set)

Survived <- predict(rf.tune, test.set)
predictions <- data.frame(Survived)
predictions$Survived <- revalue(predictions$Survived, c("Survived"="1","Perished"="0"))
rf.y <- predictions$Survived

# predictions$PassengerId <- test$PassengerId
# write.csv(predictions[,c("PassengerId","Survived")],
#           file="rf.csv",row.names=FALSE)