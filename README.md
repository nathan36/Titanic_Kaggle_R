Kaggle data competition
===================================

This is an entry to [Kaggle](http://www.kaggle.com/)'s
[Sentiment Analysis on Movie Reviews](http://www.kaggle.com/c/sentiment-analysis-on-movie-reviews) (SAMR)
competition.

It's written for R 

Problem description
-----------------

Quoting from Kaggle's [description page](http://www.kaggle.com/c/sentiment-analysis-on-movie-reviews):

This competition presents a chance to benchmark your sentiment-analysis ideas
on the [Rotten Tomatoes](http://www.rottentomatoes.com/) dataset. You are asked
to label phrases on a scale of five values: negative, somewhat negative,
neutral, somewhat positive, positive.

Some examples:

 - **4** (positive): _"They works spectacularly well... A shiver-inducing, nerve-rattling ride."_
 - **3** (somewhat positive): _"rooted in a sincere performance by the title character undergoing midlife crisis"_
 - **2** (neutral): _"Its everything you would expect -- but nothing more."_
 - **1** (somewhat negative): _"But it does not leave you with much."_
 - **0** (negative): _"The movies progression into rambling incoherence gives new meaning to the phrase fatal script error."_

So the goal of the competition is to produce an algorithm to classify phrases
into these categories. And that's what `samr` does.


How to use it
-------------

After installing R just run:

    generate_kaggle_submission.py samr/data/model2.json > submission.csv

And that will generate a Kaggle submission file that scores near `0.65844` on the
[leaderboard](http://www.kaggle.com/c/sentiment-analysis-on-movie-reviews/leaderboard)
(should take 3 minutes, and as of 2014-07-22 that score is the 2nd place).

The `model2.json` argument above is a configuration file for `samr` that
determines how the `scikit-learn` pipeline is going to be built and other
hyperparameters, here is how it looks:

    {
     "classifier":"randomforest",
     "classifier_args":{"n_estimators": 100, "min_samples_leaf":10, "n_jobs":-1},
     "lowercase":"true",
     "map_to_synsets":"true",
     "map_to_lex":"true",
     "duplicates":"true"
    }

You can try `samr` with different configuration files you make (as long as the
options are implemented), yielding
different scores and perhaps even better scores.

### Just tell me how it works

In particular `model2.json` feeds a [random forest classifier](http://en.wikipedia.org/wiki/Random_forest)
with a concatenation of 3 kinds of features:

 - The [decision functions](http://scikit-learn.org/stable/modules/generated/sklearn.linear_model.SGDClassifier.html#sklearn.linear_model.SGDClassifier.decision_function)
   of set of vanilla SGDClassifiers trained in a one-versus-others scheme using
   [bag-of-words](http://en.wikipedia.org/wiki/Bag-of-words_model) as features.
   It's classifier inside a classifier, [yo dawg!](http://i.imgur.com/aueqLyL.png)
 - The decision functions of set of vanilla SGDClassifiers trained in a one-versus-others scheme using bag-of-words
   on the [wordnet](http://wordnetweb.princeton.edu/perl/webwn?s=bank) synsets of the words in a phrase.
 - The amount of "positive" and "negative" words in a phrase as dictated by
   the [Harvard Inquirer sentiment lexicon](http://www.wjh.harvard.edu/~inquirer/spreadsheet_guide.htm)

During prediction, it also checks for duplicates between the training set and
the train set (there are quite a few).

And that's it! Want more details? see the code! it's only 350 lines.


Installation
------------

    git clone https://github.com/nathanli36/R-Programming.git


