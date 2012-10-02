$infile=shift; #infile is the tsv with two fields: class, text
$dirprefix=shift; #$dirprefix is the directory where the xml files for training should be stored and where the models will be
$testfile=shift; #testfile is the tsv file that needs to be scored two fields: id, text
$modeldir=$dirprefix."\models\\";
$train=shift;
$test=shift; #do scoring or not


if ($train) {
  #open training file and load it
  open(IN,$infile);
  while ($record = <IN>) {
	 chomp($record);
  ($class,$text)=split(/\t/,$record);
  $classes{$class}=1;
  }
  close IN;

  #create xml file for each class and then train each model
  foreach my $currentclass ( keys %classes )
  {
    $outfile=$dirprefix.$currentclass.".xml";
    open(OUT, ">$outfile");
    open(IN,$infile);
    $i=1;
    while ($record = <IN>) {
      chomp($record);
      ($class,$text)=split(/\t/,$record);
      if ($currentclass eq $class) {
        print OUT "<document>\n<id>$i<\/id>\n<title><\/title>\n<body>\n<text>$text<text>\n<\/body>\n<category attribute=\"sentiment\">Positive<\/category>\n<\/document>\n";
      }
      else {
        print OUT "<document>\n<id>$i<\/id>\n<title><\/title>\n<body>\n<text>$text<text>\n<\/body>\n<category attribute=\"sentiment\">Negative<\/category>\n<\/document>\n";
      }
      $i++;
    }
    print OUT "<\/data>\n<\/xml>";
    close OUT;
    close IN;
    #train model
    $cmd='perl makeMatricesXMLP.pl -UseAllDirectoriesFlag -nodebug  -mode train -bodyTag1 title -bodyTag2 body -categoryAttribute sentiment -randomSeed 1000 -numFolds 5 -ExcludeSize 50000 -Pos NoPos -Neg NoNeg -Stoplist  -NoDict  -Stem  -Bigrams  -dir "'.$outfile.'" -Classifier svmperftfidf';
    print "$cmd\n";
    $torun=`$cmd`;
  } #end while each class
}  # end train if

#take test tsv file  and convert it to xml
if ($test) {
	$outfile=$dirprefix."testfile.xml";
	open(OUT, ">$outfile");
	print OUT "<xml>\n<data>\n";
	
	open(IN,$testfile);
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
 
 # find all models in model directory and score the test  xml file with each model
	opendir (DIR, $modeldir) or die $!;
  $modelnumber=0;
  while (my $file = readdir(DIR)) {
    if ($file=~/DocModel\.txt$/i) {
			#test outfile with file model
			$modelfile=$modeldir.$file;
			if ($file=~/^(.*?)\./) {
        $modelname=$1;
      }
      $modelnumber++;
      if ($modelnumber <= 1) {
        $cmd="start /b /realtime perl makeMatricesXMLP.pl -UseAllDirectoriesFlag -nodebug  -mode score -bodyTag1 title -bodyTag2 body -categoryAttribute sentiment -randomSeed 1000 -numFolds 5 -ExcludeSize 50000 -Pos NoPos -Neg NoNeg -Stoplist  -NoDict -Stem -Bigrams -dir \"$outfile\" -model \"$modelfile\" -Classifier svmperftfidf";
         print "$cmd\n";
        $matrixfile=`$cmd`;
      }
      else {
        $cmd="start /b /realtime perl runmodel.pl  -Features \"$matrixfile\"  -model \"$modelfile\"  -classifier svmperftfidf ";
        print "$cmd\n";
        $cmdoutput=`$cmd`;
      }


      #$newfilename=$cmdoutput.'-'.$modelname;
      #$cpcmd="copy \"$cmdoutput\" \"$newfilename\"";
      #print "$cpcmd\n";
      #$tmp=`$cpcmd`;
      
			$resultdir=$dirprefix.'matrices\\';
			opendir (RESULTDIR, $resultdir) or die $!;
			while ($resultfile = readdir(RESULTDIR)) {
				if ($resultfile =~ /^testfile.*result\.txt$/i) {
					$resultpath=$resultdir.$resultfile;
					$newresultpath="results_".$modelname.".txt";
          $tmp="\"$resultdir$newresultpath\"";
          push(@resultfiles, $tmp);
          push(@modelnames,$modelname);
					$renamecmd="ren \"$resultpath\" \"$newresultpath\"";
					`$renamecmd`;
          #open(TMP, $tmp);
          #@tmparray=<TMP>;
          #$modelresultsarray{$modelname}=\@tmparray;
          close TMP;
          #undef @tmparray;
					last;
				}
			}
		}
  }
 	closedir(DIR);
  
  $allresultfiles= join " ", @resultfiles;
  $combinedresultsfile="$resultdir"."allresults.txt";
  $pastecmd="paste $allresultfiles > \"$combinedresultsfile\"";
  $pastecmdoutput=`$pastecmd`;
  $tmpheader=join "\t", @modlenames;
  #add column headers
  #paste textdata all_results > ...
  # remove characters
  # tr -d "\015" < all_results.txt > all_results_fixed.txt
  #find max score and class
  $winnerfile="$resultdir"."winnerclass.txt";
  open (FINAL, $combinedresultsfile);
  open(OUTPUT, ">$winnerfile");
  while ($record = <FINAL>) {
    chomp($record);
    @data=split(/\t/,$record);
    my $idxMax = 0;
    $data[$idxMax] > $data[$_] or $idxMax = $_ for 1 .. $#data;
    print OUTPUT "$idxMax\t$data[$idxMax]\t$modelnames[$idxMax]\n";
    #$count[$idxMax]++;
  }
  close FINAL;
}
