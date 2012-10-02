#-dir "E:\Amazon\svm scripts\TestInput4.xml.txt" -outputdir c:\tmp
#-dir "E:\Amazon\groceriestest" -mode score
# -UseAllDirectoriesFlag -nodebug  -mode score -bodyTag1 title -bodyTag2 body -categoryAttribute sentiment -randomSeed 1000 -numFolds 5 -ExcludeSize 50000 -Pos ConcatPOS -Neg BothNeg -Stoplist  -Dict  -NoStem  -NoBigrams  -dir "E:\amazon\svm scripts\TestInput.xml.txt"
#-dir "E:\Amazon\allbalanced\automotive" -mode train -classifier all -makexmlfile
#-dir "E:\Amazon\allbalanced\automotive" -mode train -classifier all -makexmlfile
# -UseAllDirectoriesFlag  -mode xvalidation -bodyTag1 title -bodyTag2 body -categoryAttribute sentiment -randomSeed 1000 -numFolds 5 -ExcludeSize 50000 -Pos ConcatPOS -Neg BothNeg -Stoplist  -Dict  -NoStem  -NoBigrams  -dir "E:\Amazon\svm scripts\testmatrices\groceriestestXMLOutput.xml" -Classifier svmperftfidf
use Config::Simple;
use File::Basename;
use File::Path;
use Lingua::Stem::En;
use Lingua::EN::Tagger;
use HTML::TokeParser;
use Config::Simple;
use Text::CSV_XS;
#use Object::Destroyer;
#use Memoize qw(memoize unmemoize);
#memoize('_assign_tag',TIE => ['Memoize::ExpireLRU', CACHESIZE => 10000,]);
#memoize('_assign_tag');

# -mode train -bodyTag1 title -bodyTag2 body -categoryAttribute sentiment -randomSeed 1000 -numFolds 5 -ExcludeSize 50000 -ConcatPos -BothNeg -Stoplist  -Dict  -NoStem  -NoBigrams  -dir "E:\amazon\svm scripts\test3.xml"
#-dir E:\Amazon\groceriestest -sentencematrix
#use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
#use Lingua::EN::Sentence qw( get_sentences add_acronyms );
use File::Basename;
use Getopt::Long;
use List::Util qw[min max];



# use XML::SAX::Expat;
#  use XML::SAX::MyFooHandler;

#  use MyHandler;

  #use XML::SAX::XYZHandler;
  
  
  
# -mode train -bodyTag1 title -bodyTag2 body -categoryAttribute sentiment -randomSeed 1000 -numFolds 5 -ExcludeSize 50000 -Pos ConcatPos -Neg BothNeg -Stoplist  -Dict  -NoStem  -NoBigrams  -dir "E:\amazon\svm scripts\test3.xml"
  
  
if (!defined($PPos)) {
$PPos="ConcatPOS";
}

if (!defined($PDict)) {
$PDict="Dict";
}

if (!defined($PNeg)) {
$PNeg="RemoveNEG";
}

if (!defined($PBigrams)) {
$PBigrams="BiGram";
}

if (!defined($PStem)) {
$PStem="NoStem";
}

