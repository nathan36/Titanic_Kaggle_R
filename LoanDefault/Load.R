# load data
setwd("./desktop/LoanPrediction/data")
train = read.csv("train_v2.csv", stringsAsFactors = F, header = T)
test = read.csv("test_v2.csv", stringsAsFactors = F, header = T)
test$loss = NA

# combine train and test set for data munging
data = rbind(train, test)

# remove duplicate columns based on the first 25000 rows
data = data[!duplicated(as.list(data[1:25000,]))]

# correct f4
data$f4 = data$f4/100

save(data, file = "data_raw.RData")

