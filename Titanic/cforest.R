require(caret)
require(party)
require(pROC)

cv.ctrl <- cforest_unbiased(ntree=2000, mtry=3)

# conditional inference trees
set.seed(35)

ctree.tune <- cforest(as.factor(Survived) ~ Class + Sex + Age + 
                      Fare + Embarked + Title + FamilySize + FamilyID,
                      data = train.batch,
                      controls=cv.ctrl
)

Survived <- predict(ctree.tune, test, OOB=T)
predictions <- data.frame(Survived)
predictions$Survived <- revalue(predictions$Survived, c("Survived"="1","Perished"="0"))
predictions$PassengerId <- df.test$PassengerId
write.csv(predictions[,c("PassengerId","Survived")],
          file="cforest.csv",row.names=FALSE)