if (!defined($PMode)) {
$PMode="none";
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
if (!(defined($phrasesdictionarydir))) {
	$phrasesdictionarydir = "phrasesdictionaries";
}

if (!(defined($stopdir))) {
 $stopdir = "$dictionarydir\/stoplists";
}

if (!(defined($model))) {
	$model = "testmodels\/automotive-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocModel.txt.svmperftfidf.model.txt";
}

if (!(defined($testmatrix))) {
 $testmatrix = "testmatrices\/groceriestestxmloutput.xml-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocMatrix.txt";
}

if (!(defined($activeModel))) {
	$activeModel = "testmodels\/Activeautomotive-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocModel.txt.svmperftfidf.model.txt";
}

if (!(defined($activeMatrix))) {
 $activeMatrix = "testmatrices\/ActiveAutomotive-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocMatrix.txt";
}

$documentCounter=0;

$reloadTaggerEvery=1000;



#E:\Amazon\testxml\TestInput.xml.txt
#E:\Amazon\testxml\TestInput.xml.txt
#E:\Amazon\GroceriesTest

$PBigramsFlag=1;
$PDictFlag=1;

$sentenceMatrixFlag=0;
$maximumNegationWindow=4;

$stoplistFlag = 1;
$saveCleanFiles=0;

$numFolds=5;
$randomSeed=1000;

$DBFlag=1;

$stdinFlag=0;
$csvFlag=0;
$separator="|";
$quote="";
$recordSeparator="\n";
$outputdir="";
$maxsizeForDocument=500000;
$printIdsFlag=0;
$printTimeFlag=0;

$stopNegOnPunctFlag=1;
$punctuationFeaturesFlag=1;
$positivenegativeFeatureFlag=1;
$timestampFlag=0;
$useAllDirectoriesFlag=0;
$debugFlag=1;
$bodyTag1="title";
$bodyTag2="body";
$substitutionsFlag=1;
$makeXMLFileFlag=1;
$classifier="svmperftfidf";

 $distanceFromNegationFeatureFlag=1;

#$classifier="liblogistic";
#$classifier="all";
$result = GetOptions (
"dir=s" => \$dir, # directory or xmlfile
"Pos=s" => \$PPos, # part of speech
"Dict!" => \$PDictFlag,
"Neg=s" => \$PNeg,
"DistanceFromNegationFeature!" => \$distanceFromNegationFeatureFlag,
"Bigrams!" => \$PBigramsFlag,
"Stem!" => \$PStemFlag,
"Classifier=s" => \$classifier,
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
"PhrasesDictionaryDirectory=s" => \$dictionarydir,
"NumFolds=i" => \$numFolds,
"ExcludeSize=i" => \$maxsizeForDocument,
"RandomSeed=i" => \$randomSeed,
"Stdin!" => \$stdinFlag,
"CSV!" => \$csvFlag,
"CSVSeparator=s" => \$separator,
"CSVQuote=s" => \$quote,
"CSVRecordSeparator=s" => \$recordSeparator,
"StopNegOnPunct!" => \$stopNegOnPunctFlag,
"PunctuationFeaturesFlag!" => \$punctuationFeaturesFlag,
"PositiveNegativeFeatureFlag!" => \$positivenegativeFeatureFlag,
"OutputDir=s" => \$outputdir,
"bodyTag1=s" => \$bodyTag1,
"bodyTag2=s" => \$bodyTag2,
"bodyTag2=s" => \$bodyTag2,

"OutputNounPhrases!" => \$phrasesFlag,
"Substitutions!" => \$substitutionsFlag,
"DBAccess!" => \$DBFlag,
"PrintIds!" => \$printIdsFlag,
"PrintTime!" => \$printTimeFlag,
"Debug!" => \$debugFlag,
"makeXMLFile!" => \$makeXMLFileFlag,
"ReloadTaggerEvery=i" => \$reloadTaggerEvery,
"Testmatrix=s" => \$testmatrix,
"ActiveMatrix=s" => \$activeMatrix,
"ActiveModel=s" => \$activeModel,
"Timestamp!" => \$timestampFlag,
"UseAllDirectoriesFlag!" => \$useAllDirectoriesFlag,

"resultfile=s" => \$resultfile);

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




#$matrixdir = $dir . "\/matrices\/";

# my $tag = Lingua::EN::Tagger->new(longest_noun_phrase => 5,
#                                      weight_noun_phrases => 0);

# start timer
$start        = time();
$relaxHMMFlag = 0
  ; #"Relax the Hidden Markov Model: this may improve accuracy for uncommon words, particularly words used polysemously"
undef $sentry;
undef $p;



$p = Lingua::EN::Tagger->new( stem => $stemFlag, relax => $relaxHMMFlag );


$paramSuffix="-";
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

if ($PMode eq "active") {
    $activeLearningFlag=1;    } else {
    $activeLearningFlag=0;
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

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
$mon=$mon+1;
if ($timestampFlag) {
$timestamp="-$mon-$mday-$hour-$min";
} else {
$timestamp="";
}
if ( $dir =~ /^(.+)\/(.+?)$/ig ) {

	#$outputdir=$1."\/";
	$outputdir2 = $1;
	$domain    = $2;

 $domain=$domain.$timestamp;
}

undef %categories;
undef %featureDocCount;
undef %featureMaxFrequency;



if ($stoplistFlag) {
	$stopdir = "$dictionarydir\/stoplists";
	%stopwords  = getHashFromDirFilenameStemFlag($stopdir, $stemFlag);
}
if ($lexicalFlag) {
	%lookup = getHashFromDirFilenameStemFlag("$dictionarydir\/dictionaries", $stemFlag);
}

	%negation = getHashFromDirFilenameStemFlag("$dictionarydir\/negation", $stemFlag);


print "$dir";
print "std $stdinFlag\n";
if ((-d $dir)&&(!($stdinFlag))) {
if ($outputdir eq "")
      {
       $outputdir=$dir;
      }
 $matrixdir = $outputdir . "\/matrices";
mkdir ($matrixdir,1);
if ($trainModelsFlag || $traintestModelsFlag) {
$modeldir = $outputdir . "\/models";
mkdir ($modeldir,1);

}
if ($makeXMLFileFlag) {
$xmloutput= "$outputdir\/$domain" . "XMLOutput.txt";
open( XMLOUTPUT,    ">$xmloutput" )    or die "can't open $xmloutput: $!";
binmode(XMLOUTPUT, ":utf8");
print XMLOUTPUT "<xml>\n<data>\n";
#<document><id>90495</id><title>99 GTP 2door</title><author>Royfact</author><date>2005-01-22</date><body><text>Review Te </text></body><category attribute="make">Pontiac</category><category attribute="model">Pontiac Grand Prix</category><category attribute="sentiment">positive</category></document>
}
    $fcleanDoc      = "$outputdir\/$domain" . "Doc" . "clean.txt";
#$fcleanPgraph   = "$dir\/$domain" . "Pgraph" . "clean.txt";
$fcleanSentence = "$outputdir\/$domain" . "Sentence" . "clean.txt";

if ($saveCleanFiles) {
 open( CLEANDOC,    ">$fcleanDoc" )    or die "can't open $fcleanDoc: $!";
 binmode(CLEANDOC, ":utf8");
#open( CLEANPGRAPH, ">$fcleanPgraph" ) or die "can't open $fcleanPgraph: $!";
if ($sentenceMatrixFlag) {
open( CLEANSENTENCE, ">$fcleanSentence" )
  or die "can't open $fcleanSentence: $!";
  binmode(CLEANSENTENCE, ":utf8");

}
}
$fmatrixDoc        = "$matrixdir\/$domain" .$paramSuffix. "Doc" . "Matrix.txt";
#$fmatrixPgraph     = "$outputdir\/$domain" .$paramSuffix . "Pgraph" . "Matrix.txt";
$fmatrixSentence   = "$matrixdir\/$domain" .$paramSuffix . "Sentence" . "Matrix.txt";

$fidlist   = "$matrixdir\/$domain" .$paramSuffix . "DocIdList.txt";
$fcategorylist   = "$matrixdir\/$domain" .$paramSuffix . "categoryList.txt";
open( ID,    ">$fidlist" )    or die "can't open $fidlist: $!";
binmode(ID, ":utf8");

open( CATEGORY,    ">$fcategorylist" )    or die "can't open $fcategorylist: $!";
binmode(CATEGORY, ":utf8");

#if ($trainModelsFlag) {
if (1) {
$fmodelDoc        = "$modeldir\/$domain" .$paramSuffix. "Doc" . "Model.txt";
$fmodelSentence   = "$modeldir\/$domain" .$paramSuffix . "Sentence" . "Model.txt";

}
#print $fmatrixDoc, "\n";
#print $fmatrixSentence, "\n";
#print $fmatrixDoc, "\n";
open( MATDOC,    ">$fmatrixDoc" )    or die "can't open $fmatrixDoc: $!";
binmode(MATDOC, ":utf8");

#open( MATPGRAPH, ">$fmatrixPgraph" ) or die "can't open $fmatrixPgraph: $!";
if ($sentenceMatrixFlag) {
open( MATSENTENCE, ">$fmatrixSentence" ) or die "can't open $fmatrixSentence: $!";
binmode(MATSENTENCE, ":utf8");

$fsentenceidlist   = "$matrixdir\/$domain" .$paramSuffix . "SentenceIdList.txt";

open( SENTENCEID,    ">$fsentenceidlist" )    or die "can't open $fsentenceidlist: $!";
binmode(SENTENCEID, ":utf8");


              }




@classes = ( "positive", "negative", "neutral", "unknown" );      #unnecessart if $missing=0;
#@classes = ( "0", "1" );
opendir( DIR, "$dir" );
@files2 = readdir(DIR);
closedir(DIR);
foreach $f (@files2) {
	next if $f =~ /^\.\.?$/;
	next if $f =~ /\.txt$/;
 if ($useAllDirectoriesFlag) {
 $missing = 0; #use all subdirectories
 } else
 {
 $missing = 1; #use  subdirectories in @classes
 }
#$missing = 0; #use all subdirectories

	foreach $c (@classes) {

		#print $f .":".$c."\n";
		if ( $f eq $c ) { $missing = 0; }
	}    #foreach $c
	if ($missing) { next; }
	$class = $f;
  $categories{$class}++;
	# print $class ."\n";
	$inputdir= $dir . "\/" . $class;
  	opendir( DIR, "$inputdir" );
		@files = readdir(DIR);
		closedir(DIR);
    foreach $f (@files) {
    next if $f =~ /^\.\.?$/;
    next if $f =~ /^\.svn$/;
    $file=$inputdir."\/".$f;
       $text="";
    	open( INPUTFILE, "<$file" ) or die "can't open $file: $!";
     $file=~s/\s+/\_\_\_/g; #replace spaces in file id with ___ to avoid problems later  when splitting
		while ( defined( $line = <INPUTFILE> ) ) {
    $text=$text.$line;
    }
    close INPUTFILE;
    if ($makeXMLFileFlag) {
print XMLOUTPUT "<document>\n<id>$file</id>\n<title></title>\n<body>\n<text>";
print XMLOUTPUT "$text<text>\n</body>\n";
print XMLOUTPUT "<category attribute=\"$categoryAttribute\">$class</category>\n</document>\n";


#<category attribute="make">Pontiac</category><category attribute="model">Pontiac Grand Prix</category><category attribute="sentiment">positive</category></document>
}
    if (length($text)>$maxsizeForDocument) {next;}
    processDoc();
    } #file
   } #classes
   } #kind of file
    elsif ((-e $dir)||($stdinFlag)) {
    if ($stdinFlag) {
     $dir="stdin\/StdinXML.txt";

    }
    my($filename, $directory) = fileparse($dir);

    chop $directory;
    $xmlfile=$dir;
    $dir=$directory;
    $domain=$filename;
    $domain=$domain.$timestamp;
    if ($outputdir eq "")
      {
       $outputdir=$dir;
      }
    mkdir ($outputdir,1);
    $fcleanDoc      = "$outputdir\/$domain" . "Doc" . "clean.txt";
#$fcleanPgraph   = "$dir\/$domain" . "Pgraph" . "clean.txt";
$fcleanSentence = "$outputdir\/$domain" . "Sentence" . "clean.txt";

if ($saveCleanFiles) {
 open( CLEANDOC,    ">$fcleanDoc" )    or die "can't open $fcleanDoc: $!";
 binmode(CLEANDOC, ":utf8");
#open( CLEANPGRAPH, ">$fcleanPgraph" ) or die "can't open $fcleanPgraph: $!";
if ($sentenceMatrixFlag) {
open( CLEANSENTENCE, ">$fcleanSentence" )
  or die "can't open $fcleanSentence: $!";
  binmode(CLEANSENTENCE, ":utf8");
}
}

 $matrixdir = $outputdir . "\/matrices";
mkdir ($matrixdir,1);
if ($trainModelsFlag) {
$modeldir = $outputdir . "\/models";
mkdir ($modeldir,1);

}
$fmatrixDoc        = "$matrixdir\/$domain" .$paramSuffix. "Doc" . "Matrix.txt";
#$fmatrixPgraph     = "$outputdir\/$domain" .$paramSuffix . "Pgraph" . "Matrix.txt";
$fmatrixSentence   = "$matrixdir\/$domain" .$paramSuffix . "Sentence" . "Matrix.txt";

#if ($trainModelsFlag) {
if (1) {
$fmodelDoc        = "$modeldir\/$domain" .$paramSuffix. $classifier. "Doc" . "Model.txt";
$fmodelSentence   = "$modeldir\/$domain" .$paramSuffix. $classifier. "Sentence" . "Model.txt";
$fidlist   = "$matrixdir\/$domain" .$paramSuffix . "DocIdList.txt";
$fcategorylist   = "$matrixdir\/$domain" .$paramSuffix . "categoryList.txt";
open( ID,    ">$fidlist" )    or die "can't open $fidlist: $!";
binmode(ID, ":utf8");

open( CATEGORY,    ">$fcategorylist" )    or die "can't open $fcategorylist: $!";
binmode(CATEGORY, ":utf8");

}
#print $fmatrixDoc, "\n";
#print $fmatrixSentence, "\n";
#print $fmatrixDoc, "\n";
open( MATDOC,    ">$fmatrixDoc" )    or die "can't open $fmatrixDoc: $!";
binmode(MATDOC, ":utf8");

#open( MATPGRAPH, ">$fmatrixPgraph" ) or die "can't open $fmatrixPgraph: $!";
if ($sentenceMatrixFlag) {
open( MATSENTENCE, ">$fmatrixSentence" ) or die "can't open $fmatrixSentence: $!";
binmode(MATSENTENCE, ":utf8");
$fsentenceidlist   = "$matrixdir\/$domain" .$paramSuffix . "SentenceIdList.txt";

open( SENTENCEID,    ">$fsentenceidlist" )    or die "can't open $fsentenceidlist: $!";
binmode(SENTENCEID, ":utf8");

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
  if ($stdinFlag) {
    open( XML, "<-" ) or die "can't open stdin: $!";
    } else {
open( XML, "<$xmlfile" ) or die "can't open $xmlfile: $!";
}

  if ($csvFlag) {
 my $csv = Text::CSV_XS->new ({ binary => 1,allow_whitespace    => 1,sep_char => "\t" }) or
     die "Cannot use CSV: ".Text::CSV->error_diag ();
# open my $fh, "<:encoding(utf8)", $xmlfile or die $xmlfile;
 while (my $row = $csv->getline (XML)) {

 $id=$row->[0];
 $category=$row->[2];
 $class=$category;
 $text=$row->[1];
 #print "$text\n";
 if (length($text)>$maxsizeForDocument) {next;}

 processDoc();
  $categories{$class}++;

     #$row->[2] =~ m/pattern/ or next; # 3rd field should match
     #push @rows, $row;
     } #while
 $csv->eof or $csv->error_diag ();
} else {

 $inDocumentFlag=0;
 $xmltext="";
  while ($line=<XML>) {
  if ($line=~/\<document\>(.*?)\<\/document\>/ig) {
  $xmltext=$1;
  $inDocumentFlag=0;
  parseDoc();
  if (length($text)>$maxsizeForDocument) {next;}

  processDoc();
  $categories{$class}++;
  $xmltext="";


  } elsif ($line=~/\<document\>(.*?)$/ig) {
  $xmltext=$1;
  $inDocumentFlag=1;
  }elsif ($line=~/^(.*?)\<\/document\>/ig) {
  $xmltext=$xmltext.$1;
  $inDocumentFlag=0;
  parseDoc();
  if (length($text)>$maxsizeForDocument) {next;}
  processDoc();
  $categories{$class}++;
  $xmltext="";
   }elsif ($inDocumentFlag) {
    $xmltext=$xmltext.$line;
   }


 
 
}



   } #xmlfile

   }
   else {
   generateHelp();
   print $help;
   exit;
   }
   
    if ($makeXMLFileFlag) {
print XMLOUTPUT "</data>\n</xml>";
close XMLOUTPUT;
}

#save wordlist
#foreach $key (sort (keys(%featureDocCount)))
#{
#       $idftmp=$featureDocCount{$key};
#       if ($idftmp>=$minIDF) {
#       print FEATURES $key, "\t", $idftmp, "\t", $featureMaxFrequency{$key}, "\n";
#       }
#}
#save categorylist
foreach $key (keys(%categories))
{
       print CATEGORY $key, "\n";

}

  $cfg = new Config::Simple(syntax=>'ini');

  $cfg->autosave(1);
  $cfg->param("matrixDoc",$fmatrixDoc);
  if ($sentenceMatrixFlag) {
  $cfg->param("matrixSentence",$fmatrixSentence);
  }
   $cfg->write("$fmatrixDoc.cfg");


if ($activeLearningFlag) {

$activecommand="perl activelearning.pl -NewFeatures \"$fmatrixDoc\" -OldFeatures \"$activeMatrix\" -model \"$activeModel\" -classifier $classifier -dffilter $dffilter";
if ($debugFlag) {print $activecommand."\n";}
$activeresult=runCommand($activecommand);
#print $modelresult."\n";
#$model=$fmodelDoc;

if ($sentenceMatrixFlag) {
$activecommand="perl activelearning.pl -NewFeatures \"$fmatrixSentence\" -OldFeatures \"$activeMatrix\" -model \"$activeModel\" -classifier $classifier -dffilter $dffilter";
#print $modelcommand."\n";
$activeresult=runCommand($activecommand);
#print $modelresult."\n";
}
}
  
if ($trainModelsFlag) {

$modelcommand="perl trainmodel.pl -Features \"$fmatrixDoc\" -model \"$fmodelDoc\" -classifier $classifier -dffilter $dffilter";
if ($debugFlag) {print $modelcommand."\n";}
$modelresult=runCommand($modelcommand);
#print $modelresult."\n";
$model=$fmodelDoc;

if ($sentenceMatrixFlag) {
$modelcommand="perl trainmodel.pl -Features \"$fmatrixSentence\" -model \"$fmodelSentence\" -classifier $classifier -dffilter $dffilter";
#print $modelcommand."\n";
$modelresult=runCommand($modelcommand);
#print $modelresult."\n";
}
}

if ($testModelsFlag) {
$testcommand="perl testmodel.pl  -Features \"$fmatrixDoc\"  -model \"$model\"  -classifier $classifier ";
if ($debugFlag) {print $testcommand."\n";}

$testresult=runCommand($testcommand);

if ($sentenceMatrixFlag) {
$testcommand="perl testmodel.pl  -Features \"$fmatrixSentence\"  -model \"$model\"  -classifier $classifier ";
$testresult=runCommand($testcommand);
}
}



if ($traintestModelsFlag) {
$testcommand="perl traintest.pl  -TrainFeatures \"$fmatrixDoc\" -TestFeatures \"$testmatrix\"  -model \"$fmodelDoc\"  -classifier $classifier ";
if ($debugFlag) {print $testcommand."\n";}

$testresult=runCommand($testcommand);

if ($sentenceMatrixFlag) {
$testcommand="perl traintest.pl  -TrainFeatures \"$fmatrixSentence\" -TestFeatures \"$testmatrix\"  -model \"$fmodelSentence\"  -classifier $classifier ";
$testresult=runCommand($testcommand);
}
}

if ($scoreModelsFlag) {
$testcommand="perl runmodel.pl  -Features \"$fmatrixDoc\" -model \"$model\" -classifier $classifier -resultfile $resultfile";
if ($debugFlag) {print $testcommand."\n";}

$testresult=runCommand($testcommand);

if ($sentenceMatrixFlag) {
$testcommand="perl runmodel.pl  -Features \"$fmatrixSentence\" -model \"$model\" -classifier $classifier ";
$testresult=runCommand($testcommand);
}
}

if ($xvalidationModelsFlag) {
$testcommand="perl xvalidationOnMatrix.pl  -Features \"$fmatrixDoc\" -numFolds $numFolds -randomSeed $randomSeed -classifier $classifier ";
if ($debugFlag) {print $testcommand."\n";}
$testresult=runCommand($testcommand);

if ($sentenceMatrixFlag) {
$testcommand="perl xvalidationOnMatrix.pl  -Features \"$fmatrixSentence\" -numFolds $numFolds -randomSeed $randomSeed -classifier $classifier ";
$testresult=runCommand($testcommand);
}
}


   # end timer
$end = time();

# report
if ($printTimeFlag) {
# Convert seconds to days, hours, minutes, seconds
$seconds = $end - $start;
@parts = gmtime($seconds);

print "\nTime taken was ", ( $seconds ), " seconds.\n";
printf ("That's %4d days, %4d hours, %4d minutes, and %4d seconds.\n",@parts[7,2,1,0]);
}
print $fmatrixDoc;
exit;

sub processDoc {

if (($documentCounter % $reloadTaggerEvery)==0) {
   #print $documentCounter."\n";

$p = Lingua::EN::Tagger->new( stem => $stemFlag, relax => $relaxHMMFlag );
    if ($printIdsFlag) {
      print "$documentCounter. $file: $class.\n";
}
}
$documentCounter++;

#test
#$text=" And \"Mr. Brown weighed 2 oz.\" with a scale: It was great. ".$text;
#$text=~s/([\.\!\?])\"/$1 \"/g;

my @cleanedWords=_clean_text_MK($p,$text);
my @tags = add_tags_MK($p,@cleanedWords);
#$cleanWordsText=join (' ', @cleanedWords);

#end test

 undef %doccount;
 undef @docfeatures;
 $hasdocpositive=0;
 $hasdocnegative=0;
    $sentencecount=0;
    # get the sentences
    #$sentences=get_sentences($text); #slow oh so slow...
    #foreach my $text (@$sentences) {
 #   @sentences=split(/[\!\?\.]\s+/g,$text); #fast, but bad.
#     @sentences=split(/ \!| \?|( \.)/g,$cleanWordsText); #reasonable
undef @sentences;
$sentence="";
foreach  $word (@cleanedWords) {
if (($word eq ".")||($word eq "!")||($word eq "?")) {
#$word =~ s/^\s+//;
$sentence=$sentence.$word;
if (length ($sentence) >2) {
push (@sentences, $sentence);
}
$sentence="";
}  else {
$sentence=$sentence." ".$word;
         }
}
if (!($sentence eq "")) {
push (@sentences, $sentence);
}

    foreach $text (@sentences) {


    if ($negationPropagationFlag) {
    $negcounter=99999;
          }
    undef %count;
    undef @features;
    undef $bigram;
#    $text =~ s/<[^>]*>/ /gs; #remove tags
#	$text =~ s/&.*?\s/ /gs;    #remove escapes
#    $text=~s/[^a-zA-Z0-9'-]/ /ig; #keep only alphanumeric, dash and apostrophe
#    $text=~s/\s+/ /ig;
#    $text=lc($text);

    if ($saveCleanFiles) {
    $sentencetext=$text;
    #if ($sentencetext=~/pros/ig) {
    #print $sentencetext ."\n";
    #}
     $sentencetext=~s/\r*\n+\r*/ /msg;
if ($sentenceMatrixFlag) {
print CLEANSENTENCE "$sentencetext\n";
                     }
}
if ($substitutionsFlag) {
$text=makeSubstitutions($text);
}
    $prev="";
my @words=_clean_text_MK($p,$text);


    if ($POSFlag) {
    undef $tagged_text;
    undef $readable;
    undef @wordspos;
 #   undef @words;
    undef @poss;
   @poss = add_tags_MK($p,@words);

     #	my $tagged_text = $p->add_tags($text);
 #     my $tagged_text = add_tags($p,$text);
      #my %word_list = $p->get_words( $text );
	#	$readable = $tagged_text;
 # $tagged_text = $p->add_tags(""); #pathetic attempt to stop the memory leak
	#	$readable =~ s/<\p{IsLower}+>([^<]+)<\/(\p{IsLower}+)>/$1\/\U$2/go;
  #  @wordspos=split (/\s+/, $readable);
  #  foreach $word (@wordspos) {
  #  ( $word, $pos ) = split( /\//, $word );
  #   push (@words, $word);
  #   push (@poss, $pos);
   #                }

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
    if (!($punctuationFeaturesFlag)) {
    if ($word=~/^[,:;'"\(\)\.\?\!\`]+$/i) {next;}
    } # $punctuationFeaturesFlag
    $capsfeature="";
    if ($word=~/^[A-Z][^a-z]+$/g) { $capsfeature="R_ALLCAPS_".$word;}
    if ($word=~/^[A-Z]/g) { $capsfeature="R_CAPS_".$word;}

    $word=lc($word);
    if ($word=~/^\d+/g) { $word = "R_NUM";}


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

              if ($distanceFromNegationFeatureFlag) {
                push (@features,"NEGDIST".$negcounter."_".$word);
              }


         if ($PBigramsFlag) {
         push (@features,"NEGB_".$bigram);
              if ($distanceFromNegationFeatureFlag) {
              push  (@features,"NEGBDIST".$negcounter."_".$bigram);
              }


         
         }
         if  (($POSFlag==1)&&($concatenatePOSFlag==0)) {
      push (@features,"NEGPOS_".$pos);
            if ($distanceFromNegationFeatureFlag) {
            push   (@features,"NEGPOSDIST".$negcounter."_".$pos);
              }

    }
    if  (($POSFlag)&&($concatenatePOSFlag)) {
     push (@features,"NEGCONCATPOS_".$word."_".$pos);
           if ($distanceFromNegationFeatureFlag) {
           push     (@features,"NEGCONCATPOS".$negcounter."_".$word."_".$pos);
              }


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
          if ($stopNegOnPunctFlag) {
          if (($word eq "(")||($word eq ")")||($word eq ",")||($word eq "''")||($word eq ":")||($word eq ";")||($word eq "``")||($word eq "\"")) {
       $negcounter=999999;
       }
       }#$stopNegOnPunctFlag
      }
      if ($addWordFlag) {
      push (@features,$word);
      if (!($capsfeature eq "")) { push (@features,$capsfeature);}
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
    $haspositive=0;
    $hasnegative=0;

    foreach $f (@features) {
    $count{$f}++;
    if ($f eq "D_POSITIVE") {
                  $haspositive++;
                  $hasdocpositive++;
                        }
    if ($f eq "D_NEGATIVE") {
                  $hasnegative++;
                  $hasdocnegative++;
    }
    } #@features

    $sentencecount++;
    if ($positivenegativeFeatureFlag) {
      my $pn=min($haspositive,$hasnegative);
      my $pdiff=$haspositive-$hasnegative;
      if ($pn) {
        $count{"PN_SENTENCE"}=$pn;
        $doccount{"PN_SENTENCE"}=$doccount{"PN_SENTENCE"}+$pn;
        if ($pdiff>0) {
            $count{"PN_SENTENCEPOSDIFF"}=$pdiff;
            $doccount{"PN_SENTENCEPOSDIFF"}= $doccount{"PN_SENTENCEPOSDIFF"}+$pdiff;
        } elsif ($pdiff<0) {
        $count{"PN_SENTENCENEGDIFF"}=-$pdiff;
        $doccount{"PN_SENTENCENEGDIFF"}= $doccount{"PN_SENTENCENEGDIFF"}-$pdiff;

        } else {
        $count{"PN_SENTENCEEQUAL"}=1;
        $doccount{"PN_SENTENCEEQUAL"}++;

        }
      }
    }  #$positivenegativeFeatureFlag
    if ($sentenceMatrixFlag) {
    print SENTENCEID "$file-$sentencecount\n";

    print MATSENTENCE "$file-$sentencecount $class ";

    print MATSENTENCE join(" ", map{"$_ $count{$_}"} keys(%count))."\n";
    }
    push (@docfeatures, @features);

    } #$sentences
    $text=$text;

    foreach $f (@docfeatures) {
    $doccount{$f}++;
    }
    if ($positivenegativeFeatureFlag) {
      my $pn=min($hasdocpositive,$hasdocnegative);
      my $pdiff=$hasdocpositive-$hasdocnegative;
      if ($pn) {
        $doccount{"PN_DOC"}=$pn;
        if ($pdiff>0) {
            $doccount{"PN_DOCPOSDIFF"}=$pdiff;

        } elsif ($pdiff<0) {
        $doccount{"PN_DOCNEGDIFF"}=-$pdiff;

        } else {
        $doccount{"PN_DOCEQUAL"}=1;

        }
      }
    }  #$positivenegativeFeatureFlag

    print ID "$file\n";
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
		my $filename = "$dir\/$file";
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
		my $filename = "$dir\/$file";
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
  $title="";
  if ($xmltext=~/\<$bodyTag1.*?\>(.*?)\<\/$bodyTag1\>/ism){
  $title=$1;
  }
  if ($xmltext=~/\<$bodyTag2.*?\>(.*?)\<\/$bodyTag2\>/ism){
  $body=$1;
  }
  if (!($title eq"")) {
  $text=$title.".\n".$body;
  }
  else
  {
  $text=$body;
  }

  if ($xmltext=~/\<id\>(.*?)\<\/id\>/ism) {
  $id=$1;
  }
  $file=$id;
  my $regex="\/<category\/s+attribute=\/s*[\/'\/\"]\/s*".$categoryAttribute."s*[\/'\/\"]\/s*.*?\/>(.*?)\/<\//category\/>";
  if ($xmltext=~/$regex/ism){
  $category=$1;
  } else {
  $category="NoClassSpecified";

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
$help=$help."-Dir		directory or xmlfile (Either this must be set or stdin must be on)"."\n";
$help=$help."-Pos 		part of speech (ConcatPOS, POS, NoPOS). ConcatPos"."\n";
$help=$help."-Dict 		use of dictionary (flag). Dict"."\n";
$help=$help."-DictionaryDirectory 	directory containing dictionary files. dictionaries"."\n";
$help=$help."-Neg 		negation handling (BothNEG PropagNEG NEG NoNEG). BothNEG"."\n";
$help=$help."-NegWindow 	negation propagation window (integer). 4"."\n";
$help=$help."-Bigrams	bigrams (flag). Bigrams"."\n";
$help=$help."-Stem 		stem (flag). NoStem"."\n";
$help=$help."-SentenceMatrix generate sentence matrix in addition to the document matrix (flag). NoSentenceMatrix"."\n";
$help=$help."-Stoplist	use of stoplist (flag). Stoplist"."\n";
$help=$help."-Stdin	use of <stdin> for XML (flag). NoStdin"."\n";
$help=$help."-StoplistDirectory 	directory containing stoplist files. dictionaries\\stoplists"."\n";
$help=$help."-SaveCleanSentenceFiles	save sentences in a single file (flag). NoSaveCleanSentenceFiles"."\n";
$help=$help."-Mode 		train or test mode (train, test, score, xvalidation, none). train"."\n";
$help=$help."-DFFilter	use only features that occur in at least as many documents (integer). 0"."\n";
$help=$help."-CategoryAttribute 	category attribute that represents the category if input is XML. sentiment"."\n";
$help=$help."-Model		model for testing. test\\Electronics-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocModel.txt"."\n";
$help=$help."-Testmatrix	matrix for testing. test\\ElectronicsCameraAndPhotoB-.ConcatPOS.Dict.BothNEG.BiGram.NoStem-DocMatrix.txt"."\n";

$help=$help."-OutputDir	output directory (string). current directory."."\n";
$help=$help."-ExcludeSize	documents larger than this will be excluded (integer). 500000"."\n";
$help=$help."-PrintIds	print document Ids while processing (flag). NoPrintIds"."\n";
$help=$help."-PrintTime	print time taken (flag). NoPrintTime"."\n";

$help=$help."-ReloadTaggerEvery	Reload the tagger every n documents to prevent memory leaks. 50 is more efficient. (integer). 1"."\n";

$help=$help."-numFolds	number of cross validation folds (integer). 5"."\n";
$help=$help."-randomSeed	random seed for cross validation (integer). 1000"."\n";

}
sub runCommand {
my $command=shift;
my $exe;
my $subst;
my $pl;
my $ret;

  $ret=`$command`;
  return $ret;
}
sub extractPhrases {
my $text=shift;
my @ret;
return @ret;
}
sub add_tags {

        my ( $self, $text ) = @_;

        return unless $self->_valid_text( $text );

        my @text = _clean_text_MK( $p, $text );
        my $t = $self->{'current_tag'}; # shortcut
        my ( @tags ) =
                map {
                        $t = _assign_tag( $p, $t, $self->_clean_word( $_ ))
                                || $self->{'unknown_word_tag'} || 'nn';
                       "<$t>$_</$t>"
                } @text;
        $self->{'current_tag'} = $t;
        $self->_reset;
        return join ' ', @tags;
}
sub add_tags_MK {

        my ( $self, @text ) = @_;

        #return unless $self->_valid_text( $text );

        #my @text = _clean_text( $p, $text );
        my $t = $self->{'current_tag'}; # shortcut
        my ( @tags ) =
                map {
                        $t = _assign_tag( $p, $t, $self->_clean_word( $_ ))
                                || $self->{'unknown_word_tag'} || 'nn';
                       "$t"
                } @text;
        $self->{'current_tag'} = $t;
        $self->_reset;
        return @tags;
}

sub _assign_tag {

        my ( $self, $prev_tag, $word) = @_;


        if ( $self->{'unknown_word_tag'} and $word eq "-unknown-" ){
                # If the 'unknown_word_tag' value is defined,
                # classify unknown words accordingly
                return $self->{'unknown_word_tag'};
        } elsif ( $word eq "-sym-" ){
                # If this is a symbol, tag it as a symbol
                return "sym";
        }

        my $best_so_far = 0;
        my $w = $Lingua::EN::Tagger::_LEXICON{$word};
        my $t = \%Lingua::EN::Tagger::_HMM;

        ##############################################################
        # TAG THE TEXT
        # What follows is a modified version of the Viterbi algorithm
        # which is used in most POS taggers
        ##############################################################
        my $best_tag;

        foreach my $tag ( keys %{ $t->{$prev_tag} } ){

                # With the $self->{'relax'} var set, this method
                # will also include any `open classes' of POS tags
                my $pw;
                if( defined ${ $w->{$tag} } ){
                        $pw = ${ $w->{$tag} };
                } elsif ( $self->{'relax'} and  $tag =~ /^(?:jj|nn|rb|vb)/  ){
                        $pw = 0;
                } else {
                        next;
                }

                # Bayesian logic:
                # P =  P( $tag | $prev_tag ) * P( $tag | $word )
                my $probability =
                        $t->{$prev_tag}{$tag} * ( $pw + 1 );

                # Set the tag with maximal probability
                if( $probability > $best_so_far ) {
                        $best_so_far = $probability;
                        $best_tag = $tag;
                }
        }

        return $best_tag;
}
sub _clean_text_MK {
        my ( $self, $text ) = @_;
        return if (( !defined $text )||($text eq ""));
        $text=~s/\#/ /ig;
        $text=~s/\^/ /ig;
        # Strip out any markup and convert entities to their proper form
        my $html_parser;
        utf8::decode( $text );
        $html_parser = HTML::TokeParser->new( \$text );

        my $cleaned_text = $html_parser->get_text;
        while( $html_parser->get_token ){
                $cleaned_text .= ( $html_parser->get_text )." ";
        }


        # Tokenize the text (splitting on punctuation as you go)
        my @tokenized = map { $self->_split_punct( $_ ) }
                                split /\s+/, $cleaned_text;
        my @words = _split_sentences_MK($p, \@tokenized );
        return @words;


}

sub _split_sentences_MK {
        my ( $self, $array_ref ) = @_;
        my @tokenized = @{ $array_ref };

        my @PEOPLE = qw/jr mr ms mrs dr prof esq sr sen sens rep reps gov attys attys supt det mssrs rev/;
        my @ARMY = qw/col gen lt cmdr adm capt sgt cpl maj brig/;
        my @INST = qw/dept univ assn bros ph.d/;
        my @PLACE = qw/arc al ave blvd bld cl ct cres exp expy dist mt mtn ft fy fwy hwy hway la pde pd plz pl rd st tce/;
        my @COMP = qw/mfg inc ltd co corp/;
    my @STATE = qw/ala ariz ark cal calif colo col conn del fed fla ga ida id ill ind ia kans kan ken ky la me md is mass mich minn miss mo mont neb nebr nev mex okla ok ore penna penn pa dak tenn tex ut vt va wash wis wisc wy wyo usafa alta man ont que sask yuk/;
        my @MONTH = qw/jan feb mar apr may jun jul aug sep sept oct nov dec/;
        my @MISC = qw/vs etc no esp i.e/;
       my @UOM = qw/ ml lbf kips kPa psi MPa ksi bbl F ft gal gr in k kt lb LT L T mi mph n m oz pt qt rpm T tbsp tsp yd b B C cm3 cc GB g K KB kg kl km l m MB µg mg mm W kW hz wt/;
        my %ABBR = map { $_, 0 }
                ( @PEOPLE, @ARMY, @INST, @PLACE, @COMP, @STATE, @MONTH, @MISC, @UOM);

        my @words;
        for( 0 .. $#tokenized ){

                if ( defined $tokenized[$_ + 1]
                        # and $tokenized[$_ + 1] =~ /^[A-Z\W]/
                        and $tokenized[$_ + 1] =~ /[\p{IsUpper}\W]/
                        and $tokenized[$_] =~ /^(.+)\.$/ ){

                        # Don't separate the period off words that
                        # meet any of the following conditions:
                        #  1. It is defined in one of the lists above
                        #  2. It is only one letter long: Alfred E. Sloan
                        #  3. It has a repeating letter-dot: U.S.A. or J.C. Penney
                        unless( defined $ABBR{ lc $1 }
                                or $1 =~ /^\p{IsLower}$/i
                                or $1 =~ /^\p{IsLower}(?:\.\p{IsLower})+$/i ){
                                push @words, ( $1, '.' );
                                next;
                        }
                }
                push @words, $tokenized[$_];
        }

        # If the final word ends in a period...
        if( defined $words[$#words] and $words[$#words] =~ /^(.*\p{IsWord})\.$/ ){
                $words[$#words] = $1;
                push @words, '.';
        }


        return @words;

}
sub makeSubstitutions {
 my $text=shift;
 $text=~s/ \d+-\d+ / numberRange /mg;
 $text=~s/[\t ]+/ /mg;
     $text=~s/ (?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6011[0-9]{12}|622((12[6-9]|1[3-9][0-9])|([2-8][0-9][0-9])|(9(([0-1][0-9])|(2[0-5]))))[0-9]{10}|64[4-9][0-9]{13}|65[0-9]{14}|3(?:0[0-5]|[68][0-9])[0-9]{11}|3[47][0-9]{13}) / SubstCREDITCARD /mg;
    $text=~s/[0-3]?[0-9]\/[0-3]?[0-9]\/(?:[0-9]{2})?[0-9]{2}/SubstDate/mg;
   # $text=~s/ ((19|20)?[0-9]{2}[- /.](0?[1-9]|1[012])[- /.](0?[1-9]|[12][0-9]|3[01])) /SubstDate/mg;
    $text=~s/ [A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4} / SubstEmail /img;
    $text=~s/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4} /SubstEmail /img;
    $text=~s/ [A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/ SubstEmail/img;

   $text=~s/ ((([0-9]{1})*[- .(]*([0-9]{3})[- .)]*[0-9]{3}[- .]*[0-9]{4})+) / SubstPhoneNA /mg;
   $text=~s/ ([0-9]{3}[-]*[0-9]{2}[-]*[0-9]{4}) / SubstSSN /mg;
   $text=~s/ (((http|https|ftp):\/\/)?([[a-zA-Z0-9]\-\.])+(\.)([[a-zA-Z0-9]]){2,4}([[a-zA-Z0-9]\/+=%&_\.~?\-]*)) / SubstURL /mg;

  $text=~s/ -?[\$|£|€|¥]\d+\.?\d* / SubstCurrency /mg;
   $text=~s/ \d+[.:] / SubstOrdinal /mg;
   $text=~s/ #d+ / SubstNumOrdinal /mg;
   $text=~s/ -?\d+ / SubstInteger /mg;
   $text=~s/ -?\d+\.?\d* / SubstRealNum /mg;

   $text=~s/ [\$]+ / SubstMoney /mg;
   $text=~s/ [\$]+$/ SubstMoney/mg;
   $text=~s/ [\$|£|€|¥] / SubstMoney /mg;

       $text=~s/^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6011[0-9]{12}|622((12[6-9]|1[3-9][0-9])|([2-8][0-9][0-9])|(9(([0-1][0-9])|(2[0-5]))))[0-9]{10}|64[4-9][0-9]{13}|65[0-9]{14}|3(?:0[0-5]|[68][0-9])[0-9]{11}|3[47][0-9]{13})$/SubstCREDITCARD/mg;
       $text=~s/^(0[1-9]|1[012])[- \/.](0[1-9]|[12][0-9]|3[01])[- \/.](19|20)\d\d$/SubstDate/mg;
       $text=~s/^((19|20)?[0-9]{2}[- \/.](0?[1-9]|1[012])[- \/.](0?[1-9]|[12][0-9]|3[01]))$/SubstDate/mg;
       $text=~s/^((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))$/SubstIpaddress/mg;
      $text=~s/^((([0-9]{1})*[- .(]*([0-9]{3})[- .)]*[0-9]{3}[- .]*[0-9]{4})+)$/SubstPhoneNA/mg;
      $text=~s/^([0-9]{3}[-]*[0-9]{2}[-]*[0-9]{4})$/SubstSSN/mg;
      $text=~s/^(((http|https|ftp):\/\/)?([[a-zA-Z0-9]\-\.])+(\.)([[a-zA-Z0-9]]){2,4}([[a-zA-Z0-9]\/+=%&_\.~?\-]*))$/SubstURL/mg;

     $text=~s/^-?[\$|£|€|¥]\d+\.?\d*$/SubstCurrency/mg;
      $text=~s/^\d+[.:]$/SubstOrdinal/mg;
      $text=~s/^#d+$/SubstNumOrdinal/mg;
      $text=~s/^-?\d+$/SubstInteger/mg;
      $text=~s/^-?\d+\.?\d*$/SubstRealNum/mg;

      $text=~s/^[\$]+$/SubstMoney/mg;
   $text=~s/^[\$|£|€|¥]$/SubstMoney/mg;

       $text=~s/^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6011[0-9]{12}|622((12[6-9]|1[3-9][0-9])|([2-8][0-9][0-9])|(9(([0-1][0-9])|(2[0-5]))))[0-9]{10}|64[4-9][0-9]{13}|65[0-9]{14}|3(?:0[0-5]|[68][0-9])[0-9]{11}|3[47][0-9]{13}) /SubstCREDITCARD /mg;
       $text=~s/^(0[1-9]|1[012])[- \/.](0[1-9]|[12][0-9]|3[01])[- \/.](19|20)\d\d /SubstDate /mg;
       $text=~s/^((19|20)?[0-9]{2}[- \/.](0?[1-9]|1[012])[- \/.](0?[1-9]|[12][0-9]|3[01])) /SubstDate /mg;
       $text=~s/^((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)) /SubstIpaddress /mg;
      $text=~s/^((([0-9]{1})*[- .(]*([0-9]{3})[- .)]*[0-9]{3}[- .]*[0-9]{4})+) /SubstPhoneNA /mg;
      $text=~s/^([0-9]{3}[-]*[0-9]{2}[-]*[0-9]{4}) /SubstSSN /mg;
      $text=~s/^(((http|https|ftp):\/\/)?([[a-zA-Z0-9]\-\.])+(\.)([[a-zA-Z0-9]]){2,4}([[a-zA-Z0-9]\/+=%&_\.~?\-]*)) /SubstURL /mg;

     $text=~s/^-?[\$|£|€|¥]\d+\.?\d* /SubstCurrency /mg;
      $text=~s/^\d+[.:] /SubstOrdinal /mg;
      $text=~s/^#d+ /SubstNumOrdinal /mg;
      $text=~s/^-?\d+ /SubstInteger /mg;
      $text=~s/^-?\d+\.?\d* /SubstRealNum /mg;

      $text=~s/^[\$]+ /SubstMoney /mg;
   $text=~s/^[\$|£|€|¥] /SubstMoney /mg;
       $text=~s/(%-\()|(\|8C)|(xP)|(\^o\))|(XP)|(XO)|(X-\()|(X\()|(X\()|(D\:)|(\)-\:)|(\)\:)|(\)o\:)|(Bc)|(B\()|(>o>)|(>\\)|(38\*)|(>\[)|(>\:O)|(8-0)|(8\/)|(8\\)|(8c)|(\:#)|(\:'\()|(\:'-\()|(\:\()|(>\:L)|(\:\*\()|(\:,\()|(\:-&)|(\:-\()|(\:-\(o\))|(>\:\()|(>\/)|(=\[)|(\:-\/)|(=\()|(<o<)|(<\/3-1)|(\:…\()|(\:-S)|(\:-\\)|(\:\|)|(\:-\|)|(\:s)|(\:\/)|(\:o\()|(\:_\()|(\:\\)|(\:\[)|(\:E)|(\:F)|(\:O)|(\:\[)|(\:S)|(\|8c)/SubstNegativeEmoticon /mg;
       $text=~s/(\:-})|(\:p)|(\:Þ)|(\:-P)|(\:o\))|(;\^\))|(\:b\))|(\:3)|(\:\])|(\:9)|(\:-D)|(\:D)|(=\))|(\:-\*)|(=\])|(\:-\*)|(\:-\))|(>\:\))|(>\:D)|(\:\))|(\:P)|(>=D)|(8\))|(0\:\))|(--\^--@)|(@}->--)|(\*\\o\/\*)|(\:X)|(<3)|(\(o\:)|(\(\^_\^\))|(\(\^.\^\))|(XD)|(XD)|(\(\^-\^\))|(\(\^ \^\))|(XP)|(\^_\^)|(\(\:)|(xD)|(\(-\:)|(%-\))|(\:P)|(\|D)|(}\:\))/SubstPositiveEmoticon /mg;
       $text=~s/\.\.\.+/SubstElipsis/mg;
 return $text;
}



