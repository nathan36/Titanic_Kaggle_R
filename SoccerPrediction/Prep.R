readData <- function(file.path, column.types, missing.types) {
    read.csv(file=file.path, colClasses=column.types, na.strings=missing.types)
}

train.path <- "desktop/SoccerPrediction/train.csv"
test.path <- "desktop/SoccerPrediction/test.csv"
missing.types <- c("NA", "")
train.col.types <- rep(c('integer',    # ID
                        'character',   # Date
                        'character',   # HomeTeam
                        'character',   # AwayTeam
                        'factor',      # FTR
                        'numeric'      # B365H ~ VCA
                        ), times = c(1,1,1,1,1,18)
)

train.data <- readData(train.path, train.col.types, missing.types)
df.train <- as.data.frame(train.data)

# remove rows with missing value
df.tarin <- na.omit(df.train)

