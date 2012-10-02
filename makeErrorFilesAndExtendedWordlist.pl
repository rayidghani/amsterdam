use File::Copy;
use File::Basename;
use File::Path;

$POSTHRESHOLD=0.0;
$NEGTHRESHOLD=0.0;


$filename=shift;
$model=shift;
$minIDF=shift;
$results=shift;
$testmatrix=shift;
$output=shift;

( $name, $path, $suffix ) = fileparse( $filename, "\.[^.]*");
( $nameT, $pathT, $suffixT ) = fileparse( $testmatrix, "\.[^.]*");
$errorpath=$path."\ResultsAnalysis";
$errorpathtp=$errorpath."\\tp";
$errorpathtn=$errorpath."\\tn";
$errorpathfp=$errorpath."\\fp";
$errorpathfn=$errorpath."\\fn";

mkpath([$errorpathtp,$errorpathtn,$errorpathfp,$errorpathfn],1);
$tp=$errorpathtp."\\$nameT"."$suffixT"."TP.txt";
$tn=$errorpathtn."\\$nameT"."$suffixT"."TN.txt";
$fp=$errorpathfp."\\$nameT"."$suffixT"."FP.txt";
$fn=$errorpathfn."\\$nameT"."$suffixT"."FN.txt";

$tplist=$errorpathtp."\\$nameT"."$suffixT"."TPlist.html";
$tnlist=$errorpathtn."\\$nameT"."$suffixT"."TNlist.html";
$fplist=$errorpathfp."\\$nameT"."$suffixT"."FPlist.html";
$fnlist=$errorpathfn."\\$nameT"."$suffixT"."FNlist.html";

$tpmatrix=$errorpathtp."\\$nameT"."$suffixT"."TPmatrix.txt";
$tnmatrix=$errorpathtn."\\$nameT"."$suffixT"."TNmatrix.txt";
$fpmatrix=$errorpathfp."\\$nameT"."$suffixT"."FPmatrix.txt";
$fnmatrix=$errorpathfn."\\$nameT"."$suffixT"."FNmatrix.txt";

open(TP,">$tp")or die "can't open $tp:$!";
open(TN,">$tn")or die "can't open $tn:$!";
open(FP,">$fp")or die "can't open $fp:$!";
open(FN,">$fn")or die "can't open $fn:$!";

open(TPLIST,">$tplist")or die "can'topen $tplist:$!";
open(TNLIST,">$tnlist")or die "can'topen $tnlist:$!";
open(FPLIST,">$fplist")or die "can'topen $fplist:$!";
open(FNLIST,">$fnlist")or die "can'topen $fnlist:$!";

open(TPMATRIX,">$tpmatrix")or die "can'topen $tpmatrix:$!";
open(TNMATRIX,">$tnmatrix")or die "can'topen $tnmatrix:$!";
open(FPMATRIX,">$fpmatrix")or die "can'topen $fpmatrix:$!";
open(FNMATRIX,">$fnmatrix")or die "can'topen $fnmatrix:$!";

if (length($minIDF)<1) {
$minIDF=0;
}

#E:\Amazon\AllBalanced\Automotive\matrices\xval\matrices\automotive-ConcatPOSDictPropagNEGBiGramNoStem-DocMatrix.txtN5-2-train.txt E:\Amazon\AllBalanced\Automotive\matrices\xval\models\automotive-ConcatPOSDictPropagNEGBiGramNoStem-DocMatrix.txtN5-2-model.txt 3 E:\Amazon\AllBalanced\Automotive\matrices\xval\results\automotive-ConcatPOSDictPropagNEGBiGramNoStem-DocMatrix.txtN5-2-result.txt
#No filenames or domains in svmlight label is +1 -1.
if (length($output)<2) {$output=$filename."WordListEnhanced.csv";}
#$output5=$filename."SVMLightNumericSubs.txt";
#$output2=$filename."FilenameSVMLight.txt";
#$output3=$filename."CategorySVMLight.txt";
#$output4=$filename."DomainSVMLight.txt";
#$output6=$filename."WordsSVMLight.txt";
#$outputaml=$output.".aml";
#E:\Amazon\simpletest\matrices\simpletest-ConcatPOSDictPropagNEGBiGramNoStem-DocMatrix.txt 3 E:\Amazon\simpletest\models\simpletest-ConcatPOSDictPropagNEGBiGramNoStem-DocModel.txtWordList.txt
$summary=$output."summary.txt";
$SVMfileMAX=$testmatrix."SVMLightMAX.txt";
$c=0;

 # open(OUTPUTFILE, "> $output") or die "can't open $output: $!";

 # open(OUTPUTFILE2, "> $output2") or die "can't open $output2: $!";
