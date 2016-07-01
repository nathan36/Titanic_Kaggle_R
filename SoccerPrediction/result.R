FTR <- predict(svm.tune, df.test)
Prediction <- data.frame(FTR)
Prediction$ID <- df.test$ID
write.csv(Prediction[,c("ID","FTR")],file="desktop/match_pred.csv",row.names=FALSE)

