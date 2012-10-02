use File::Path;
use File::Basename;
use Scalar::Util qw(looks_like_number);
use Config::Simple;
#E:\Amazon\GroceriesTest\xval\results
$dir = shift;

@files=();
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
#$timestamp="$mon-$mday-$hour-$min";
$timestamp="";

if (-d $dir) {
 # if (!($dir=~/\\\"$/)) {
  #  $evalsingle=$dir."\\"."EvalCollectedIndividual-$timestamp.csv";
  #  $evalaverage=$dir."\\"."EvalCollectedAverage-$timestamp.csv";
  #}
  #else {
#     $dir=~s/\"$//;
     $evalsingle=$dir."EvalCollectedIndividual-$timestamp.csv";
    $evalaverage=$dir."EvalCollectedAverage-$timestamp.csv";
 # }



opendir(DIR, $dir);
@files2 = readdir(DIR);
closedir(DIR);
    foreach $file (@files2) {
      next if $file =~ /^\.\.?$/;     # skip . and ..
      next unless $file =~ /\-result\.txt$/;     # skip . and ..
      push (@files, "$dir\\$file");
      }
} else {
open(DIR, "<$dir") or die "can't open $dir: $!";
while ($line=<DIR>) {
@tmp=split (/,\s*/, $line);
if (scalar(@tmp)>3) {
$file=$tmp[3];
} else {
$matrix=$tmp[0];
chomp $matrix;
next;
}
push(@files, "$file");

}
#($filename, $dir) = fileparse($dir);
$evalsingle=$dir."EvalCollectedIndividual-$timestamp.csv";
$evalaverage=$dir."EvalCollectedAverage-$timestamp.csv";
#$configfile="$matrix.cfg";
#print $configfile;
if (-e "$matrix.cfg") {
$cfg = new Config::Simple("$matrix.cfg");
$cfg->autosave(1);
  $cfg->param("evalsingle",$evalsingle);
  $cfg->param("evalaverage",$evalaverage);


   $cfg->write();
                       }
}


open(OUTFILE, ">$evalsingle") or die "can't open $evalsingle: $!";

open(OUTFILEAVG, ">$evalaverage") or die "can't open $evalaverage: $!";



$docnum=-1;
$numfiles=scalar(@files);
undef @avgvals;
foreach $file (@files) {

$docnum++;
#print $file, "\n";
print ".";

open(FILE, "<$file") or die "can't open $file: $!";

my $eval = do { local $/; <FILE> };

#$eval = <FILE>;
close FILE;
undef @atts;
undef @vals;


getattsandvals($eval);
$file=trim($file);
push @vals, trim($file);
if ($docnum==0) {
foreach $a (@atts) {
push (@avgvals,0.0);
}
push @atts, "file";

push @avgvals, $dir;

$numatts=scalar(@atts);
$outline=arrayToCSV(@atts);
$outline=$outline."\n";
print OUTFILE $outline;
print OUTFILEAVG $outline;
}
$outline=arrayToCSV(@vals);
$outline=$outline."\n";
print OUTFILE $outline;



for ($i=0;$i<$numatts;$i++) {
if (looks_like_number(@vals[$i])) {
@avgvals[$i]=@avgvals[$i]+@vals[$i];
# } else {@avgvals[$i]=@avgvals[$i]."+".@vals[$i]};
  } else {@avgvals[$i]=@vals[$i]}; #avoid large file
}
}
for ($i=0;$i<$numatts;$i++) {
if (looks_like_number(@avgvals[$i])) {
@avgvals[$i]=@avgvals[$i]/($numfiles*1.0);
 }
}
$outline=arrayToCSV(@avgvals);
print OUTFILEAVG $outline;

close OUT;
print"\n $docnum documents processed.";
exit;

sub getattsandvals{
($val)=@_;
my $a;
my $b;

while ($val=~ /(.+?-command)\: (.+?)\n/ig) {
$a=trim($1);
$b=trim($2);
push @atts, $a;
push @vals, $b;
}
$val=~ s/.+?-command\: .+?\n/ /ig;

while ($val=~ /(.+?)\: (.+?)[ \n]/ig) {
$a=$1;
$b=$2;
push @atts, $a;
push @vals, $b;
}
}

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
sub trim{
my ($f)=@_;
    $f=~s/^\s+//;
    $f=~s/\s+$//;
    return $f;
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

