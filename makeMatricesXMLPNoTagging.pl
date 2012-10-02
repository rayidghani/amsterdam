
use File::Path;
use Lingua::Stem::En;
#use Lingua::EN::Tagger;



#use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
#use Lingua::EN::Sentence qw( get_sentences add_acronyms );
use File::Basename;
use Getopt::Long;

# use XML::SAX::Expat;
#  use XML::SAX::MyFooHandler;

#  use MyHandler;

  #use XML::SAX::XYZHandler;
if (!defined($PPos)) {
$PPos="NoPOS";
}

if (!defined($PDict)) {
$PDict="Dict";
}

if (!defined($PNeg)) {
$PNeg="BothNEG";
}

if (!defined($PBigrams)) {
$PBigrams="BiGram";
}

if (!defined($PStem)) {
$PStem="NoStem";
}

if (!defined($PMode)) {
$PMode="train";
}
if (!defined($dffilter)) {
$dffilter=0;
}


if (!defined($categoryAttribute)) {
$categoryAttribute="sentiment";
}
if (!(defined($dictionarydir))) {
	$dictionarydir = "dictionaries";
}

if (!(defined($stopdir))) {
 $stopdir = "$dictionarydir\\stoplists";
}

if (!(defined($model))) {
	$model = "Electronics-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocModel.txt";
}

if (!(defined($testmatrix))) {
 $testmatrix = "test\\ElectronicsCameraAndPhotoB-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocMatrix.txt";
}


#E:\Amazon\testxml\TestInput.xml.txt
#E:\Amazon\testxml\TestInput.xml.txt
#E:\Amazon\GroceriesTest

$PBigramsFlag=1;
$PDictFlag=1;

$sentenceMatrixFlag=0;
$maximumNegationWindow=4;

$stoplistFlag = 1;
$saveCleanFiles=0;

$numFolds=10;
$randomSeed=1000;


$result = GetOptions (
"dir=s" => \$dir, # directory or xmlfile
"Pos=s" => \$PPos, # part of speech
"Dict!" => \$PDictFlag,
"Neg=s" => \$PNeg,
"Bigrams!" => \$PBigramsFlag,
"Stem!" => \$PStemFlag,
"SentenceMatrix!" => \$sentenceMatrixFlag,
"Stoplist!" => \$stoplistFlag,
"SaveCleanSentenceFiles!" => \$saveCleanFiles,
"Mode=s" => \$PMode,
"DFFilter=i" => \$dffilter,
"CategoryAttribute=s" => \$categoryAttribute,
"Model=s" => \$model,
"NegWindow=i" => \$maximumNegationWindow,
"StoplistDirectory=s" => \$stopdir,
"DictionaryDirectory=s" => \$dictionarydir,
"NumFolds=i" => \$numFolds,
"RandomSeed=i" => \$randomSeed,
"Testmatrix=s" => \$testmatrix
 );
 
if ($saveCleanFiles) {
$sentenceMatrixFlag=1;
}

if ($PBigramsFlag) {
$PBigrams = "BiGram"
}
else {
$PBigrams = "UniGram"
}
if ($PDictFlag) {
$PDict = "Dict"
}
else {
$PDict = "NoDict"
}

if ($PStemFlag) {
$PStem = "Stem"
}
else {
$PStem = "NoStem"
}




#$matrixdir = $dir . "\\matrices\\";

# my $tag = Lingua::EN::Tagger->new(longest_noun_phrase => 5,
#                                      weight_noun_phrases => 0);

# start timer
$start        = time();
$relaxHMMFlag = 0
  ; #"Relax the Hidden Markov Model: this may improve accuracy for uncommon words, particularly words used polysemously"






$paramSuffix="-";
$PPos="NoPOS";
if ($PPos eq "NoPOS") {
$POSFlag=0;
$concatenatePOSFlag=0;
$paramSuffix=$paramSuffix.".".$PPos;
}
elsif ($PPos eq "POS") {
$POSFlag=1;
$concatenatePOSFlag=0;
$paramSuffix=$paramSuffix.".".$PPos;
}
elsif ($PPos eq "ConcatPOS") {
$POSFlag=1;
$concatenatePOSFlag=1;
$paramSuffix=$paramSuffix.".".$PPos;
}