#  open(OUTPUTFILE3, "> $output3") or die "can't open $output3: $!";
 # open(OUTPUTFILE4, "> $output4") or die "can't open $output4: $!";
 # open(OUTPUTFILE5, "> $output5") or die "can't open $output5: $!";

 # undef %cf; #file numeric labels
 # undef %cc; #category numeric labels
 # undef %cd; #domain numeric labels
 # undef %w;  #word numeric labels
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

#if (!($w{$l}>0)) {
#                        $wc++;
#                        $w{$l}=$wc;
#
#                        }  #if
#$wf{$l}=$wf{$l}+$v;
$idfdeleteme=$wd{$l};
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



#   $output6=$filename."WordListMAX.txt";;
#  print OUTPUTFILE6 $doccount, "\n";
#  open(OUTPUTFILE6, "> $output6") or die "can't open $output6: $!";
#  print OUTPUTFILE6 "Word", "\t", "Number", "\t", "Total Frequency", "\t","Num Documents", "\t", "Max", "\n";
#foreach $key (sort (keys(%w)))
#{
#       print OUTPUTFILE6 $key, "\t", $wm{$key}, "\n";
#}

 #$output7=$filename."WordList-$wc-NumDoc-$doccount.txt";
  $output7=$output;
  open(OUTPUTFILE7, "> $output") or die "can't open $output: $!";
  open(SUMMARY, "> $summary") or die "can't open $summary: $!";
#  print OUTPUTFILE6 "Word", "\t", "Number", "\t", "Total Frequency", "\t","Num Documents", "\t", "Max", "\n";

@tmp=("Feature","IDF","ModelWeight","PositivePerc","NegativePerc","AbsDiffPErc","TotalWordFrequency","MaxFrequency");
$tmpout=arrayToCSV(@tmp);
print OUTPUTFILE7 $tmpout, "\n";
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
for ($n=1;$n<$numelements;$n++){
$tmp=@elements[$n];
($wordnum,$weight)=split(":", $tmp);
$wmodel{$wordnum}=$weight;
}
$modelfeatures=$numelements-1;
print SUMMARY "Features in model: $modelfeatures\n";
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


foreach $key (sort (keys(%wd)))
{
       $idftmp=$wd{$key};
       $pperc=$wdp{$key}*100.0/$wd{$key};
       $nperc=$wdn{$key}*100.0/$wd{$key};
       $absdiffperc=abs($pperc-$nperc);
       $wordnumber=$wl{$key};
       $modelweight=$wmodel{$wordnumber};
       @tmp=($key, $idftmp, $modelweight, $pperc, $nperc, $absdiffperc,$wtf{$key}, $wm{$key});
       $tmpout=arrayToCSV(@tmp);
        if ($idftmp>=$minIDF){
        print OUTPUTFILE7 $tmpout, "\n";
                              }
       }
close(OUTPUTFILE7);
  print "$output: $c lines processed. Word Count:$wc.\n";
$c=0;
 open(INPUTFILE, "<$SVMfileMAX") or die "can't open $SVMfileMAX: $!";
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
$ret=$ret.$i.",";
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

