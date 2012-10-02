# "C:\Users\marko_krema\Documents\Visual Studio 2010\Projects\SentimentTest1\SentimentTest1\inputtmp\inputtmpDocMatrixSorted.txt" "E:\Amazon\m\global.matrix.txt.svmperftfidf.model.txt"
use Config::Simple;
use Getopt::Long;
#$matrix=shift;
#$testmatrix=shift;
#$model=shift;
#$resulteval=shift;
#$algorithm=shift;



$classifier = "svmperftfidf";
$dffilter=0;
$result = GetOptions (
"Features=s" => \$matrix,
"TestFeatures=s" => \$testmatrix,
"model=s" => \$model,
"classifier=s" => \$classifier,
"results=s" => \$resulteval,
"Quick!" => \$quickFlag,
"dffilter=f" => \$dffilter
);


if (length ($classifier)<2) {
$classifier="svmperftfidf";
}

if (length ($model)<2) {
$model="$matrix.$classifier.model.txt";
}


if (length ($result)<2) {
$result="$matrix.$classifier.result.txt";
}

if (length ($resulteval)<2) {
$resulteval="$matrix.$classifier.EVAL.txt";
}



$wordlistfile=$model."WordList.txt";
 $SVMfileIDF=$inputfile."SVMLightIDF.txt";

# "C:\Users\marko_krema\Documents\Visual Studio 2010\Projects\SentimentTest1\SentimentTest1\inputtmp\inputtmpDocMatrixSorted.txt" "E:\Amazon\m\global.matrix.txt.svmperftfidf.model.txt"
 $inputfile=$matrix;
 $SVMfileMAX=$inputfile."SVMLightMAX.txt";

 #$wordlistcommand="perl makeWordlistIDFAndMaxFreq.pl $inputfile $wordlistfile";
# $inputcommand = "perl makeSVMLightFile.pl $inputfile $wordlistfile 0 $SVMfileIDF $SVMfileMAX";
 $traincommand = "start /wait /b /high perl trainmodel.pl -Features \"$matrix\" -model \"$model\"  -classifier $classifier -dffilter $dffilter";

 #$modelcommand ="start /wait /realtime /b   svm_perf_learn.exe -c 100 -l 10 -w 3 $SVMfileIDF $model ";
 $testcommand="start /wait /b /high perl testmodel.pl -Features \"$testmatrix\" -model \"$model\" -results \"$resulteval\"";



#$wordlistresult=`$wordlistcommand`;
print $traincommand . "\n";
$trainresult=runCommand ($traincommand);

print $testcommand . "\n";
#$modelresult=`$modelcommand`;
$testresult=runCommand($testcommand);

#print $testcommand . "\n";


$logfile=$matrix.".TRAINTESTLOG.txt";
open(OUT, ">$logfile") or die "can't open logfile $logfile: $!";
print OUT "$traincommand\n$trainresult\n\n$testcommand\n$testresult\n";
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

