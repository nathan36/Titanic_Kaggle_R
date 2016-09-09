require(RSNNS)
require(caret)
require(neuralnet)

# data partition
set.seed(46)
training.rows <- createDataPartition(train$Survived,
                                 p = 0.8, list = FALSE)
train.batch <- train[training.rows, ]
test.batch <- train[-training.rows, ]

# convert to dummy variables
train.batch.m <- model.matrix(~Survived+Sex+Boat.dibs+Age+Title+Class+Fare+Embarked+FamilySize+FamilyID, 
                    data=train.batch)
test.batch.m <- model.matrix(~Survived+Sex+Boat.dibs+Age+Title+Class+Fare+Embarked+FamilySize+FamilyID, 
                    data=test.batch)
test.m <- model.matrix(~Sex+Boat.dibs+Age+Title+Class+Fare+Embarked+FamilySize+FamilyID, 
                    data=test)   

# trim column header
colnames(train.batch.m) <- make.names(colnames(train.batch.m), unique=T)
colnames(test.batch.m) <- make.names(colnames(test.batch.m), unique=T)
colnames(test.m) <- make.names(colnames(test.m), unique=T)

# create formula for neuralnet
title <- colnames(test.m)
title <- paste(title[-1], sep="", collapse="+")
fm <- paste("SurvivedSurvived", title, sep="~")                   

# train neural network
nn <- neuralnet(fm, data=train.batch.m, linear.output=FALSE)

# predict survivial
Survived <- round(compute(nn, test.m[,-1])$net.result)

# output result to csv
prediction <- data.frame(Survived)
prediction$PassengerId <- df.test$PassengerId
write.csv(prediction[,c("PassengerId","Survived")],
    file="Titanic_result.csv",row.names=FALSE)
    
# --------- incomplete rsnns mlp model ------------
# require(RSNNS)
# train.input <- as.matrix(train.batch[,-1])
# train.target <- as.matrix(train.batch[,1])
# test.input <- as.matrix(test.batch[,-1])
# test.target <- as.matrix(test.batch[,1])
# mlp.tune <- mlp(train.input, train.target)

