group <- function(string){
    string <- c(paste(string,"H",sep=""),
                paste(string,"A",sep=""),
                paste(string,"D",sep=""))
}

sumResult <- function(str,data){
    x <- group(str)
    y <- as.factor(apply(data[,x],1,which.min))
    rs <- revalue(y,c("1"="H","2"="A","3"="D"))
    return (rs)
}

df.train$D.mean <- rowMeans(subset(df.train,
    select = c("BWD","IWD","LBD","WHD","VCD")),na.rm=TRUE)
df.train$A.mean <- rowMeans(subset(df.train,
    select = c("BWA","IWA","LBA","WHA","VCA")),na.rm=TRUE)
df.train$H.mean <- rowMeans(subset(df.train,
    select = c("BWH","IWH","LBH","WHH","VCH")),na.rm=TRUE)

# create correlation matrix
corr.matrix = cor(subset(df.train, select = c("B365H","B365A","B365D","H.mean","A.mean","D.mean")), use = "pairwise.complete.obs")
corr.matrix[is.na(corr.matrix)] = 0

# data prepped for casting predications
df.test$D.mean <- rowMeans(subset(df.test,
    select = c("BWD","IWD","LBD","WHD","VCD")),na.rm=TRUE)
df.test$A.mean <- rowMeans(subset(df.test,
    select = c("BWA","IWA","LBA","WHA","VCA")),na.rm=TRUE)
df.test$H.mean <- rowMeans(subset(df.test,
    select = c("BWH","IWH","LBH","WHH","VCH")),na.rm=TRUE)

