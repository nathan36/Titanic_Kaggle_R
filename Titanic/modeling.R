require(caret)
require(party)
require(pROC)

# data partition
set.seed(23)
training.rows <- createDataPartition(train$Survived,
                                     p = 0.8, list = FALSE)
train.batch <- train[training.rows, ]
test.batch <- train[-training.rows, ]

# 3 fold cross validation
cv.ctrl <- trainControl(method = "repeatedcv", repeats = 3,
                        summaryFunction = twoClassSummary,
                        classProbs = TRUE)

# xgboost
xgb.grid <- expand.grid(nrounds = 500,
                        eta = c(0.1,0.01,0.001),
                        max_depth = c(2, 6, 10),
                        gamma = 1,
                        colsample_bytree = 1, 
                        min_child_weight = 1  
)                                

xgb.tune <- train(Survived ~.,
                  data = train.batch,
                  trControl = cv.ctrl,
                  tuneGrid = xgb.grid,
                  method ="xgbTree",
                  metric = "ROC"
)

xgb.probs <- predict(xgb.tune, test.batch, type = "prob")
xgb.ROC <- roc(response = test.batch$Survived,
               predictor = xgb.probs$Survived,
               levels = levels(test.batch$Survived))
plot(xgb.ROC, type="S")   

# logistic regression
Titanic.logit.1 <- glm(Survived ~ Sex + Class + Age + FamilySize + Embarked,
      data = train.batch, family=binomial("logit"))

# generalized liner model tuning
set.seed(35)
glm.tune.1 <- train(Survived ~ Sex + Class + Age + FamilySize + Embarked,
                    data = train.batch,
                    method = "glm",
                    metric = "ROC",
                    trControl = cv.ctrl)

glm.probs <- predict(glm.tune.1, test.batch, type = "prob")
glm.ROC <- roc(response = test.batch$Survived,
               predictor = glm.probs$Survived,
               levels = levels(test.batch$Survived))
plot(glm.ROC, add = T, col="green")   

# random forest
rf.grid <- data.frame(.mtry = c(2,3))
set.seed(35)
rf.tune <- train(Survived ~ Sex + Class + Age + FamilySize + Embarked,
                 data = train.batch,
                 method = "rf",
                 metric = "ROC",
                 tuneGrid = rf.grid,
                 trControl = cv.ctrl)

rf.probs <- predict(rf.tune, test.batch, type = "prob")
rf.ROC <- roc(response = test.batch$Survived,
               predictor = rf.probs$Survived,
               levels = levels(test.batch$Survived))
plot(rf.ROC, add = T, col="red")   

# conditional inference trees
set.seed(35)
ctree.tune <- cforest(as.factor(Survived) ~ Class + Sex + Age + Fare +
                                       Embarked + Title + FamilySize + FamilyID,
                 data = train.batch,
                 controls=cforest_unbiased(ntree=2000, mtry=3))

ctree.probs <- 1-unlist(treeresponse(ctree.tune, test.batch, OOB=T), 
                        use.names=F)[seq(1,nrow(test.batch)*2,2)]
ctree.ROC <- roc(response = test.batch$Survived,
              predictor = ctree.probs,
              levels = levels(test.batch$Survived))
plot(ctree.ROC, add = T, col="blue") 