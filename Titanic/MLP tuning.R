require(rsnns)
require(caret)

# data partition
set.seed(23)
training.rows <- createDataPartition(train$Survived,
                                     p = 0.8, list = FALSE)
train.batch <- train[training.rows, ]
test.batch <- train[-training.rows, ]

train.input <- train.batch[,-1]
train.target <- train.batch[,1]
test.input <- test.batch[,-1]
test.target <- test.batch[,1]

mlp.tune <- mlp(train.input, train.target, size = 5, maxit = 50,
                inputsTest = test.input, targetsTest = test.target)

