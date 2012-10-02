use Config::Simple;
use Getopt::Long;
use File::Basename;
#$matrix=shift;
#$model=shift;
#$classifier=shift;
#$dffilter=shift;
$svmperfFlag=1;

# -Features "E:\Amazon\groceriestest\matrices\groceriestest-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocMatrix.txt" -model "E:\Amazon\groceriestest\models\groceriestest-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocModel.txt" -classifier svmperftfidf -dffilter 0
#"E:\Amazon\NewModels\Electronics\matrices\Electronics-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocMatrix.txt" "E:\Amazon\NewModels\Electronics\models\Electronics-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocModel.txt"
$classifier="all";


#$model="$matrix";


$dffilter=0;


$r = GetOptions (
"Features=s" => \$matrix,
"model=s" => \$model,
"classifier=s" => \$classifier,
"Quick!" => \$quickFlag,
"dffilter=f" => \$dffilter
);
$classifier=lc($classifier);
$logfile=$matrix.".LOG.txt";
open(OUT, ">$logfile") or die "can't open logfile $logfile: $!";


if (length ($model)<2) {
$model="$matrix";
}
$modelc=$model;
if (($classifier eq "svmperftfidf")||($classifier eq "all")) {

    if ($classifier eq "all") {
$modelc="$model.svmperftfidf.model.txt";
     }

 $inputfile=$matrix;
 #wordlistfile=$inputfile."WordList.txt";
 $wordlistfile=$modelc."WordList.txt";
 $SVMfileIDF=$inputfile."SVMLightIDF.txt";
 $SVMfileMAX=$inputfile."SVMLightMAX.txt";
 $wordlistcommand="perl makeWordlistIDFAndMaxFreq.pl \"$inputfile\" $dffilter \"$wordlistfile\"";
 $inputcommand = "perl makeSVMLightFile.pl \"$inputfile\" \"$wordlistfile\" 0 \"$SVMfileIDF\" \"$SVMfileMAX\"";
 if ((-e "svm_perf_learn") && $svmperfFlag) {
 $modelcommand ="svm_perf_learn -c 100 -l 10 -w 3 \"$SVMfileIDF\" \"$modelc\" ";
 $checkcommand="perl checkmodel.pl \"$inputfile\"  \"$modelc\" ";
 runAllCommands();
 } else {
 $classifier="liblogistic";
  }

if (($classifier eq "liblogistic")||($classifier eq "all")) {
 if ($classifier eq "all") {
   $modelc="$model.liblogistic.model.txt";
}
$inputfile=$matrix;
 #wordlistfile=$inputfile."WordList.txt";
 $wordlistfile=$modelc."WordList.txt";
 $SVMfileIDF=$inputfile."SVMLightIDF.txt";
 $SVMfileMAX=$inputfile."SVMLightMAX.txt";
 $wordlistcommand="perl makeWordlistIDFAndMaxFreq.pl \"$inputfile\" $dffilter \"$wordlistfile\"";
 $inputcommand = "makeSVMLightFile.pl \"$inputfile\" \"$wordlistfile\" 0 \"$SVMfileIDF\" \"$SVMfileMAX\"";
 $modelcommand ="train.exe -s 7 -c 100 -e 0.1   \"$SVMfileIDF\"  \"$modelc\" ";
 $checkcommand="perl checkmodel.pl \"$inputfile\"  \"$modelc\" ";
  runAllCommands();
}




close OUT;
                       }
exit;

sub runAllCommands {
 $wordlistresult=runCommand($wordlistcommand);
$inputresult=runCommand($inputcommand);
$modelresult=runCommand($modelcommand);
$checkresult=runCommand($checkcommand);

print OUT "$wordlistcommand\n$wordlistresult\n\n$inputcommand\n$checkcommand\n$inputresult\n\n$modelcommand\n$modelresult\n$checkresult\n";
print "Done training $model.\n";
if (-e "$matrix.cfg") {
$cfg = new Config::Simple("$matrix.cfg");
$cfg->autosave(1);
  $cfg->param("wordlistfile",$wordlistfile);
  $cfg->param("SVMfileIDF",$SVMfileIDF);
  $cfg->param("SVMfileMAX", $SVMfileMAX);
  $cfg->param("model",$model);
  $cfg->param("dffilter",$dffilter);

   $cfg->write();



}

}
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
