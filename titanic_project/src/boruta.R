library(caret)
library(Boruta)

candidata.set <- train.set[,-1]

set.seed(sample(1:100,1))

bor.results <- Boruta(x=candidata.set, y=train.set$Survived,
                      maxRuns=100,
                      doTrace=0)

plot(bor.results)