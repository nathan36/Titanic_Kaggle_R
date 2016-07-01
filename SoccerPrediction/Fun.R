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