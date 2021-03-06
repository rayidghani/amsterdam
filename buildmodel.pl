#takes a directory of data rainbow style and outputs an svm model


#input parameters

# input source : csv or database or rainbow-style directories
# classes to build classifiers for: all or set
# features to generate: words, bigrams, pos, negation, stopilst, stemming, other dictionaries, rules
# classifier to use svm, naivebayes
# classifier parameters
# buildmodel or experiment : build model on all data or generate train test splits and run evaluation scripts


$dirname=shift;

$matrixfilename=`perl makeMatrices.pl $dirname`;
print $matrixfilename;
`perl traintest.pl $matrixfilename $matrixfilename`;
