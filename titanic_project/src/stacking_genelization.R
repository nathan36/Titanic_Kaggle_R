library('ProjectTemplate'); load.project()
require(caret)
require(caretEnsemble)
require(pROC)
require(plyr)

control <- trainControl(method="repeatedcv", number=10, 
                        repeats=3, classProbs = T)
seed <- 7
metric <- c("ROC")
algorithmList <- c("C5.0", "gbm", "treebag", "rf", "rpart", "svmRadial")

# stacking models
models <- caretList(Survived~., data=train.set,
                    metric=metric,
                    trControl=control, 
                    methodList=algorithmList)

results <- resamples(models)

require(caret)
require(caretEnsemble)

# correlation between results, exclude if > 0.75
modelCor(results)
splom(results)

seed <- 7
metric <- c("ROC")
stackControl <- trainControl(method="repeatedcv", number=10, repeats=3, 
                             savePredictions=TRUE, classProbs=TRUE)
# stack using glm
set.seed(seed)
stack.glm <- caretStack(models, 
                        method="glm", 
                        metric=metric, 
                        trControl=stackControl)

# stack using rf
set.seed(seed)
stack.rf <- caretStack(models, 
                       method="rf", 
                       metric=metric, 
                       trControl=stackControl)

# plot_data <- learing_curve_dat(dat=models,
#                                outcome=Survived,
#                                trControl=stackControl,
#                                metric=metric)

pred <- predict(stack.glm, test.set)
pred <- revalue(pred, c("Perished"=0, "Survived"=1))
submission <- data.frame(PassengerId=test.raw$PassengerId, Survived=pred)
write.csv(submission, file='glm_stack.csv', row.names = F)
