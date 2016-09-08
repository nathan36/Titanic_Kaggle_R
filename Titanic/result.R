Survived <- predict(fit, test, OOB=TRUE, type = "response")
predictions <- data.frame(Survived)
predictions$Survived <- revalue(predictions$Survived, c("Survived"="1","Perished"="0"))
predictions$PassengerId <- df.test$PassengerId
write.csv(predictions[,c("PassengerId","Survived")],
    file="Titanic_pred.csv",row.names=FALSE)