require(plyr)
require(caret)
require(neuralnet)

# ------------- calculating SSE ---------------
cv.error <- NULL
k <- 10

# creating a progress bar
pbar <- create_progress_bar('text')
pbar$init(k)

# 10-fold cross-validation
for (i in 1:k){
    set.seed(sample(1:100, 1))
    training.rows <- createDataPartition(train$Survived,
                                     p = 0.8, list = FALSE)
    train.batch <- train[training.rows, ]
    test.batch <- train[-training.rows, ]

    train.batch.m <- model.matrix(~Survived+Sex+Boat.dibs+Age+Title+Class+Fare+Embarked+FamilySize, 
                        data=train.batch)
    test.batch.m <- model.matrix(~Survived+Sex+Boat.dibs+Age+Title+Class+Fare+Embarked+FamilySize, 
                        data=test.batch)
                        
    nn <- neuralnet(SurvivedSurvived~Sexmale+Boat.dibsYes+Age+TitleMiss+TitleMr+TitleMrs+TitleNoble
                        +ClassSecond+ClassThird+Fare+EmbarkedQ+EmbarkedS+FamilySize,
                    data=train.batch.m,
                    linear.output=FALSE)
        
    cv.error[i] <- nn$result.matrix[1]
    
    pbar$step()
}

png("SSE Graph.png")
plot(c(1:10), cv.error, type="n", xlab='SSE CV')
lines(c(1:10), cv.error)
dev.off()
