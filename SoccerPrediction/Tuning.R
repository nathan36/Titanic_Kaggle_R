require(caret)
require(nnet)

# create 10-fold corss-validation
cv.ctrl <- trainControl(method = "repeatedcv", repeats=3,
                        summaryFunction = multiClassSummary,
                        classProbs = TRUE)

# split training data into train batch and test batch
set.seed(23)
training.rows <- createDataPartition(df.train$FTR,
                                     p = 0.8, list = FALSE)
train.batch <- df.train[training.rows, ]
test.batch <- df.train[-training.rows, ]

# multinominal logistic regression
logit <- multinom(FTR ~ B365H_H.mean + B365A_A.mean + B365D.D.mean, train.batch)
logit.1 <- multinom(FTR ~ B365H + B365A + B365D + H.mean + A.mean + D.mean, train.batch)

# random forest
rf.grid <- data.frame(.mtry=c(2.3,2.4,2.5))

set.seed(35)
rf.tune <- train(FTR ~ B365H + B365A + B365D + H.mean + A.mean + D.mean,
    data=train.batch,
    method="rf",
    metric="Mean_ROC",
    tuneGrid=rf.grid,
    trControl=cv.ctrl)

# svm
set.seed(35)
svm.tune <- train(FTR ~ B365H + B365A + B365D + H.mean + A.mean + D.mean,
    data=train.batch,
    method="svmRadial",
    tuneLength=9,
    preProcess=c("center","scale"),
    metric="Mean_ROC",
    trControl=cv.ctrl)


# # ada boosting
# ada.grid <- expand.grid(.iter = c(50, 100),
#                         .maxdepth = c(4, 8),
#                         .nu = c(0.1, 1))
#
# set.seed(35)
# ada.tune <- train(FTR ~ B365H + B365A + B365D + H.mean + A.mean + D.mean,
#     data=train.batch,
#     method="ada",
#     metric="Mean_ROC",
#     tuneGrid=ada.grid,
#     trControl=cv.ctrl)

