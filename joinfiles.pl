use Getopt::Long;
$result = GetOptions (
"file1=s" => \$file1, # directory or xmlfile
"file2=s" => \$file2, # part of speech
"file3=s" => \$file3,
"file4=s" => \$file4,
"separator=s" => \$sparator,
"output=s" => \$output);
$f1Flag=0;
$f2Flag=0;
$f3Flag=0;
$f4Flag=0;
if ((!(defined ($file1)))|| (!(defined ($file2)))) {
  die "You must join at least two files!";
}

if (!(defined ($output))) {
  $output=$file1."JOINED.txt";
}
if (!(defined ($separator))) {
  $separator="";
}

open( OUTPUT,    ">$output" )    or die "can't open $output: $!";

if ((defined($file1)) && (-e $file1)){
open( FILE1,    ">$file1" )    or die "can't open $file1: $!";
$f1Flag=0;
}
if ((defined($file2)) && (-e $file2)){
open( FILE1,    ">$file2" )    or die "can't open $file2: $!";
$f2Flag=0;
}

while (($line1=<FILE1>) && ($line1=<FILE1>)){
 chomp $line1;
 chomp $line2;
 $oline=$line1.$separator.$line2."\n";
 print OUTPUT $oline;
}
exit;
