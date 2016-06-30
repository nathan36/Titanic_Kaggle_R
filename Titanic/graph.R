require(Amelia)
require(corrgram)
require(plyr)

missmap(df.train, main="Training Data - Missings Map",
        col=c("yellow", "black"), legend=FALSE)

corrgram.data <- df.train

corrgram.data$Survived <- as.numeric(corrgram.data$Survived)
corrgram.data$Pclass <- as.numeric(corrgram.data$Pclass)
corrgram.data$Embarked <- revalue(corrgram.data$Embarked,
                                  c("C"=1, "Q"=2, "S"=3))

corrgram.vars <- c("Survived", "Pclass", "Sex", "Age",
                   "SibSp", "Parch", "Fare", "Embarked")
corrgram(corrgram.data[,corrgram.vars], order=FALSE,
         lower.panel=panel.ellipse, upper.panel=panel.pie,
         text.panel=panel.txt, main="Training Data")