if ($PDict eq "NoDict") {
$lexicalFlag             = 0;
$paramSuffix=$paramSuffix.".".$PDict;
}
elsif ($PDict eq "Dict") {
$lexicalFlag             = 1;
$paramSuffix=$paramSuffix.".".$PDict;
}
if ($PNeg eq "NoNEG") {
$negationPropagationFlag = 0;
$negationFeatureFlag = 0;
$removeNegatedFlag=0;
$paramSuffix=$paramSuffix.".".$PNeg;
}
elsif ($PNeg eq "NEG") {
$negationPropagationFlag = 0;
$negationFeatureFlag = 1;
$removeNegatedFlag=0;
$paramSuffix=$paramSuffix.".".$PNeg;
}
elsif ($PNeg eq "PropagNEG") {
$negationPropagationFlag = 1;
$negationFeatureFlag = 0;
$removeNegatedFlag=0;
$paramSuffix=$paramSuffix.".".$PNeg;
}
elsif ($PNeg eq "BothNEG") {
$negationPropagationFlag = 1;
$negationFeatureFlag = 1;
$removeNegatedFlag=0;
$paramSuffix=$paramSuffix.".".$PNeg;
}
elsif ($PNeg eq "RemoveNEG") {
$negationPropagationFlag = 1;
$negationFeatureFlag = 1;
$removeNegatedFlag=1;
$paramSuffix=$paramSuffix.".".$PNeg;
}
if ($PBigrams eq "UniGram") {
$PBigramsFlag = 0;
$paramSuffix=$paramSuffix.".".$PBigrams;
}
elsif ($PBigrams eq "BiGram") {
$PBigramsFlag = 1;
$paramSuffix=$paramSuffix.".".$PBigrams;
}
# Works now $PStem="NoStem"; #Stemmer does not work!!!
if ($PStem eq "NoStem") {
$stemFlag = 0;
$paramSuffix=$paramSuffix.".".$PStem;
}
elsif ($PStem eq "Stem") {
$stemFlag = 1;
$paramSuffix=$paramSuffix.".".$PStem;
}
$paramSuffix=$paramSuffix."-";
if ($PMode eq "generic") {
    $paramSuffix="";
    $saveCleanFiles=1;
    $sentenceMatrixFlag=1;
}

if ($PMode eq "train") {
    $trainModelsFlag=1;    } else {
    $trainModelsFlag=0;
}
if ($PMode eq "test") {
    $testModelsFlag=1;    } else {
    $testModelsFlag=0;
}

if ($PMode eq "traintest") {
    $traintestModelsFlag=1;    } else {
    $traintestModelsFlag=0;
}
if ($PMode eq "score") {
    $scoreModelsFlag=1;    } else {
    $scoreModelsFlag=0;
}
if ($PMode eq "xvalidation") {
    $xvalidationModelsFlag=1;    } else {
    $xvalidationModelsFlag=0;
}

if ( $dir =~ /^(.+)\\(.+?)$/ig ) {

	#$outputdir=$1."\\";
	$outputdir = $1;
	$domain    = $2;
}



#my $p = Lingua::EN::Tagger->new( stem => $stemFlag, relax => $relaxHMMFlag );

if ($stoplistFlag) {
	$stopdir = "$dictionarydir\\stoplists";
	%stopwords  = getHashFromDirFilenameStemFlag($stopdir, $stemFlag);
}
if ($lexicalFlag) {
	%lookup = getHashFromDirFilenameStemFlag("$dictionarydir\\dictionaries", $stemFlag);
}

	%negation = getHashFromDirFilenameStemFlag("$dictionarydir\\negation", $stemFlag);


