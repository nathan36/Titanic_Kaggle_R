require(pROC)

# create confusion matrix for each model
rf.pred <- predict(rf.tune, test.batch)
confusionMatrix(rf.pred, test.batch$FTR)

svm.pred <- predict(svm.tune, test.batch)
confusionMatrix(svm.pred, test.batch$FTR)

ml.pred <- predict(ml.tune, test.batch)
confusionMatrix(ml.pred, test.batch$FTR)

# plot the ROC curve for each model
rf.probs <- predict(rf.tune, test.batch, type = "prob")
rf.ROC <- roc(response = test.batch$FTR,
            predictor = rf.probs$H,
            levels = levels(test.batch$FTR))
plot(rf.ROC, col="red", type="S")

svm.probs <- predict(svm.tune, test.batch, type = "prob")
svm.ROC <- roc(response = test.batch$FTR,
            predictor = svm.probs$H,
            levels = levels(test.batch$FTR))
plot(svm.ROC, add=TRUE, col="green")

ml.probs <- predict(ml.tune, test.batch, type = "prob")
ml.ROC <- roc(response=test.batch$FTR,
            predictor=ml.probs$H,
            levels=levels(test.batch$FTR))
plot(ml.ROC, add=TRUE, col="black")