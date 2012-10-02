#input parameters

# input source : csv or database or rainbow-style directories
# classes to build classifiers for: all or set
# features to generate: words, bigrams, pos, negation, stopilst, stemming, other dictionaries, rules
# classifier to use svm, naivebayes
# classifier parameters
# buildmodel or experiment : build model on all data or generate train test splits and run evaluation scripts


$dirname=shift;
$modelfilename='D:\data\PROJECTS\sentiment\globalmodels\global-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocModel.txt';
$inputcommand = "start /wait /realtime /b perl makeMatrices.pl \"$dirname\" ConcatPOS BothNEG Dict BiGram NoStem";
print $inputcommand."\n";
$matrixoutput=`$inputcommand`;
if ($matrixoutput =~ /\n(.*?)$/) {$matrixfilename=$1;}
print $matrixfilename;
$inputcommand = "start /wait /realtime /b perl score_new_data.pl \"$matrixfilename\" \"$modelfilename\"";
print $inputcommand."\n";
$output=`$inputcommand`;
