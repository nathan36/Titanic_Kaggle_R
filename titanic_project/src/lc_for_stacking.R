pred <- lapply(models, function(x){
    result <- x$pred
    result <- result[order(result$rowIndex),]
    result$prob <- result$pred
    result[, colnames(result) %in% c("prob")]
})

pred$obs <- models$gbm$pred[order(models$gbm$pred$rowIndex), "obs"]

pred.df <- data.frame(pred)

set.seed(sample(1:100, 1))

cv.ctrl <- trainControl(method='repeatedcv', repeats=3, classProbs=T)

plot_data <- learing_curve_dat(dat=pred.df,
                               outcome="obs",
                               method='glm',
                               trControl=cv.ctrl)

ggplot(plot_data, aes(x=Training_Size, y=Accuracy, color=Data)) +
  geom_smooth(span=.8, se=F) +
  theme_bw()
