
#testMatrixSVM\toystestmatrix.txtSVM.txt testResultsSVM\TRkitchendining.mp3playersbig.trainmatrix.0.1.toystestmatrix.txtSVM.txt delete.me.txt use Statistics::Contingency; #use List::AllUtils qw( :all ); use List::Util qw/sum/; use List::MoreUtils qw/any minmax/;
use Statistics::Contingency;
use List::Util qw(min max sum);
use Getopt::Long;

$trainf=shift;
$result=shift;
$output=shift;

if (length($output)<2) {$output=$result."EVAL.txt";}  open(OUT, "> $output") or die "can't open $output: $!";

$outputpr=$result."EVAL.PR.txt";
$outputforpr=$result."OUTPUTPR.txt";
 open(OUTPR, "> $outputpr") or die "can't open $outputpr: $!";

push (@all_categories, 1);
push (@all_categories, -1);
 my $s = new Statistics::Contingency(categories => \@all_categories);



   open(INPUTFILE, "< $trainf") or die "can't open $trainf: $!";
   open(INPUTFILE2, "< $result") or die "can't open $result: $!";
   $count=0;
   while (defined ($line = <INPUTFILE>) && defined ($line2 = <INPUTFILE2>)) {

   @f=split(/\s/,$line);
  $cor=$f[0];
  
  @f2=split(/\s/,$line2);
  $ass=$f2[0];
  if($cor < 0 ) { $correct_class[$count]=0;}
  if($cor > 0) {$correct_class[$count]=1}
  #$correct_class[$count]=$cor;
  $predicted_score[$count]=$ass;
  
  if ($ass<=0) {$ass=-1}
  else {
  if ($ass>0) {$ass=1}
  else {
  die "Assigned category is zero; $line2 $line1";
  }
  }

  $correct_categories=$cor;
  $assigned_categories=$ass;
   $s->add_result($assigned_categories, $correct_categories);
   $count++;
 }
 
 $min_score=min(@predicted_score);
 $max_score=max(@predicted_score);
 print "min=$min_score max=$max_score\n";  $total_positives=sum(@correct_class);
 print "total positives= $total_positives\n";
 
 @predicted_normalized_score=map(($_ - $min_score)/($max_score - $min_score), @predicted_score);  my @idxes =  sort { $predicted_normalized_score[$b] <=> $predicted_normalized_score[$a] } 0..$#correct_class; @correct_class  = @correct_class [ @idxes ]; @predicted_normalized_score = @predicted_normalized_score[ @idxes ];
  $correct_so_far=0;
  for ($i=0; $i<$count; $i++) {
    $correct_so_far+=$correct_class[$i];
    $prec=$correct_so_far/($i+1);
    $recall=$correct_so_far/$total_positives;
    push(@prec_curve,$prec);
    push(@rec_curve, $recall);
    print  OUTPR "$prec\t$recall\n";
  }
  close OUTPR;

 #print "$command\n";
 print " Micro-F1: ", $s->micro_F1, " Macro-F1: ", $s->macro_F1, " Accuracy2: ", $s->micro_accuracy," Error: ", $s->macro_error,"\n";  print " Micro-precision: ", $s->micro_precision,  " Micro-recall: ", $s->micro_recall, " Macro-precision: ", $s->macro_precision, " Macro-recall: ", $s->macro_recall,"\n";

 print $s->stats_table; # Show several stats in table form
 my $stats = $s->category_stats;
  while (my ($cat, $value) = each %$stats) {

   print "Category '$cat' \n";
   print "  F1 $value->{F1} ";
   print "  Accuracy $value->{accuracy}\n";
   print "  Precision $value->{precision} ";
   print "  Recall $value->{recall}\n";
 }

   
while (my ($cat, $value) = each %$stats) {
   print  "Category '$cat' (Redundant) \n";
   print  " C$cat-F1: $value->{F1} ";
   print  " C$cat-Accuracy: $value->{accuracy}\n";
   print  " C$cat-Precision: $value->{precision} ";
   print  " C$cat-Recall: $value->{recall}\n";

   }
print OUT "$command\n";
print OUT " Micro-F1: ", $s->micro_F1, " Macro-F1: ", $s->macro_F1, " Accuracy2: ", $s->micro_accuracy, " Error2: ", $s->macro_error,"\n"; print OUT " Micro-precision: ", $s->micro_precision,  " Micro-recall: ", $s->micro_recall, " Macro-precision: ", $s->macro_precision, " Macro-recall: ", $s->macro_recall,"\n";


 print  OUT $s->stats_table; # Show several stats in table form my $stats = $s->category_stats;  while (my ($cat, $value) = each %$stats) {
   print  OUT "Category '$cat' \n";
   print  OUT "  F1 $value->{F1} ";
   print  OUT "  Accuracy $value->{accuracy}\n";
   print  OUT "  Precision $value->{precision} ";
   print  OUT "  Recall $value->{recall}\n";


while (my ($cat, $value) = each %$stats) {
   print  OUT "Category '$cat' (Redundant) \n";
   print  OUT " C$cat-F1: $value->{F1} ";
   print  OUT " C$cat-Accuracy: $value->{accuracy}\n";
   print  OUT " C$cat-Precision: $value->{precision} ";
   print  OUT " C$cat-Recall: $value->{recall}\n";

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
  #$ret=`perl2exe\\perl2exe.exe $pl`;
  }
  }
  if (-e $exe) {
  $command=~s/$subst/$exe/ig;
  }
  }
  $ret=`$command`;
  return $ret;
}

