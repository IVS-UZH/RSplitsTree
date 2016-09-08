# A very rudementary functionality test. Meant to be invoked as a script 
# TODO: proper unit tests

devtools:::install('..')

library(RSplitsTree)

library(cluster)

data(agriculture)
agriculture.dist <- daisy(agriculture)

splitstree(agriculture.dist, plot='PDF')


