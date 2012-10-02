use File::Copy;
use File::Basename;
use File::Path;
use Config::Simple;
use Getopt::Long;
  #"E:\Amazon\Allbalanced\Electronics\matrices\Electronics-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocMatrix.txt" "E:\Amazon\Allbalanced\Electronics\models\Electronics-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocModel.txt"
  #"E:\Amazon\Allbalanced\Automotive\matrices\Automotive-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocMatrix.txt" "E:\Amazon\AllBalanced\Automotive\models\Automotive-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocModel.txt"
$filename=shift;
$model=shift;
$output=shift;

#optional
$outputIDF=shift;
$outputMAX=shift;
if (length($minIDF)<1) {
$minIDF=0;
}
if (length($outputIDF)<2) {$outputIDF=$filename."SVMLightIDF.txt";}
if (length($outputMAX)<2) {$outputMAX=$filename."SVMLightMAX.txt";}

#E:\Amazon\AllBalanced\Automotive\matrices\xval\matrices\automotive-ConcatPOSDictPropagNEGBiGramNoStem-DocMatrix.txtN5-2-train.txt E:\Amazon\AllBalanced\Automotive\matrices\xval\models\automotive-ConcatPOSDictPropagNEGBiGramNoStem-DocMatrix.txtN5-2-model.txt 3 E:\Amazon\AllBalanced\Automotive\matrices\xval\results\automotive-ConcatPOSDictPropagNEGBiGramNoStem-DocMatrix.txtN5-2-result.txt
if (length($output)<2) {$output=$filename."WordListEnhanced.csv";}
$summary=$output."summary.txt";
if (-e "$filename.cfg") {
$cfg = new Config::Simple("$filename.cfg");
$cfg->autosave(1);
  $cfg->param("wordlistenhanced",$output);
  $cfg->param("Summary",$summary);


   $cfg->write();
                 }

