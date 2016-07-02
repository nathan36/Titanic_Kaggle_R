Survived <- predict(fit, test, OOB=TRUE, type = "response")
predictions <- data.frame(Survived)
predictions$PassengerId <- df.test$PassengerId
write.csv(predictions[,c("PassengerId","Survived")],
    file="desktop/Titanic_pred.csv",row.names=FALSE)
