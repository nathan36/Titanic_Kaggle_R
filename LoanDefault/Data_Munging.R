library("foreach")
library("caret")
library("doParallel")

# ----------- create correlation matrix -----------

# build a correlation matrix based on the first 100000 rows
corr.matrix = cor(data[1:100000, 2:679], use = "pairwise.complete.obs")
corr.matrix[is.na(corr.matrix)] = 0

# create sets of features that are very highly correlated
corr.list = foreach(i = 1:nrow(corr.matrix)) %do% {
  rownames(corr.matrix[corr.matrix[,i] > 0.996,])
}

# remove empty and duplicated sets
corr.list = corr.list[sapply(corr.list, function(x) length(x) > 0 )]
corr.list = unique(corr.list)

# create dataframe of correlated pairs of features
corr.pairs = foreach(i = 1:length(corr.list), .combine = rbind) %do% {
  temp.feats = corr.list[[i]]
  t(combn(temp.feats,2))
}

# remove duplicated pairs
corr.pairs = unique(corr.pairs)

# ----------- feature engineering -----------
 
cl = makeCluster(detectCore()-1)
registerDoParallel(cl)

# compute difference of each feature pair
golden.features = foreach(i = 1:length(corr.pairs[,1]), .combine = cbind) %do% {
  temp.feats = corr.pairs[i,]
  new.feat.temp = data[,temp.feats[1] ] - data[,temp.feats[2] ]
}

golden.features = as.data.frame(golden.features)

stopCluster(cl)

# create column names 
colnames(golden.features) = apply(corr.pairs, 1, function(x) paste("diff", x[1], x[2], sep = "_"))

# remove correlated features based on the first 100000 rows
corr.matrix = cor(golden.features[1:100000,], use = "pairwise.complete.obs")
corr.matrix[is.na(corr.matrix) == T] = 0

# find highly correlated features 
useless.features = colnames(corr.matrix)[findCorrelation(corr.matrix, cutoff = 0.99, verbose = F)]

# remove highly correlated features 
for(i in useless.features) {golden.features[,i] = NULL}
golden.features = golden.features[,!(colnames(golden.features) %in% useless.features)]

save(golden.features, file = "golden_features.RData")

