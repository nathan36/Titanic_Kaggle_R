library('ProjectTemplate'); load.project()

require(caret)
require(party)
require(pROC)

# 3 fold cross validation
cv.ctrl <- trainControl(method = "repeatedcv", repeats = 3,
                        summaryFunction = twoClassSummary,
                        classProbs = TRUE)

# xgboost
xgb.grid <- expand.grid(nrounds = 500,
                        eta = 0.01,
                        max_depth = 10,
                        gamma = 2,
                        colsample_bytree = 0.5, 
                        min_child_weight = 1  
)                                

xgb.tune <- train(Survived ~.,
                  data = train.batch,
                  trControl = cv.ctrl,
                  tuneGrid = xgb.grid,
                  method ="xgbTree",
                  metric = "ROC"
)

xgb.yhat <- predict(xgb.tune, train.set)

Survived <- predict(xgb.tune, test.set)
predictions <- data.frame(Survived)
predictions$Survived <- revalue(predictions$Survived, c("Survived"="1","Perished"="0"))
xgb.y <- predictions$Survived

# predictions$PassengerId <- test$PassengerId
# write.csv(predictions[,c("PassengerId","Survived")],
#           file="xgb.csv",row.names=FALSE)