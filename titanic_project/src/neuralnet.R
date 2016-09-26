library('ProjectTemplate'); load.project()

require(caret)
require(neuralnet)

nn.train.batch <- prepSet4nn(train.batch[,-ncol(train.batch)])
nn.test.batch <- prepSet4nn(test.batch[,-ncol(test.batch)])

nn.train.set <- prepSet4nn(train.set[,-ncol(train.set)], test=T)
nn.test.set <- prepSet4nn(test.set[,-ncol(test.set)], test=T)

# create formula for neuralnet
title <- paste(colnames(nn.train.batch)[-(1:2)], collapse = "+")
f <- paste("SurvivedSurvived", title, sep="~")

# train neural network
nn.tune <- neuralnet(f, data=nn.train.batch, hidden=c(5,3), stepmax=1e+09, linear.output=FALSE)

nn.yhat <- round(compute(nn.tune, nn.train.set[,-1])$net.result)

Survived <- round(compute(nn.tune, nn.test.set[,-1])$net.result)
prediction <- data.frame(Survived)
nn.y <- prediction$Survived

# prediction$PassengerId <- test.set$PassengerId
# write.csv(prediction[,c("PassengerId","Survived")],
#     file="nn.csv",row.names=FALSE)
    
