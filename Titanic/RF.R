require(caret)

rf.grid <- data.frame(.mtry = c(2,3))
set.seed(35)
rf.tune <- train(Fate ~ Sex + Class + Age + Family + Embarked,
                 data = train.batch,
                 method = "rf"
                 metric = "ROC",
                 tuneGrid = rf.grid,
                 trContorl = cv.ctrl)