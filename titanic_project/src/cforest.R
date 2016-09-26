library('ProjectTemplate'); load.project()

require(caret)
require(party)
require(pROC)

cv.ctrl <- cforest_unbiased(ntree=2000, mtry=3)

# conditional inference trees
set.seed(35)

ctree.tune <- cforest(Survived ~ Class + Sex + Age + 
                      Fare + Embarked + Title + FamilySize + FamilyID,
                      data = train.batch,
                      controls=cv.ctrl
)

cforest.yhat <- predict(ctree.tune, train.set, OOB=T)

Survived <- predict(ctree.tune, test.set, OOB=T)
predictions <- data.frame(Survived)
predictions$Survived <- revalue(predictions$Survived, c("Survived"="1","Perished"="0"))
cforest.y <- predictions$Survived

# predictions$PassengerId <- test$PassengerId
# write.csv(predictions[,c("PassengerId","Survived")],
#           file="cforest.csv",row.names=FALSE)