require(caret)

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

# random forest
rf.tune <- train(FTR ~ B365H + B365A + BWH + BWA + IWH + IWA + LBH + LBA +
    WHH + WHA + VCH + VCA + D.mean,
    data=train.batch,
    method="rf",
    metric="ROC",
    tuneGrid=rf.grid,
    trControl=cv.ctrl)