# "C:\Users\marko_krema\Documents\Visual Studio 2010\Projects\SentimentTest1\SentimentTest1\inputtmp\inputtmpDocMatrixSorted.txt" "E:\Amazon\m\global.matrix.txt.svmperftfidf.model.txt"

# "C:\Users\marko_krema\Documents\Visual Studio 2010\Projects\SentimentTest1\SentimentTest1\inputtmp\matrices\inputtmpDocMatrix.txt" "C:\Users\marko_krema\Documents\Visual Studio 2010\Projects\SentimentTest1\SentimentTest1\models\global-NoPOSDictNEGBiGramNoStem-DocModel.txt"
#run with max not idf

#-Features "E:\Amazon\groceriestest\matrices\groceriestest-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocMatrix.txt" -model "testmodels\automotive-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocModel.txt.svmperftfidf.model.txt" -classifier svmperftfidf
use Config::Simple;
use Getopt::Long;


$svmperfFlag=1;
$probabilitiesFlag=1;
if (length ($classifier)<2) {
$classifier="svmperftfidf";
}


$r = GetOptions (
"Features=s" => \$matrix,
"model=s" => \$model,
"classifier=s" => \$classifier,
"Quick=f" => \$quickFlag,
"resultfile=s" => \$result
);

if (length ($result)<2) {
$result="$matrix.$classifier.result.txt";
}


if ($classifier eq "svmperftfidf") {
 $inputfile=$matrix;
$wordlistfile=$model."WordList.txt";
 $SVMfileIDF=$inputfile."SVMLightIDF.txt";
# "C:\Users\marko_krema\Documents\Visual Studio 2010\Projects\SentimentTest1\SentimentTest1\inputtmp\inputtmpDocMatrixSorted.txt" "E:\Amazon\m\global.matrix.txt.svmperftfidf.model.txt"

 $SVMfileMAX=$inputfile."SVMLightMAX.txt";
 
 #$wordlistcommand="perl makeWordlistIDFAndMaxFreq.pl $inputfile $wordlistfile";
# $inputcommand = "perl MakeSVMLightFile.pl $inputfile $wordlistfile 0 $SVMfileIDF $SVMfileMAX";
 $inputcommand = "perl /home/rayid/text_classification_tool/MakeSVMLightFile.pl \"$inputfile\" \"$wordlistfile\" 0 \"$SVMfileIDF\" \"$SVMfileMAX\"";
print $inputcommand."\n";
 #$modelcommand ="start /wait /realtime /b   svm_perf_learn.exe -c 100 -l 10 -w 3 $SVMfileIDF $model ";
 if ((-e "svm_perf_classify.exe") && $svmperfFlag)  {
 $runcommand="/home/rayid/text_classification_tool/svm_perf_classify \"$SVMfileIDF\"  \"$model\" \"$result\" ";
  }
  else
  {
   $runcommand="/home/rayid/text_classification_tool/svm_perf_classify  \"$SVMfileIDF\" \"$model\"  \"$result\" ";
  }
print $runcommand."\n";

}
if (-e "$matrix.cfg") {
$cfg = new Config::Simple("$matrix.cfg");
$cfg->autosave(1);
  $cfg->param("model",$model);
  $cfg->param("resultfile",$result);

   $cfg->write();
                     }
#$wordlistresult=`$wordlistcommand`;
$inputresult=runCommand($inputcommand);
#$modelresult=`$modelcommand`;
$runresult=runCommand($runcommand);


$logfile=$matrix.".LOG.txt";
open(OUT, ">$logfile") or die "can't open logfile $logfile: $!";
print OUT "$inputcommand\n$inputresult\n\n$runcommand\n$runresult\n";
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

