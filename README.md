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
   1. Load.R
   2. Data_munging.R
   3. Model_training.R
   4. Result.R

Installation
------------

    git clone https://github.com/nathanli36/R-Programming.git


