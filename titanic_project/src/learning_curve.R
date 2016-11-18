set.seed(28)

cv.ctrl <- trainControl(method = "cv",
                        summaryFunction = twoClassSummary,
                        classProbs = TRUE)

n <- ncol(train.set)

plot_data <- learing_curve_dat(dat=train.set[,-n],
                               outcome="Survived",
                               metric="ROC",
                               method="glm",
                               trControl=cv.ctrl
)

ggplot(plot_data, aes(x = Training_Size, y = ROC, color = Data)) + 
  scale_y_reverse() +
  geom_smooth(span = 1, se=F) + 
  theme_bw()
