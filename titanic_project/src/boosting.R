library('ProjectTemplate'); load.project()
require(caret)
require(caretEnsemble)
require(pROC)

control <- trainControl(method="repeatedcv", number=10, 
                        repeats=3, classProbs = T)
seed <- 7
metric <- c("ROC")

# C5.0
set.seed(seed)
fit.c50 <- train(Survived~., data=train.set, 
                 method="C5.0", 
                 metric=metric, 
                 trControl=control)

# Stochastic Gradient Boosting
set.seed(seed)
fit.gbm <- train(Survived~., data=train.set, 
                 method="gbm", 
                 metric=metric, 
                 trControl=control, 
                 verbose=FALSE)

# summarize results
boosting_results <- resamples(list(c5.0=fit.c50, gbm=fit.gbm))