#$SVMfileMAX=$testmatrix."SVMLightMAX.txt";
$c=0;
 undef %wtf; #word total frequencies
  undef %wm; #word max frequency
  undef %wd; #word documents
  $cfc=0;
  $ccc=0;
  $cdc=0;
  $wc=0;
  $doccount=0;
  open(INPUTFILE, "<$filename") or die "can't open $filename: $!";
  while (defined ($line = <INPUTFILE>)) {
  $doccount++;
  ($linenocomment,$trash)=split(/#/,$line);
  @f=split(/\s+/,$linenocomment);
  $file=@f[0];
  $cat=lc(@f[1]);
  $wordcat=$word."|".$cat;
$len=@f;
for ($i=2;$i<$len;$i=$i+2)
{
$l=@f[$i];
$v=@f[$i+1];

if (!($wd{$l}>0)) {
                        $wc++;

                        }  #if

$wd{$l}++;
if ($cat eq 'negative'){
$wdn{$l}++;
} elsif ($cat eq 'positive') {
 $wdp{$l}++;
}
#debug
#if ($l eq "abc") {
#print "Here: $l";
#}
#end debug
$wtf{$l}=$wtf{$l}+$v;
if (!(exists  $wm{$l})){
$wm{$l}=0;
}
if ($v>$wm{$l}) {
$wm{$l}=$v;
}
} #for
 }  #while
 
close $filename;

  open(OUTPUTFILE7, "> $output") or die "can't open $output: $!";
  open(SUMMARY, "> $summary") or die "can't open $summary: $!";

@tmp=("FeatureNum","Feature","IDF","ModelWeight","PositivePerc","NegativePerc","DiffPErc","AbsDiffPErc","TotalWordFrequency","MaxFrequency","AbsModelWeight" );
$tmpout=arrayToCSV(@tmp);
print OUTPUTFILE7 $tmpout, "\n";
print SUMMARY "Total Documents: $doccount\n";

open(MODEL, "<$model") or die "can't open $model: $!";
   $wcmodel=0;
   %wmodel=();
   undef %wmodel;

      $lastline="";
      $ctmodel=0;

    while ((defined ($line = <MODEL>))) {
   $ctmodel++;
   if ($ctmodel<12) {next;}
  # print "b chomp\n";
   chomp $line;
   #print "a chomp\n";
   #print "b\n";
   $lastline=$line;
   #print "a\n";

   #print "Done reading model\n";
@elements=split (" ",$lastline);
#print "Done splitting model\n";
$numelements=@elements;
undef @missing;
for ($n=1;$n<$numelements;$n++){
$tmp=@elements[$n];
$nextwordnum=$wordnum+1;
($wordnum,$weight)=split(":", $tmp);
    for ($j=$nextwordnum;$j<$wordnum;$j++) {
    #print SUMMARY "Missing in model: feature number $j\n";
    #print "Missing in model: feature number $j\n";
    push (@missing, $j);
    }
$wmodel{$wordnum}=$weight;
}
$modelfeatures=$numelements-1;
print SUMMARY "\nFeatures in model: $modelfeatures\n";
print  "\nFeatures in model: $modelfeatures\n";

$wc=0;
$wordlist=$model."WordList.txt";
undef %wl;
undef %wi;

open(WORDLIST, "<$wordlist") or die "can't open $wordlist: $!";
 while ((defined ($line = <WORDLIST>))) {
   chomp $line;
   ($justword,$wordfreq)=split(/\s+/, $line);
#   print "1".$justword."1";
   $wl{$justword}=$wc;
   $wi{$wc}=$justword;

   $wc++;

   }
print SUMMARY "Features in FeatureList: $wc\n";
print  "Features in FeatureList: $wc\n";
$numMissing=scalar(@missing);
print SUMMARY "Missing in model: $numMissing features:\n";
    print "Missing in model: $numMissing features:\n";
foreach $j (@missing) {
$key=$wi{$j};
$idftmp=$wd{$key};
       $pperc=$wdp{$key}*100.0/$wd{$key};
       $nperc=$wdn{$key}*100.0/$wd{$key};
       $absdiffperc=abs($pperc-$nperc);

print SUMMARY "$j: $wi{$j}:$idftmp $pperc% $nperc%\n";
print  "$j: $wi{$j}:$idftmp $pperc% $nperc%\n";
}

foreach $key (sort (keys(%wd)))
{
       $idftmp=$wd{$key};
       $pperc=$wdp{$key}*100.0/$wd{$key};
       $nperc=$wdn{$key}*100.0/$wd{$key};
       $diffperc=($pperc-$nperc);
       $absdiffperc=abs($pperc-$nperc);
       $wordnumber=$wl{$key};
       $modelweight=$wmodel{$wordnumber};
       $absmodelweight=abs($modelweight);
       @tmp=($wordnumber,$key, $idftmp, $modelweight, $pperc, $nperc, $diffperc, $absdiffperc,$wtf{$key}, $wm{$key}, $absmodelweight);
       $tmpout=arrayToCSV(@tmp);
        if ($idftmp>=$minIDF){
        print OUTPUTFILE7 $tmpout, "\n";
                              }
       }
close(OUTPUTFILE7);
  print "$output\n$summary\n";

exit;

$c=0;
 open(INPUTFILE, "<$SVMfile") or die "can't open $SVMfile: $!";
 open(RESULTS, "<$results") or die "can't open $results: $!";
 open(MATRIX, "<$testmatrix") or die "can't open $filename: $!";
 print $testmatrix;
   undef %tpfiles, %tnfiles, %fpfiles, %fnfiles;
  $doccount=0;
  while (defined (($line = <INPUTFILE>))&& (defined ($liner = <RESULTS>))&& (defined ($linem = <MATRIX>))) {
  $doccount++;
  $liner=~s/\s+//g;
  ($linenocomment,$trash)=split(/#/,$line);
  @ftrash=split(/\s+/,$trash);
  ($trash,$fname)=split(/file\:/,@ftrash[2]);
#  $fname=s/___/ /g;
$fnametmp=$fname;
if ($fname=~/(.*?)-\d+$/g) {
$fnametmp=$1;
}
if (-e $fnametmp) {
  open(INPUTTMP, "<$fnametmp") or  print "can't open $fname: $!";



  ( $name, $path, $suffix ) = fileparse( $fname, "\.[^.]*");
  $text="";
  while (defined ($linetmp = <INPUTTMP>)) {
  $text=$text.$linetmp;
  }
  close INPUTTMP;
  } else {
  $text=$fnametmp;
  }
  undef %words;
  undef %wordsweigths;
  undef %wordstotalp;
   undef %wordstotaln;
  @f=split(/[\s+\:]/,$linenocomment);
  $cat=@f[0];
 $len=@f;
for ($i=1;$i<$len;$i=$i+2)
{
$l=@f[$i];
$v=@f[$i+1];
$word=$wi{$l};
$words{$word}=$v;
$modelweight=$wmodel{$l};
$wordsweigths{$word}=$modelweight;
if ($modelweight>=0) {
$wordstotalp{$word}=$v*$modelweight;
}
if ($modelweight<0) {
$wordstotaln{$word}=$v*$modelweight;
}

#if (!($w{$l}>0)) {
#                        $wc++;
#                        $w{$l}=$wc;
#
#                        }  #if
#$wf{$l}=$wf{$l}+$v;
} #for
$termssection="";
$positivecount=0;
$negativecount=0;
foreach $word (sort {$wordstotalp {$b} <=> $wordstotalp {$a}} keys %wordstotalp )
{
$positivecount++;
$termssection=$termssection."$word=$words{$word}|$wordsweigths{$word}|$wordstotalp{$word}, ";
}
$termssection=$termssection."\n--\n";
foreach $word (sort {$wordstotaln {$a} <=> $wordstotaln {$b}} keys %wordstotaln )
{
$negativecount++;
$termssection=$termssection."$word=$words{$word}|$wordsweigths{$word}|$wordstotaln{$word}, ";
}
$docsection="$liner|$cat|$name|$fname\n$text\n-------\n$linem\n----------------------\n$termssection\n---------------------------------------------------------------------------\n\n";

if (($cat==1) && ($liner > $POSTHRESHOLD)) {
$tpfiles{$fname}=$liner;
print TPMATRIX   $linem;
print TP   $docsection;
 }
if (($cat==-1) && ($liner < $NEGTHRESHOLD)) {
$tnfiles{$fname}=$liner;
print TNMATRIX   $linem;
print TN   $docsection;

 }
if (($cat==-1) && ($liner > $POSTHRESHOLD)) {
$fpfiles{$fname}=$liner;
print FPMATRIX   $linem;
print FP   $docsection;
 }
if (($cat==1) && ($liner < $NEGTHRESHOLD)) {
$fnfiles{$fname}=$liner;
print FNMATRIX   $linem;
print FN   $docsection;
 }


 }  #while
print SUMMARY "Total Documents: $doccount\n";

#foreach $filename (sort {$tpfiles {$b} <=> $tpfiles {$a}} keys %tpfiles )
#{

#}

exit;

sub arrayToCSV {
my @input=@_;
my $ret="";
foreach $i (@input)
{
$ret=$ret."\"".$i."\"".",";
}
if (length ($ret) >1) {
chop $ret;
}
return $ret;
}
}
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
  $ret=`perl2exe\\perl2exe.exe $pl`;
  }
  }
  if (-e $exe) {
  $command=~s/$subst/$exe/ig;
  }
  }
  $ret=`$command`;
  return $ret;
}

