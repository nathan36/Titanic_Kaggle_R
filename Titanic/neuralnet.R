require(RSNNS)
require(caret)
require(neuralnet)

# data partition
set.seed(46)
training.rows <- createDataPartition(train$Survived,
                                 p = 0.8, list = FALSE)
train.batch <- train[training.rows, ]
test.batch <- train[-training.rows, ]

# standardize data
train.batch[,c("Age","Fare")] <- scale(train.batch[,c("Age","Fare")])
test.batch[,c("Age","Fare")] <- scale(test.batch[,c("Age","Fare")])
test[,c("Age","Fare")] <- scale(test[,c("Age","Fare")])

# convert to dummy variables
train.batch.m <- model.matrix(~., data = train.batch[,1:ncol(train.batch)-1])
test.batch.m <- model.matrix(~., data = test.batch[,1:ncol(test.batch)-1])
test.m <- model.matrix(~., data = test[,!(colnames(test) %in% c("Survived", "FamilyID"))])  

# trim column header
colnames(train.batch.m) <- make.names(colnames(train.batch.m), unique=T)
colnames(test.batch.m) <- make.names(colnames(test.batch.m), unique=T)
colnames(test.m) <- make.names(colnames(test.m), unique=T)

# create formula for neuralnet
title <- paste(colnames(test.m)[-1], collapse = "+")
f <- paste("SurvivedSurvived", title, sep="~")

# train neural network
fit.nn <- neuralnet(f, data=train.batch.m, hidden=c(5,3), stepmax=1e+09, linear.output=FALSE)

# # predict survivial
# Survived <- round(compute(nn, test.m[,-1])$net.result)
# 
# # output result to csv
# prediction <- data.frame(Survived)
# prediction$PassengerId <- df.test$PassengerId
# write.csv(prediction[,c("PassengerId","Survived")],
#     file="Titanic_result.csv",row.names=FALSE)
    
# --------- incomplete rsnns mlp model ------------
# require(RSNNS)
# train.input <- as.matrix(train.batch[,-1])
# train.target <- as.matrix(train.batch[,1])
# test.input <- as.matrix(test.batch[,-1])
# test.target <- as.matrix(test.batch[,1])
# mlp.tune <- mlp(train.input, train.target)

