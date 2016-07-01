# function to add features to training or test data frames
featureEngrg <- function(data) {
    # assume odds < 0.5 means highly likey to determine teams with potential upset
    data$PotUpset <- 0
    data[which(df.train$B365H<1.5 & (data$FTR=="A"|data$FTR=="D")),"PotUpset"] <- 1
    # take the mean of top three accurate bet odds
    data$D.mean <- rowMeans(subset(data,
        select = c("B365D","WHD","VCD")),na.rm=TRUE)
    data$A.mean <- rowMeans(subset(data,
        select = c("B365A","WHA","VCA")),na.rm=TRUE)
    data$H.mean <- rowMeans(subset(data,
        select = c("B365H","WHH","VCH")),na.rm=TRUE)
    return(data)
}