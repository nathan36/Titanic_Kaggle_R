train.data.path <- "data/train.csv"
test.data.path <- "data/test.csv"
missing.types <- c("NA", "")
train.col.types <- c('integer',     # PassengerId
                     'factor',      # Survived
                     'factor',      # Pclass
                     'character',   # Name
                     'factor',      # Sex
                     'numeric',     # Age
                     'integer',     # SibSp
                     'integer',     # Parch
                     'character',   # Ticket
                     'numeric',     # Fare
                     'character',   # Cabin
                     'factor'       # Embarked
)
test.col.types <- train.col.types[-2]

train.data <- readData(train.data.path, train.col.types, missing.types)
df.train <- train.data

test.data <- readData(test.data.path, test.col.types, missing.types)
df.test <- test.data

