# library('ProjectTemplate'); load.project()
require(doParallel)

L1Feature.set <- data.frame(glm.yhat, cforest.yhat, nn.yhat, 
                            rf.yhat, xgb.yhat, y=test.batch$Survived)

for(i in 1:ncol(L1Feature.set)){
  x <- colnames(L1Feature.set)[i]
  L1Feature.set[,i] <- revalue(L1Feature.set$x, c("Perished"="0","Survived"="1"))
}

#L1Feature.set <- sapply(L1Feature.set, function(x) revalue(L1Feature.set, c("Survived"=1, "Perished"=0)))

L1Test.set <- data.frame(glm.yhat=glm.y, cforest.yhat=cforest.y,
                         nn.yhat=as.factor(nn.y), rf.yhat=rf.y, xgb.yhat=xgb.y)

cl <- makeCluster(detectCores()-1)
registerDoParallel(cl)

avNN.tune <- avNNet(y ~ ., data=L1Feature.set, size=8)

stopCluster(cl)
registerDoSEQ()

Survived <- predict(avNN.tune, L1Test.set, type="class")
predictions <- data.frame(Survived)
predictions$PassengerId <- test$PassengerId
write.csv(predictions[,c("PassengerId","Survived")],
          file="result.csv", row.names=F)
