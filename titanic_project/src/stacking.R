library('ProjectTemplate'); load.project()
require(caret)
require(caretEnsemble)
require(pROC)

# create submodels
seed <- 7
metric <- c("ROC")
control <- trainControl(method="repeatedcv", number=10, repeats=3, 
                        savePredictions='final', classProbs=TRUE)

algorithmList <- c('glmnet','rpart', 'glm', 'knn', 'svmRadial')

set.seed(seed)
models <- caretList(Survived~., data=train.set,
                    metric=metric,
                    trControl=control, 
                    methodList=algorithmList)

results <- resamples(models)
summary(results)
dotplot(results)

# glmnet
fit.glmnet <- models$glmnet