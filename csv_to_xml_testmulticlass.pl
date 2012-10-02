$infile=shift;
$dirprefix=shift;

$outfile=$dirprefix."testfile.xml";
open(OUT, ">$outfile");
print OUT "<xml>\n<data>\n";

open(IN,$infile);
while ($record = <IN>) {
  chomp($record);
  ($id,$text)=split(/\t/,$record);
  $text=~s/^\"//g;
  $text=~s/\"$//g;
  print OUT "<document>\n<id>$id<\/id>\n<title><\/title>\n<body>\n<text>$text<text>\n<\/body>\n<category attribute=\"sentiment\">Positive<\/category>\n<\/document>\n";
}
print OUT "<\/data>\n<\/xml>";
close OUT;
close IN;

$cmd='perl makeMatricesXMLP.pl -UseAllDirectoriesFlag -nodebug  -mode train -bodyTag1 title -bodyTag2 body -categoryAttribute sentiment -randomSeed 1000 -numFolds 5 -ExcludeSize 50000 -Pos NoPos -Neg NoNeg -Stoplist  -NoDict  -Stem  -Bigrams  -dir "'.$outfile.'" -Classifier svmperftfidf';
print "$cmd\n";
$torun=`$cmd`;
