use Config::Simple;
use Getopt::Long;
# "C:\Users\marko_krema\Documents\Visual Studio 2010\Projects\SentimentTest1\SentimentTest1\inputtmp\inputtmpDocMatrixSorted.txt" "E:\Amazon\m\global.matrix.txt.svmperftfidf.model.txt"
#E:\Amazon\GroceriesTest\GroceriesTestDocMatrixSorted.txt E:\Amazon\GroceriesTest\GroceriesTestDocMatrixSorted.txt.svmperftfidf.model.txt E:\Amazon\GroceriesTest\testresult.txt
#run with max not idf
#$matrix=shift;
#$model=shift;
#$resulteval=shift;
#$algorithm=shift;

$result = GetOptions (
"Features=s" => \$matrix,
"model=s" => \$model,
"classifier=s" => \$classifier,
"results=s" => \$resulteval,
"Quick!" => \$quickFlag,
);

if (length ($classifier)<2) {
$classifier="svmperftfidf";
}

if (length ($result)<2) {
$result="$matrix.$classifier.result.txt";
}

if (length ($resulteval)<2) {
$resulteval="$matrix.$classifier.EVAL.txt";
}


if ($classifier eq "svmperftfidf") {
 $inputfile=$matrix;
$wordlistfile=$model."WordList.txt";
 $SVMfileIDF=$inputfile."SVMLightIDF.txt";
# "C:\Users\marko_krema\Documents\Visual Studio 2010\Projects\SentimentTest1\SentimentTest1\inputtmp\inputtmpDocMatrixSorted.txt" "E:\Amazon\m\global.matrix.txt.svmperftfidf.model.txt"
 $inputfile=$matrix;
 $SVMfileMAX=$inputfile."SVMLightMAX.txt";

 #$wordlistcommand="perl makeWordlistIDFAndMaxFreq.pl $inputfile $wordlistfile";
# $inputcommand = "perl makeSVMLightFile.pl $inputfile $wordlistfile 0 $SVMfileIDF $SVMfileMAX";
 $runcommand = "perl runmodel.pl -Features \"$matrix\" -model \"$model\" -resultfile \"$result\" -classifier $classifier";

 #$modelcommand ="start /wait /realtime /b   svm_perf_learn.exe -c 100 -l 10 -w 3 $SVMfileIDF $model ";
 $evalcommand="perl evalSVM6.pl \"$SVMfileIDF\" \"$result\" \"$resulteval\"";


}
#$wordlistresult=`$wordlistcommand`;
$runresult=runCommand($runcommand);
print $runcommand;
#$modelresult=`$modelcommand`;
$evalresult=runCommand($evalcommand);


$logfile=$matrix.".TESTLOG.txt";
open(OUT, ">$logfile") or die "can't open logfile $logfile: $!";
print OUT "$runcommand\n$runresult\n\n$evalcommand\n$evalresult\n";
close OUT;
print "Done.\n";

exit;
sub runCommand {
my $command=shift;
my $exe;
my $subst;
my $pl;
my $ret;
if ($command=~/(perl\s+((.*?).pl))/ig) {
  $subst=$1;
  $pl=$2;
  $exe=$3.".exe";
  if (!(-e $exe)) {
  if (-e "perl2exe\\perl2exe.exe") {
 # $ret=`perl2exe\\perl2exe.exe $pl`;
  }
  }
  if (-e $exe) {
  $command=~s/$subst/$exe/ig;
  }
  }
  $ret=`$command`;
  return $ret;
}

