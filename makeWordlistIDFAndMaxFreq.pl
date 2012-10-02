use File::Copy;
use Config::Simple;
use Getopt::Long;


$filename=shift;
$minIDF=shift;
$output=shift;

if (length($minIDF)<1) {
$minIDF=0;
}
#No filenames or domains in svmlight label is +1 -1.
if (length($output)<2) {$output=$filename."WordListIDFANDMAX.txt";}
#$output5=$filename."SVMLightNumericSubs.txt";
#$output2=$filename."FilenameSVMLight.txt";
#$output3=$filename."CategorySVMLight.txt";
#$output4=$filename."DomainSVMLight.txt";
#$output6=$filename."WordsSVMLight.txt";
#$outputaml=$output.".aml";

$c=0;
 open(INPUTFILE, "< $filename") or die "can't open $filename: $!";
 # open(OUTPUTFILE, "> $output") or die "can't open $output: $!";

 # open(OUTPUTFILE2, "> $output2") or die "can't open $output2: $!";
#  open(OUTPUTFILE3, "> $output3") or die "can't open $output3: $!";
 # open(OUTPUTFILE4, "> $output4") or die "can't open $output4: $!";
 # open(OUTPUTFILE5, "> $output5") or die "can't open $output5: $!";

 # undef %cf; #file numeric labels
 # undef %cc; #category numeric labels
 # undef %cd; #domain numeric labels
 # undef %w;  #word numeric labels
 # undef %wf; #word frequencies
  undef %wm; #word total frequency for redundancy
  undef %wd; #word documents
  $cfc=0;
  $ccc=0;
  $cdc=0;
  $wc=0;
  $doccount=0;
  while (defined ($line = <INPUTFILE>)) {
  $doccount++;
  ($linenocomment,$trash)=split(/#/,$line);
  @f=split(/\s+/,$linenocomment);
  $file=@f[0];
#  if ($file=~/E:\\Amazon\\AllBalanced\\Automotive\\negative\\Automotive\.ReplacementParts\.positive\.C15719731IS-1-V0RA3F5O60ZB7XXT9BlrgL1620W284P19\.txt/ig) {
#print $file."\n";
#}
  $cat=lc(@f[1]);

$len=@f;
for ($i=2;$i<$len;$i=$i+2)
{
$l=@f[$i];
$v=@f[$i+1];
#if ($l=~/abandoned/ig) {
#print $l."\n";
#}
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

#debug
#if ($l eq "abc") {
#print "Here: $l";
#}
#end debug

if (!(exists  $wm{$l})){
$wm{$l}=0;
}
#if ($v>$wm{$l}) {
#$wm{$l}=$v;
#}
$wm{$l}=$wm{$l}+$v;
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
#  print OUTPUTFILE6 "Word", "\t", "Number", "\t", "Total Frequency", "\t","Num Documents", "\t", "Max", "\n";
print OUTPUTFILE7 $doccount, "\n";

foreach $key (sort (keys(%wd)))
{
       $idftmp=$wd{$key};
       if ($idftmp>=$minIDF) {
       print OUTPUTFILE7 $key, "\t", $idftmp, "\t", $wm{$key}, "\n";
       }
}

close(OUTPUTFILE7);

  print "$output:  $doccount lines processed. Word Count:$wc.\n";


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


