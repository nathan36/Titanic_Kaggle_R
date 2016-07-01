require(pROC)

# create confusion matrix for each model
rf.pred <- predict(rf.tune, test.batch)
confusionMatrix(rf.pred, test.batch$FTR)

rf.pred.1 <- predict(rf.tune.1, test.batch)
confusionMatrix(rf.pred.1, test.batch$FTR)

svm.pred <- predict(svm.tune, test.batch)
confusionMatrix(svm.pred, test.batch$FTR)

svm.pred.1 <- predict(svm.tune.1, test.batch)
confusionMatrix(svm.pred.1, test.batch$FTR)

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

ogit.probs <- data.frame(logit.probs)
logit.ROC <- roc(response=test.batch$FTR,
            predictor=logit.probs$H,
            levels=levels(test.batch$FTR))
plot(logit.ROC, add=TRUE, col="black")