require(pROC)

glm.probs <- predict(glm.tune.1, test.batch, type = "prob")
glm.ROC <- roc(response = test.batch$Survived,
               predictor = glm.probs$Survived,
               levels = levels(test.batch$Survived))

xgb.probs <- predict(xgb.tune, test.batch, type = "prob")
xgb.ROC <- roc(response = test.batch$Survived,
               predictor = xgb.probs$Survived,
               levels = levels(test.batch$Survived))

rf.probs <- predict(rf.tune, test.batch, type = "prob")
rf.ROC <- roc(response = test.batch$Survived,
              predictor = rf.probs$Survived,
              levels = levels(test.batch$Survived))

ctree.probs <- 1-unlist(treeresponse(ctree.tune, test.batch, OOB=T), 
                        use.names=F)[seq(1,nrow(test.batch)*2,2)]
ctree.ROC <- roc(response = test.batch$Survived,
                 predictor = ctree.probs,
                 levels = levels(test.batch$Survived))


# ploting ROC 
xgb.roc <- roc.prep(xgb.ROC)
rf.roc <- roc.prep(rf.ROC)
ctree.roc <- roc.prep(ctree.ROC)
glm.roc <- roc.prep(glm.ROC)

base <- ggplot()+scale_x_reverse()
xgb <- base + geom_line(data=xgb.roc, aes(y=sens, x=spec), colour='black')
rf <- xgb + geom_line(data=rf.roc, aes(y=sens, x=spec), colour='red')
ctree <- rf + geom_line(data=ctree.roc, aes(y=sens, x=spec), colour='blue')
glm <- ctree + geom_line(data=glm.roc, aes(y=sens, x=spec), colour='green')
g <- glm + labs(x="specificity",y="sensitivity")