if (-d $dir) {

 $matrixdir = $dir . "\\matrices";
mkdir ($matrixdir,1);
if ($trainModelsFlag) {
$modeldir = $dir . "\\models";
mkdir ($modeldir,1);

}
    $fcleanDoc      = "$dir\\$domain" . "Doc" . "clean.txt";
#$fcleanPgraph   = "$dir\\$domain" . "Pgraph" . "clean.txt";
$fcleanSentence = "$dir\\$domain" . "Sentence" . "clean.txt";

if ($saveCleanFiles) {
 open( CLEANDOC,    ">$fcleanDoc" )    or die "can't open $fcleanDoc: $!";
#open( CLEANPGRAPH, ">$fcleanPgraph" ) or die "can't open $fcleanPgraph: $!";
if ($sentenceMatrixFlag) {
open( CLEANSENTENCE, ">$fcleanSentence" )
  or die "can't open $fcleanSentence: $!";
}
}
$fmatrixDoc        = "$matrixdir\\$domain" .$paramSuffix. "Doc" . "Matrix.txt";
#$fmatrixPgraph     = "$outputdir\\$domain" .$paramSuffix . "Pgraph" . "Matrix.txt";
$fmatrixSentence   = "$matrixdir\\$domain" .$paramSuffix . "Sentence" . "Matrix.txt";

if ($trainModelsFlag) {
$fmodelDoc        = "$modeldir\\$domain" .$paramSuffix. "Doc" . "Model.txt";
$fmodelSentence   = "$modeldir\\$domain" .$paramSuffix . "Sentence" . "Model.txt";

}
#print $fmatrixDoc, "\n";
#print $fmatrixSentence, "\n";
#print $fmatrixDoc, "\n";
open( MATDOC,    ">$fmatrixDoc" )    or die "can't open $fmatrixDoc: $!";
#open( MATPGRAPH, ">$fmatrixPgraph" ) or die "can't open $fmatrixPgraph: $!";
if ($sentenceMatrixFlag) {
open( MATSENTENCE, ">$fmatrixSentence" ) or die "can't open $fmatrixSentence: $!";
              }


@classes = ( "positive", "negative", "neutral", "unknown" );
opendir( DIR, "$dir" );
@files2 = readdir(DIR);
closedir(DIR);
foreach $f (@files2) {
	next if $f =~ /^\.\.?$/;
	next if $f =~ /\.txt$/;
	$missing = 1;

	foreach $c (@classes) {

		#print $f .":".$c."\n";
		if ( $f eq $c ) { $missing = 0; }
	}    #foreach $c
	if ($missing) { next; }
	$class = $f;

	# print $class ."\n";
	$inputdir= $dir . "\\" . $class;
  	opendir( DIR, "$inputdir" );
		@files = readdir(DIR);
		closedir(DIR);
    foreach $f (@files) {
    next if $f =~ /^\.\.?$/;
    next if $f =~ /^\.svn$/;
    $file=$inputdir."\\".$f;
       $text="";
    	open( INPUTFILE, "<$file" ) or die "can't open $file: $!";
     $file=~s/\s+/\_\_\_/g; #replace spaces in file id with ___ to avoid problems later  when splitting
		while ( defined( $line = <INPUTFILE> ) ) {
    $text=$text.$line;
    }
    close INPUTFILE;
    processDoc();
    } #file
   } #classes
   } #kind of file
    elsif (-e $dir) {
    my($filename, $directory) = fileparse($dir);
    chop $directory;
    $xmlfile=$dir;
    $dir=$directory;
    $domain=$filename;
    $fcleanDoc      = "$dir\\$domain" . "Doc" . "clean.txt";
#$fcleanPgraph   = "$dir\\$domain" . "Pgraph" . "clean.txt";
$fcleanSentence = "$dir\\$domain" . "Sentence" . "clean.txt";

if ($saveCleanFiles) {
 open( CLEANDOC,    ">$fcleanDoc" )    or die "can't open $fcleanDoc: $!";
#open( CLEANPGRAPH, ">$fcleanPgraph" ) or die "can't open $fcleanPgraph: $!";
if ($sentenceMatrixFlag) {
open( CLEANSENTENCE, ">$fcleanSentence" )
  or die "can't open $fcleanSentence: $!";
}
}

 $matrixdir = $dir . "\\matrices";
mkdir ($matrixdir,1);
if ($trainModelsFlag) {
$modeldir = $dir . "\\models";
mkdir ($modeldir,1);

}
$fmatrixDoc        = "$matrixdir\\$domain" .$paramSuffix. "Doc" . "Matrix.txt";
#$fmatrixPgraph     = "$outputdir\\$domain" .$paramSuffix . "Pgraph" . "Matrix.txt";
$fmatrixSentence   = "$matrixdir\\$domain" .$paramSuffix . "Sentence" . "Matrix.txt";

if ($trainModelsFlag) {
$fmodelDoc        = "$modeldir\\$domain" .$paramSuffix. "Doc" . "Model.txt";
$fmodelSentence   = "$modeldir\\$domain" .$paramSuffix . "Sentence" . "Model.txt";

}
#print $fmatrixDoc, "\n";
#print $fmatrixSentence, "\n";
#print $fmatrixDoc, "\n";
open( MATDOC,    ">$fmatrixDoc" )    or die "can't open $fmatrixDoc: $!";
#open( MATPGRAPH, ">$fmatrixPgraph" ) or die "can't open $fmatrixPgraph: $!";
if ($sentenceMatrixFlag) {
open( MATSENTENCE, ">$fmatrixSentence" ) or die "can't open $fmatrixSentence: $!";
              }

#my $handler = XML::SAX::XYZHandler->new();
#  my $p = XML::SAX::ParserFactory->parser(Handler => $handler);
#  $p->parse_uri("foo.xml");
  # or $p->parse_string("<foo/>") or $p->parse_file($fh);

 #my $h = XML::SAX::MyFooHandler->new;
# my $h = start_element;
#  my $p = XML::SAX::Expat->new(Handler => $h);
#  $p->parse_file($xmlfile);
#Logic for handling events goes into the handler class (MyHandler in this example), which you write:

# in MyHandler.pm
  # $data is hash with keys like Name and Attributes
  # ...
open( XML, "<$xmlfile" ) or die "can't open $xmlfile: $!";
 $inDocumentFlag=0;
 $xmltext="";
 while( $line=<XML> ) {
  if ($line=~/\<document\>(.*?)/ig) {
  $xmltext=$1;
  $inDocumentFlag=1;
  }elsif ($line=~/(.*?)\<\/document\>/ig) {
  $xmltext=$xmltext.$1;
  $inDocumentFlag=0;
  parseDoc();
  processDoc();
  $xmltext="";
   }elsif ($inDocumentFlag) {
    $xmltext=$xmltext.$line;
   }
  

 
 
 }



   } #xmlfile
   else {
   generateHelp();
   print $help;
   exit;
   }

   
