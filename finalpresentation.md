N-Gram Predictor
========================================================
author: Scott Semel
date: April 23, 2015

Overview
========================================================

- This is an algorithm for the Data Science Capstone that predicts next word given a string of words.
- It also gives you up to 5 other possibilities given what it learned from the training set.

You can go to my gitlab repository [here.](https://github.com/scottsemel/capstone/)

How do you Use the App? 

Just Enter the phrase that you want to predict the next word from.

You can run the app [here.](https://scottsemel.shinyapps.io/capstone/)

Algorithms
========================================================
- Prior to generate the n-grams model from training corpus, vocabulary is reduced to a subset of words covering 95% of total occurrences, that is, about 40,000 words. All other words are marked as unknown.
- Given a sequence of $k$ words $S=w_{1}, w_{2},\ldots,w_{k}$, a statistical language model assigns a probability to the sequence by means of a probability distribution $P(S)= P(w_1,w_2\ldots,w_k)$. 
- In n-gram models, only the $n-1$ last words are considered relevant when predicting the next word (Markov assumption)
        $P(w_{k}\mid w_{1}, w_{2},\ldots,w_{k-2}, w_{k-1}) \approx P(w_{k}\mid w_{k-n+1}, ... ,w_{k-1})$
- It checks if highest-order 4-gram has been seen. If not then it uses the next lower-order model. And progresses to 1-gram if that is the best it can do. Interpolation is another way to do it by combining several models together.

The Equations
========================================================

Katz's backoff

$P_{Katz}(w_{i}\mid w_{i-n+1}^{i-1}) =$
$$\begin{cases} d \cdot P_{MLE}(w_{i}\mid w_{i-n+1}{i-1}) \ {\text{if } C(w{i-n+1}{i})>0} \ \ \lambda \cdot P_{Katz}(w_{i}\mid w_{i-n+1}{i-2}) \ _{\text{otherwise}} \end{cases}$$

Kneser-Ney (Interpolation)
$$\begin{align*}P_{KN}(w_{i}\mid w_{i-n+1}{i-1}) &= \frac{C(w_{i-n+1}{i})-D}{\sum_{w_{i}}C(w_{i-n+1}{i})} \ &+ \lambda \cdot P_{KN}(w_{i}\mid w_{i-n+1}{i-2}) \end{align*}$$
$\text{where } C(w_{i-n+1}^{i}) =$
$$\begin{cases} \text{freq count} & _{\text{highest order}} \ \text{N(unique histories)} & _{\text{lower orders}} \end{cases}$$

Count is discounted to shift some probability mass to lower-order model for interpolation


Results
========================================================

- The underlying code stores the n-gram and frequency tables in a flat text file but a database may be used for more effectiveness. 
- We're restricted to 100mb on ShinyApps, but in real life some have trained on billions or trillions of words

- We can try Kneser-Ney or one of the Backoff models as we increase amount of data we train on

- We only use 1% of the data provided by SwiftKey and Coursera to fit into the 100mb limit

Further Exploration
========================================================
There are many ways in which this model can be improved.
- The best one would be letting the application learn from the user.
- Because of the sparsity problem the predicted probability is 0 for several words that are not in the training set. We could try different smoothing techniques to adjust for that.
- We can also train on combinations that are grammatically not possible. This would improve the accuracy if it could be done wisely. It may also be possible to combine a bag of words technqiue or a skip gram technique to predict words that are not in the training set. 

References

- Large Language Models in Machine Translation ([Brants et al 2007](http://www.cs.columbia.edu/~smaskey/CS6998-0412/supportmaterial/langmodel_mapreduce.pdf))
 
