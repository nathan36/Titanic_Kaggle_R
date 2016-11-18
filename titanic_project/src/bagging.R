library('ProjectTemplate'); load.project()
require(caret)
require(caretEnsemble)
require(pROC)

control <- trainControl(method="repeatedcv", number=10, 
                        repeats=3, classProbs = T)
seed <- 7
metric <- c("ROC")

# Bagged CART
set.seed(seed)
fit.treebag <- train(Survived~., data=train.set, 
                     method="treebag", 
                     metric=metric, 
                     trControl=control)

# Conditional Random Forest
set.seed(seed)
fit.rf <- train(Survived~., data=train.set, 
                method="cforest", 
                metric=metric, 
                trControl=control)

# summarize results
bagging_results <- resamples(list(treebag=fit.treebag, rf=fit.rf))