if ($trainModelsFlag) {

$modelcommand="start /b /realtime perl trainmodel.pl \"$fmatrixDoc\" \"$fmodelDoc\" svmperftfidf $dffilter";
print $modelcommand."\n";
$modelresult=runCommand($modelcommand);
#print $modelresult."\n";

if ($sentenceMatrixFlag) {
$modelcommand="start /b /realtime perl trainmodel.pl \"$fmatrixSentence\" \"$fmodelSentence\" svmperftfidf $dffilter";
#print $modelcommand."\n";
$modelresult=runCommand($modelcommand);
#print $modelresult."\n";
}
}

if ($testModelsFlag) {
$testcommand="start /wait /b /high perl testmodel.pl \"$fmatrixDoc\" \"$model\" ";
$testresult=runCommand($testcommand);

if ($sentenceMatrixFlag) {
$testcommand="start /wait /b /high perl testmodel.pl \"$fmatrixSentence\" \"$model\" ";
$testresult=runCommand($testcommand);
}
}



if ($traintestModelsFlag) {
$testcommand="start /wait /b /high perl traintest.pl \"$fmatrixDoc\" \"$testmatrix\" \"$model\" ";
$testresult=runCommand($testcommand);

if ($sentenceMatrixFlag) {
$testcommand="start /wait /b /high perl traintest.pl \"$fmatrixSentence\" \"$testmatrix\" \"$model\" ";
$testresult=runCommand($testcommand);
}
}

if ($scoreModelsFlag) {
$testcommand="start /wait /b /high perl runmodel.pl \"$fmatrixDoc\" \"$model\" ";
$testresult=runCommand($testcommand);

if ($sentenceMatrixFlag) {
$testcommand="start /wait /b /high perl runmodel.pl \"$fmatrixSentence\" \"$model\" ";
$testresult=runCommand($testcommand);
}
}

