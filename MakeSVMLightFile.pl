use Config::Simple;
use Getopt::Long;
use File::Copy;
#test command line
#blah "C:\Users\marko_krema\Documents\Visual Studio 2010\Projects\SentimentTest1\SentimentTest1\webSentenceunknownMatrix.txt" "E:\Amazon\m\fullmatrix\global5matrix.txtWordList-149954-IDFNumDoc-246631.txt" 0 "C:\Users\marko_krema\Documents\Visual Studio 2010\Projects\SentimentTest1\SentimentTest1\webSentenceunknownMatrixSVM.txt"
#blah fullmatrix\global5matrix.txt fullmatrix\global5matrix.txtWordList-149954-IDFNumDoc-246631.txt 0

$filename=shift;
$wlfilename=shift;
$idfthreshold=shift;
$outputIDF=shift;
$outputMAX=shift;
$missingword=0;
$duplicateword=0;
#No filenames or domains in svmlight label is +1 -1.
if (length($outputIDF)<2) {$outputIDF=$filename."SVMLightIDF.txt";}
if (length($outputMAX)<2) {$outputMAX=$filename."SVMLightMAX.txt";}
$output5=$filename."SVMLightNumericSubs.txt";
$output2=$filename."FilenameSVMLight.txt";
#$output3=$filename."CategorySVMLight.txt";
$output4=$filename."DomainSVMLight.txt";
$output6=$filename."WordsSVMLight.txt";
$outputaml=$output.".aml";

  undef %w;  #word numeric labels
  undef %wm; #word max frequency
  undef %widf; #word idf

$c=0;
$wordlinect=0;
$wc=1;
 open(WLINPUTFILE, "< $wlfilename") or die "can't open $wlfilename: $!";
while (defined ($line = <WLINPUTFILE>)) {
chomp $line;
$wordlinect++;
if ($wordlinect==1) {
$doccount=$line;
}
else {

@f=split(/\s+/,$line);
$wline=$f[0];
$mline=$f[1];
$maxline=$f[2];
if (!($mline>$idfthreshold))  {next;} #skip words below the idf threshold

if (!($w{$wline}>0)) {
  $w{$wline}=$wc;
  $wc++;
       }
 $wm{$wline}=$maxline;

if (!(exists  $widf{$wline})){
$widf{$wline}=$mline;
} else {
$duplicateword=1;
die "Duplicate word: $wline in $wlfilename";}

} #else
} #while
$wordcount=$wc;
$wcount=keys( %w );
$wmcount=keys( %wm );
$idfcount=keys( %widf );
 open(INPUTFILE, "< $filename") or die "can't open $filename: $!";
  open(OUTPUTFILEIDF, "> $outputIDF") or die "can't open $outputIDF: $!";
  open(OUTPUTFILEMAX, "> $outputMAX") or die "can't open $outputMAX: $!";
$wc=0;


  
  while (defined ($line = <INPUTFILE>)) {
  ($linenocomment,$trash)=split(/#/,$line);
  @f=split(/\s+/,$linenocomment);
  $file=@f[0];
  $cat=lc(@f[1]);
  $dom="";
  if ($file=~/.*\\(.*?)\\/i) {
                     $dom=lc($1);
                     }

#$newline="file:$File Domain:$dom Category:$cat ";
#fixing label for svmlight
if (lc($cat) eq lc("positive")) {
$catlight=1;
}
else {
if (lc($cat) eq lc("negative")) {
$catlight=-1;
}
else
{
$catlight=lc($cat);
}
 } #else

$newline="$catlight ";
$maxline="$catlight ";
$newold="$catlight ";
#$newline="file:$File Domain:$dom Category:$cat ";
$postlinesvmlight=" #Domain:$dom Category:$cat file:$file";
$postlinesvmlight="";
$newline5="1:$cf{$file} 2:$cd{$dom} 3:$cc{$cat} ";

$len=@f;
$numWords=($len-2.0)/2.0;
%incvalues=();
%maxvalues=();
for ($i=2;$i<$len;$i=$i+2)
{
$l=@f[$i];
if (!($w{$l}>0)) {

$missingword=1;
#                      die "Word $l not in $wlfilename while processing $filename and outputting $output.\n$command\n  file=$file, cat=$cat, dom=$dom len=$len\n";
next;
#print AML "<attribute name =\"$l\" valuetype =\"integer\" blocktype =\"single_value\" />\n";

                        }  #if
$v=@f[$i+1];
#$tfidfvalue =$v/$wd{$l};
#scale by total number of occurances of that word
#$sv=$v/$wf{$l};
#$sv=$v;
#$sv=$tfidfvalue;
#scale by maximum frequency of that word 0 ..1
#$lfreq=$wm{$l};
#$sv=$v/$lfreq;
$tfidfv=$widf{$l};
if ($l=~/^GLOB_/)
{
$sv=$v/$numWords;
}
else
{
$sv=$v*log(($doccount*1.0)/$tfidfv);
}
#$msv=$v*1.00/$wm{$l};
$msv=$v/$numWords;

$attindex=$w{$l};
$incvalues{$attindex}=$sv;
$maxvalues{$attindex}=$msv;
if ($attindex > $wcount) {
print $attindex . " " . $l;
}
#$newlineold=$newlineold.$attindex.":".$sv." ";
#$newline5=$newline5.($attindex+3).":".$v." ";


}
$l2norm=0.0000000001;
foreach $key (sort {$a <=> $b} (keys(%incvalues))) {
   $l2norm=$l2norm+($incvalues{$key}*$incvalues{$key});
}
$l2norm=sqrt($l2norm);

foreach $key (sort {$a <=> $b} (keys(%incvalues))) {
   $incvalues{$key}=$incvalues{$key}/$l2norm;
   
   $newline=$newline.$key.":".$incvalues{$key}." ";
   $maxline=$maxline.$key.":".$maxvalues{$key}." ";
}

#print ".";
chop $newline;
chop $maxline;
#chop $newline5;
#chop $newlineold;

#$newline=$newline."\n";

      $c++;
      print OUTPUTFILEIDF "$newline $postlinesvmlight\n";
      print OUTPUTFILEMAX "$maxline $postlinesvmlight\n";

if (($c%10000)==0) { print "$c "; }
 #     print OUTPUTFILE5 "$newline5\n";


         } #while
  close (INPUTFILE);
  close(OUTPUTFILEIDF);
  close(OUTPUTFILEMAX);
  close(OUTPUTFILE5);

close(OUTPUTFILE2);
close(OUTPUTFILE3);
close(OUTPUTFILE4);
close(OUTPUTFILE6);
close(AML);
  print "$output: $c lines processed. Word Count:$wc.\n";


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


