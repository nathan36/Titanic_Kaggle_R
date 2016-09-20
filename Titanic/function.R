require(plyr)
require(stringr)
require(Hmisc)

# function for loading data
readData <- function(file.path, column.types, missing.types) {
  read.csv(file=file.path, colClasses=column.types, na.strings=missing.types)
}


# function for extracting title for name
getTitle <- function(data) {
  title.dot.start <- regexpr("\\,[A-Z ]{1,20}\\.", data$Name, TRUE)
  title.comma.end <- title.dot.start + attr(title.dot.start, "match.length")-1
  data$Title <- substr(data$Name, title.dot.start+2, title.comma.end-1)
  return (data$Title)
}

# function for replacing missing values in features
imputeMedian <- function(impute.var, filter.var, var.levels) {
  for (v in var.levels) {
    impute.var[which(filter.var == v)] <- impute(impute.var[
      which(filter.var == v)])
  }
  return(impute.var)
}

# function for assigning new title value to old title
changeTitles <- function(data, old.titles, new.title) {
  for (honorific in old.titles) {
    data$Title[which(data$Title == honorific)] <- new.title
  }
  return(data$Title)
}

# function to add features to training or test data frames
featureEngrg <- function(data) {
  data$Survived <- revalue(data$Survived, c("1"="Survived","0"="Perished"))
  # Boat.dibs attempts to capture the "women and children first"
  data$Boat.dibs <- "No"
  data$Boat.dibs[which(data$Sex == "female" | data$Age < 15)] <- "Yes"
  data$Boat.dibs <- as.factor(data$Boat.dibs)
  # Collapsing siblings and spo(SibSp) into one featureuses
  data$FamilySize <- data$SibSp + data$Parch + 1
  # Group related family by surname
  data$Surname <- sapply(data$Name,
                         FUN=function(x) {strsplit(x, split='[,.]')[[1]][1]})
  data$FamilyID <- paste(as.character(data$FamilySize), data$Surname, sep="")
  data$FamilyID[data$FamilySize <= 2] <- 'Small'
  famIDs <- data.frame(table(data$FamilyID))
  famIDs <- famIDs[famIDs$Freq <= 2,]
  data$FamilyID[data$FamilyID %in% famIDs$Var1] <- 'Small'
  data$FamilyID <- factor(data$FamilyID)
  # Giving the traveling class feature a new look
  data$Class <- data$Pclass
  data$Class <- revalue(data$Class,
                        c("1"="First", "2"="Second", "3"="Third"))
  return (data)
}

# function for coverting roc object to data frame for ploting
roc.prep <- function(roc.obj){
  roc.copy <- roc.obj
  roc.obj <- data.frame(sens=roc.obj$sensitivities, spec=roc.obj$specificities)
  roc.obj <- loess(sens~spec, data=roc.obj)
  roc.obj <- data.frame(sens=predict(roc.obj), spec=roc.copy$specificities)
  return(roc.obj)
}