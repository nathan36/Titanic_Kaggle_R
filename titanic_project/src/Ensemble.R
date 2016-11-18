 library('ProjectTemplate'); load.project()

L1Train.set <- data.frame(glm.yhat, cforest.yhat, 
                            rf.yhat, xgb.yhat, y=train.set$Survived)

# L1Train.set$nn.yhat <- as.factor(L1Train.set$nn.yhat)
# L1Train.set$nn.yhat  <- revalue(L1Train.set$nn.yhat, 
#                                 c("0"="Perished","1"="Survived"))

#L1Train.set <- sapply(colnames(L1Train.set), function(x){revalue(L1Feature.set[[x]], c("Survived"=1, "Perished"=0))})

L1Test.set <- data.frame(glm.yhat=glm.y, cforest.yhat=cforest.y,
                         rf.yhat=rf.y, xgb.yhat=xgb.y)

for(i in 1:ncol(L1Test.set)){
  L1Test.set[,i] <- revalue(L1Test.set[,i], c("0"="Perished","1"="Survived"))
}

cv.ctrl <- trainControl(method = "repeatedcv", repeats = 3,
                        summaryFunction = twoClassSummary,
                        classProbs = TRUE)

L1nn.tune <- train(y~., data=L1Train.set,
                   metric="ROC",
                   method="nnet",
                   tuneGrid=data.frame(size=8, decay=0),
                   trControl=cv.ctrl
)

cv <- t(data.frame(ctree.tune$results$ROC, glm.tune$results$ROC,
                   rf.tune$results$ROC, xgb.tune$results$ROC, 
                   L1nn.tune$results$ROC))

Survived <- predict(L1nn.tune, L1Test.set, type="raw")
predictions <- data.frame(Survived)
predictions$Survived <- revalue(predictions$Survived, 
                                c("Perished"="0","Survived"="1"))
predictions$PassengerId <- test$PassengerId
write.csv(predictions[,c("PassengerId","Survived")],
          file="result.csv", row.names=F)
