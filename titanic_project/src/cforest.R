library('ProjectTemplate'); load.project()

require(caret)
require(party)
require(pROC)

ctree.grid <- data.frame(.mtry=sqrt(ncol(train.set)-1))

cv.ctrl <- trainControl(method = "repeatedcv", repeats = 3,
                        summaryFunction = twoClassSummary,
                        classProbs = TRUE)

# conditional inference trees
set.seed(35)

ctree.tune <- train(Survived ~ ., 
                    data = train.set,
                    metric="ROC",
                    method="cforest",
                    tuneGrid=ctree.grid,
                    trControl=cv.ctrl)

# cforest.yhat <- predict(ctree.tune, train.set, OOB=T)
# 
# Survived <- predict(ctree.tune, test.set, OOB=T)
# predictions <- data.frame(Survived)
# predictions$Survived <- revalue(predictions$Survived, c("Survived"="1","Perished"="0"))
# cforest.y <- predictions$Survived

# predictions$PassengerId <- test$PassengerId
# write.csv(predictions[,c("PassengerId","Survived")],
#           file="cforest.csv",row.names=FALSE)