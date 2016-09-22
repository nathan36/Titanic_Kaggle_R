library('ProjectTemplate'); load.project()

require(doParallel)

cl <- makeCluster(detectCores()-1)
registerDoParallel(cl)

nn <- avNNet(formula=fm, data=train.batch.m, size=8)

stopCluster(cl)
