require(caret)
require(nnet)
require(doParallel)

# ------- create feature set for classification ----------

feature.set = cbind(data[,c("id", "loss","f776", "f777", "f778", "f2", "f4", "f5")], golden.features)

# add the first 200 columns from data #
feature.set = cbind(feature.set, data[,!(colnames(data) %in% c("id", "loss","f776", "f777", "f778", "f2", "f4", "f5"))])

# recode value in loss column
feature.set$loss = ifelse(feature.set[,"loss"]>0, "bad", "good")

# create train and test sets for the classification #
train = feature.set[is.na(feature.set$loss) == F,]
test = feature.set[is.na(feature.set$loss) == T,]

# -------------- model training ------------------------

# set partition cutoff
set.seed(35)
training.rows = createDataPartition(train$loss, p=2/3, list=FALSE)
train.batch = train[training.rows,1:200]
test.batch = train[-training.rows,1:200]

# create 10-fold corss-validation
cv.ctrl = trainControl(method = "repeatedcv", repeats=10,
                       summaryFunction = multiClassSummary,
                       classProbs = TRUE)

# random forest
cl <- makeCluster(detectCores()-1)
registerDoParallel(cl)
# ------------------------------------------------------
rf.grid = data.frame(.mtry=c(sqrt(ncol(train.batch))))

rf.tune = train(loss ~ ., data=train.batch[-1], method="parRF", metric="ROC",
                tuneGrid=rf.grid, trControl=cv.ctrl)
# ------------------------------------------------------
stopCluster(cl)

