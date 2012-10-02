use Config::Simple;
use File::Path;
use File::Basename;
use Getopt::Long;
#E:\Amazon\AllBalanced\ToysToysAndGamesB\matrices\ToysToysAndGamesB-NoPOSNoDictNoNEGUniGramPunct-SentenceMatrix.txt
#E:\Amazon\GroceriesTest\GroceriesTest-NoPOSNoDictNEGUniGramNoPunct-DocMatrixSorted.txt
#"E:\Amazon\globalbest\Global-NoPOSDictNEGUniGramNoPunct-DocMatrix.txt" 5 1000 svmperftfidf
#-Features "E:\Amazon\groceriestest\matrices\groceriestest-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocMatrix.txt" -numFolds 5 -randomSeed 1000 -classifier svmperftfidf
#$matrix=shift;
#$nfold=shift;
#$seed=shift;
#$algorithm=shift;

$classifier="svmperftfidf";


$nfold=5;

$seed=1000;

$r = GetOptions (
"Features=s" => \$matrix,
"numFolds=i" => \$nfold,
"classifier=s" => \$classifier,
"Quick=f" => \$quickFlag,
"randomSeed=i" => \$seed
);

my($filename, $directory) = fileparse($matrix);
 $matricesdir=$directory;
 $matrixdir=$matricesdir."xval\\matrices\\";
 $modeldir=$matricesdir."xval\\models\\";
 #$modelcompletedir=$matricesdir."xval\\completemodels\\";
 $resultdir=$matricesdir."xval\\results\\";
 $evaldir=$matricesdir."xval\\eval\\";
 $aggevaldir=$matricesdir."xval\\aggeval\\";
 mkpath([$matrixdir,$modeldir,$resultdir,$evaldir,$aggevaldir],1);
 $evalmatrix=$evaldir.$filename;
$logfile=$evalmatrix.".XVAL.$nfold.LOG.txt";
open(LOG, ">$logfile") or die "can't open logfile $logfile: $!";
$filesfile=$evalmatrix.".XVAL.$nfold.FILES.txt";
open(FILES, ">$filesfile") or die "can't open logfile $filesfile: $!";
print FILES $matrix."\n";
 
rand $seed;
@lines=();
open(INPUTFILE, "< $matrix") or die "can't open $matrix: $!";
$samplesize= 0;
	while( <INPUTFILE> ) {
 $lines[$samplesize]=$samplesize;
  $samplesize++;
  }

fisher_yates_shuffle( \@lines );    # permutes @array in place

@trainhandles=();
@testhandles=();
@trainfnames=();
@testfnames=();
@modelfnames=();
@resultfnames=();
for ($i = 1; $i <= $nfold; $i++) {
$trainhandle= return_fh();
$testhandle= return_fh();
$trainfname=$matrixdir.$filename."N".$nfold."-".$i."-train.txt";
$testfname=$matrixdir.$filename."N".$nfold."-".$i."-test.txt";
$modelfname=$modeldir.$filename."N".$nfold."-".$i."-model.txt";
$resultfname=$resultdir.$filename."N".$nfold."-".$i."-result.txt";
print FILES  "$trainfname,$testfname,$modelfname, $resultfname\n";
$trainhandles[$i]=$trainhandle;
$testhandles[$i]=$testhandle;
$trainfnames[$i]=$trainfname;
$testfnames[$i]=$testfname;
$modelfnames[$i]=$modelfname;
$resultfnames[$i]=$resultfname;

open ($trainhandle, ">$trainfname") or die "can't open trainfname: $!";
open ($testhandle, ">$testfname") or die "can't open testfname: $!";
}
@selection = (); $thisfold = 0; $accu = 0;
open(INPUTFILE, "< $matrix") or die "can't open $matrix: $!";
$linecount= 0;
	while( $line=<INPUTFILE> ) {
 $bin=$linecount%$nfold+1;
  $linecount++;
  for ($i = 1; $i <= $nfold; $i++) {
   if ($i==$bin) {
   $fh=$testhandles[$i];
       print $fh $line;
    }
    else {
       $fh=$trainhandles[$i];

       print $fh $line;
      }
  }
  
  }

  for ($i = 1; $i <= $nfold; $i++) {
  $trainfname=$trainfnames[$i];
  $testfname=$testfnames[$i];
  $modelfname=$modelfnames[$i];
  $resultfname=$resultfnames[$i];

 $traintestcommand="start /wait /b /high perl traintest.pl -features \"$trainfname\" -testfeatures \"$testfname\" -model \"$modelfname\"  -results \"$resultfname\" -classifier $classifier";

print  $traintestcommand . "\n";

$traintestresult=runCommand($traintestcommand);


print LOG "$traintestcommand\n$traintestresult\n";

$resultforanalysis="$testfname.svmperftfidf.result.txt";

$resultanalysiscommand="start /wait /b /high perl makeErrorFilesAndExtendedWordlist.pl \"$trainfname\" \"$modelfname\" 0 \"$resultforanalysis\" \"$testfname\"";
print   $resultanalysiscommand ."\n";


$resultanalysisresult=runCommand($resultanalysiscommand);

print LOG "$resultanalysiscommand\n$resultanalysisresult\n";


}
 $collatorcommand="start /wait /b /high perl evalcollator6.pl \"$filesfile\"";
print   $collatorcommand ."\n";


$collatorresult=runCommand($collatorcommand);

print LOG "$collatorcommand\n$collatorresult\n";


exit;
#$samplesize=@files;
for ($i = 0; $i < $samplesize; $i++) {
$ir = rand $samplesize;
push @selection, $ir;
splice(@files, $ir, 1); }
foreach $f ( @selection ) { $fold{$f} =
$thisfold++ % $nfold; }
for ( $cf = 0; $cf < 10; $cf++ ) {
%train = (); %test = (); $count = ();
foreach $f ( @selection ) {
($cl{$f}, $name) = split(/\//, $f);
$ref = ($fold{$f}==$cf) ? \%test :
\%train;
open(FILE, $f); while(<FILE>) {
@words = split(/\s+/, $_);
foreach $w ( @words ) { ${$ref}
{$w}++; $count{$f}{$w}++; } }
close(FILE); }
@wlist = sort { $train{$b} <=>
$train{$a} } ( keys %train );
splice(@wlist, N);
open(TR, ">tr$cf"); open(TE, ">te$cf");
foreach $f ( @selection ) {
$handle = ($fold{$f}==$cf) ? TE : TR;
print $handle join(',', map
{$count{f}{$_}+0} @wlist).",$cl{$f}\n"; }
close(TR); close(TE);
$accu += `learner tr$cf te$cf`; }
print "Accuracy: ".($accu/10)."\n";
exit;

# fisher_yates_shuffle( \@array ) : generate a random permutation
# of @array in place
sub fisher_yates_shuffle {
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
}




sub return_fh {             # make anon filehandle
    local *FH;              # must be local, not my
    # now open it if you want to, then...
    return *FH;
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