if ($xvalidationModelsFlag) {
$testcommand="start /wait /b /high perl xvalidationOnMatrix.pl \"$fmatrixDoc\" $numFolds $randomSeed ";
$testresult=runCommand($testcommand);

if ($sentenceMatrixFlag) {
$testcommand="start /wait /b /high perl xvalidationOnMatrix.pl \"$fmatrixSentence\" $numFolds $randomSeed ";
$testresult=runCommand($testcommand);
}
}


   # end timer
$end = time();

# report
#print "\nTime taken was ", ( $end - $start ), " seconds";
print $fmatrixDoc;
exit;

sub processDoc {
 undef %doccount;
    @docfeatures=();
    $sentencecount=0;
    # get the sentences
    #$sentences=get_sentences($text); #slow oh so slow...
    #foreach my $text (@$sentences) {
    @sentences=split(/[\!\?\.]\s+/g,$text); #fast
    foreach $text (@sentences) {
    if ($saveCleanFiles) {
    $sentencetext=$text;
     $sentencetext=~s/\n+/ /g;
if ($sentenceMatrixFlag) {
print CLEANSENTENCE "$sentencetext\n";
                     }
}

    if ($negationPropagationFlag) {
    $negcounter=99999;
          }
    undef %count;
    undef @features;
    undef $bigram;
    $text =~ s/<[^>]*>/ /gs; #remove tags
	$text =~ s/&.*?\s/ /gs;    #remove escapes
    $text=~s/[^a-zA-Z0-9'-]/ /ig; #keep only alphanumeric, dash and apostrophe
    $text=~s/\s+/ /ig;
    $text=lc($text);


    $prev="";
    if ($POSFlag) {
    	#my $tagged_text = $p->add_tags($text);
      #my %word_list = $p->get_words( $text );
		$readable = $tagged_text;
		$readable =~ s/<\p{IsLower}+>([^<]+)<\/(\p{IsLower}+)>/$1\/\U$2/go;
    @wordspos=split (/\s+/, $readable);
    @words=();
    @pos=();
    foreach $word (@wordspos) {
    ( $word, $pos ) = split( /\//, $word );
     push (@words, $word);
     push (@poss, $pos);
                   }

  }
  else
  {
  @words=split (/\s+/, $text);

  }
  if ($stemFlag) {
                    #$words=[\@words];
                    my $wordsForStem=[\@words];
                    $stemmed_words = Lingua::Stem::En::stem({ -words => $wordsForStem,
                                              -locale => 'en',
                                          -exceptions => \%exceptions,
                          });
                  }
    foreach ($in=0;$in<scalar(@words);$in++) {
    if ($POSFlag) {
    #( $word, $pos ) = split( /\//, $word );
    $pos=@poss[$in]
                   }
                   else {$pos="";}
    $word=@words[$in];
    if ($word=~/^[-']$/i) {next;}
    if ( ($stoplistFlag) && ( exists( $stopwords{ lc($word) } ) ) )
				{
					next;
				}

    $addWordFlag=1;

    if ($PBigramsFlag) {
                        if (!($prev eq "")) {
                              $bigram=$prev."_".$word;
                              #push (@features,$bigram); #Added later so that it can be removed by negation
                                  }
                                  $prev=$word;
                        }


    if ( $negationFeatureFlag) {
     if ( ( exists( $negation{$word} ) ) ) {

				push( @features, "D_NEGATION" );
			}
} #$negationFeatureFlag

if ($negationPropagationFlag) {
      if ( ( exists( $negation{$word} ) ) ) {

        $negcounter=0;
			}
      if (($negcounter<$maximumNegationWindow)&& ($negcounter>0)) {
         push (@features,"NEG_".$word);
         if ($PBigramsFlag) {
         push (@features,"NEG_".$bigram);
         }
         if  (($POSFlag==1)&&($concatenatePOSFlag==0)) {
      push (@features,"NEGPOS_".$pos);
    }
    if  (($POSFlag)&&($concatenatePOSFlag)) {
     push (@features,"NEGCONCATPOS_".$word."_".$pos);
    }
    if ($lexicalFlag){
    if ( ( exists( $lookup{$word} ) ) ) {
				@tmp6 = split( ",", $lookup{$word} );
        for ($i=0;$i<scalar(@tmp6);$i++){
         $tmp6[$i]="NEG_".$tmp6[$i];
        }
				push( @features, @tmp6 );
    }
} #$lexicalFlag
         if ($removeNegatedFlag) {
          $addWordFlag=0;
         }

                }
      $negcounter++;

      }
      if ($addWordFlag) {
      push (@features,$word);
        if (($PBigramsFlag)&&(!($prev eq ""))&& ($bigram)){
         push (@features,$bigram);
         }
         if  (($POSFlag==1)&&($concatenatePOSFlag==0)) {
      push (@features,"POS_".$pos);
    }
    if  (($POSFlag)&&($concatenatePOSFlag)) {
     push (@features,"CONCATPOS_".$word."_".$pos);
    }
    if ($lexicalFlag){
    if ( ( exists( $lookup{$word} ) ) ) {
				@tmp6 = split( ",", $lookup{$word} );
				push( @features, @tmp6 );
    }
} #$lexicalFlag
                         }


    } #words

    @features = grep { !($_ =~/^\s*$/g)} @features;
    foreach $f (@features) {
    $count{$f}++;
    }

    $sentencecount++;
    if ($sentenceMatrixFlag) {
    print MATSENTENCE "$file-$sentencecount $class ";

    print MATSENTENCE join(" ", map{"$_ $count{$_}"} keys(%count))."\n";
    }
    push (@docfeatures, @features);

    } #$sentences
    $text=$text;

    foreach $f (@docfeatures) {
    $doccount{$f}++;
    }
    print MATDOC "$file $class ";
    print MATDOC join(" ", map{"$_ $doccount{$_}"} keys(%doccount))."\n";

}

sub getHashFromDirFilenameOLD {
	my $dir = shift;
	my %ret = ();
	my $value;
	my $key;
	opendir( DIR, $dir );
	my @files = readdir(DIR);
	closedir(DIR);

	foreach my $file (@files) {
		next if $file =~ /^\.\.?$/;    # skip . and ..
		next if $file =~ /^\.svn$/;    # skip . and ..

#		print "$file\n";
		my $filename = "$dir\\$file";
		open( INPUTFILE2, "<$filename" ) or die "can't open $filename: $!";
		while ( defined( $line = <INPUTFILE2> ) ) {
			chomp $line;
			my @words = split( /\s+/, $line );
			if ( scalar(@words) > 0 ) {
				$key = @words[0];
			}
			else {
				die "Empty line in $filename.";
			}
			$value = $file;
			if ( $value =~ /(.*?)\..*?/i ) {
				$value = $1;
			}

			#   if ($key eq "this") {
			#    print "this";
			#   }
			if ( !( exists $ret{$key} ) ) {
				$ret{$key} = "D_" . $value;
			}
			else {
				unless ( $ret{$key} eq "D_" . $value ) {
					$ret{$key} = $ret{$key} . "," . "D_" . $value;
				}
			}
		}
	}
	return %ret;
}

sub getHashFromDirFilenameStemFlag {
	my $dir = shift;
  my $stemFlag=shift;
	my %ret = ();
	my $value;
	my $key;
  my @keys;
	opendir( DIR, $dir );
	my @files = readdir(DIR);
	closedir(DIR);

	foreach my $file (@files) {
		next if $file =~ /^\.\.?$/;    # skip . and ..
		next if $file =~ /^\.svn$/;    # skip . and ..

#		print "$file\n";
		my $filename = "$dir\\$file";
    undef @keys;
		open( INPUTFILE2, "<$filename" ) or die "can't open $filename: $!";
		while ( defined( $line = <INPUTFILE2> ) ) {
			chomp $line;
			my @words = split( /\s+/, $line );
			if ( scalar(@words) > 0 ) {
				$key = @words[0];
        push (@keys, $key);
			}
			else {
				die "Empty line in $filename.";
			}
   }
   $value = $file;
			if ( $value =~ /(.*?)\..*?/i ) {
				$value = $1;
			}
     if ($stemFlag) {
                    #$words=[\@words];
                    my $wordsForStem=[\@keys];
                    $stemmed_words = Lingua::Stem::En::stem({ -words => $wordsForStem,
                                              -locale => 'en',
                                          -exceptions => \%exceptions,
                          });
                  }
     foreach $key (@keys){


			#   if ($key eq "this") {
			#    print "this";
			#   }
			if ( !( exists $ret{$key} ) ) {
				$ret{$key} = "D_" . $value;
			}
			else {
				unless ( $ret{$key} eq "D_" . $value ) {
					$ret{$key} = $ret{$key} . "," . "D_" . $value;
				}
			}
		}
	}
	return %ret;
}

sub runRulesOnDocument {
my $text=shift;
$text=~s/\,/ [comma]/ig;
$text=~s/\s*\:\s*/ [colon] /ig;
$text=~s/\s*\;\s*/ [semicolon] /ig;
$text=~s/\s*\"\s*/ [quote] /ig;
$text=~s/\s+\d+.*?\s+/ [num] /ig;

return $text;
}

sub parseDoc {   # method names are specified by SAX
#  print $xmltext;
  $text="error";
  $id="error";
  $class="error";
  if ($xmltext=~/\>(.*?)\</m){
  $body=$1;
  }

  if ($xmltext=~/\<body\>(.*?)\<\/body\>/ism){
  $body=$1;
  }
  $text=$body;
  if ($xmltext=~/\<id\>(.*?)\<\/id\>/ism) {
  $id=$1;
  }
  $file=$id;
  my $regex="\\<category\\s+attribute=\\s*[\\'\\\"]\\s*".$categoryAttribute."s*[\\'\\\"]\\s*.*?\\>(.*?)\\<\\/category\\>";
  if ($xmltext=~/$regex/ism){
  $category=$1;
  }
  $class=$category;
  }
  
  sub start_element {   # method names are specified by SAX
  my ($self, $data) = @_;
  }

sub generateHelp {
 $help="";
$help=$help."This script takes a directory with documents or an xml file and generates a feature matrix."."\n";
$help=$help."Standard output returns the filename and the full path to the generated feature matrix."."\n";
$help=$help."SVM models and evaluation files are optionally generated in the models and matrices directories."."\n";
$help=$help."Parameters:"."\n";
$help=$help."-Dir		directory or xmlfile (The only mandatory parameter, all others have defaults.)"."\n";
$help=$help."-Pos 		part of speech (ConcatPOS, POS, NoPOS). ConcatPos"."\n";
$help=$help."-Dict 		use of dictionary (flag). Dict"."\n";
$help=$help."-DictionaryDirectory 	directory containing dictionary files. dictionaries"."\n";
$help=$help."-Neg 		negation handling (BothNEG PropagNEG NEG NoNEG). BothNEG"."\n";
$help=$help."-NegWindow 	negation propagation window (integer). 4"."\n";
$help=$help."-Bigrams	bigrams (flag). Bigrams"."\n";
$help=$help."-Stem 		stem (flag). NoStem"."\n";
$help=$help."-SentenceMatrix generate sentence matrix in addition to the document matrix (flag). NoSentenceMatrix"."\n";
$help=$help."-Stoplist	use of stoplist (flag). Stoplist"."\n";
$help=$help."-StoplistDirectory 	directory containing stoplist files. dictionaries\\stoplists"."\n";
$help=$help."-SaveCleanSentenceFiles	save sentences in a single file (flag). NoSaveCleanSentenceFiles"."\n";
$help=$help."-Mode 		train or test mode (train, test, traintest, score, xvalidation, none). train"."\n";
$help=$help."-DFFilter	use only features that occur in at least as many documents (integer). 0"."\n";
$help=$help."-CategoryAttribute 	category attribute that represents the category if input is XML. sentiment"."\n";
$help=$help."-Model		model for testing. test\\Electronics-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocModel.txt"."\n";
$help=$help."-Testmatrix	matrix for testing. test\\ElectronicsCameraAndPhotoB-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocMatrix.txt"."\n";
$help=$help."-numFolds	number of cross validation folds (integer). 10"."\n";
$help=$help."-randomSeed	random seed for cross validation (integer). 1000"."\n";

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



