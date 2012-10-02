# "C:\Users\marko_krema\Documents\Visual Studio 2010\Projects\SentimentTest1\SentimentTest1\inputtmp\inputtmpDocMatrixSorted.txt" "E:\Amazon\m\global.matrix.txt.svmperftfidf.model.txt"
#E:\Amazon\GroceriesTest\GroceriesTestDocMatrixSorted.txt E:\Amazon\GroceriesTest\GroceriesTestDocMatrixSorted.txt.svmperftfidf.model.txt E:\Amazon\GroceriesTest\testresult.txt
$matrix=shift;
$model=shift;
$algorithm=shift;

if (length ($algorithm)<2) {
$algorithm="svmperftfidf";
}

if (length ($result)<2) {
$result="$matrix.$algorithm.result.txt";
}


if ($algorithm eq "svmperftfidf") {
 $inputfile=$matrix;
$wordlistfile=$model."WordList.txt";
 $SVMfileIDF=$inputfile."SVMLightIDF.txt";
# "C:\Users\marko_krema\Documents\Visual Studio 2010\Projects\SentimentTest1\SentimentTest1\inputtmp\inputtmpDocMatrixSorted.txt" "E:\Amazon\m\global.matrix.txt.svmperftfidf.model.txt"
 $inputfile=$matrix;
 $SVMfileMAX=$inputfile."SVMLightMAX.txt";

 #$wordlistcommand="perl makeWordlistIDFAndMaxFreq.pl $inputfile $wordlistfile";
# $inputcommand = "perl makeSVMLightFile.pl $inputfile $wordlistfile 0 $SVMfileIDF $SVMfileMAX";
 $runcommand = "start /wait /b /high perl runmodel.pl \"$matrix\" \"$model\" \"$result\" $algorithm";

}
#$wordlistresult=`$wordlistcommand`;
$runresult=`$runcommand`;
#$modelresult=`$modelcommand`;


$logfile=$matrix.".TESTLOG.txt";
open(OUT, ">$logfile") or die "can't open logfile $logfile: $!";
print OUT "$runcommand\n$runresult\n\n$evalcommand\n$evalresult\n";
close OUT;
print "Done.\n";

exit;
