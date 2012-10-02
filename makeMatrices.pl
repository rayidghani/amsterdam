use File::Path;
use Lingua::Stem::En;
use Lingua::EN::Tagger;
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use File::Path;
use Lingua::Stem::En;
use Lingua::EN::Sentence qw( get_sentences add_acronyms );
# add support for 'Lt. Gen.'
add_acronyms('lt','gen');


# todo: read from database or csv files of type "docid, classname, text"
# look at other taggers

$dir = shift; # input directory
$PPos     = shift;  #part of speech
$PDict    = shift;
$PNeg     = shift;
$PBigrams = shift;
$PStem = shift;

$outputmatrixtype=shift;  #train for normal, generic for web service

#GetOptions ('dir:s' => \$dir, 'pos:s' => \$PPos, 'dict' => \$PDict , 'neg' => \$PNeg, 'bigram' => \$PBigrams, 'punct' => \$PPunct, 'type' => \$outputmatrixtype);

if (!($PPos)) {
$PPos="NoPOS";
}

if (!($PDict)) {
$PDict="Dict";
}

if (!($PNeg)) {
$PNeg="BothNEG";
}

if (!($PBigrams)) {
$PBigrams="BiGram";
}

if (!($PStem)) {
$PStem="NoStem";
}


if ( length($dictionarydir) == 0 ) {
	$dictionarydir = "dictionaries";
}

if ( length($outputcopy) == 0 ) {
	$outputcopy = $dir . ".matrix.txt";
}

$matrixdir = $dir . "\\matrices\\";

# my $tag = Lingua::EN::Tagger->new(longest_noun_phrase => 5,
#                                      weight_noun_phrases => 0);

# start timer
$start        = time();
$relaxHMMFlag = 0
  ; #"Relax the Hidden Markov Model: this may improve accuracy for uncommon words, particularly words used polysemously"
$stoplistFlag = 1;

$paragraphflag           = 0;
$sentenceflag            = 1;
$phraseflag              = 0;

$globalFeaturesFlag      = 0;
$sortedFlag              = 0;
$POSFlag                 = 1;
$concatenatePOSFlag      = 1;
$lexicalFlag             = 1;
$syntacticFlag           = 0;
$negationPropagationFlag = 1;
$negationFeatureFlag = 1;
$doubleFirstLineFlag=0;
$addPeriodToFirstLineFlag=0;
$stemFlag     = 0;
$sentenceMatrixFlag=0;


$maximumNegationWindow=4;

if ( !( defined($PBigrams) ) ) {
	$PBigramsFlag = 1;
}


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
if ($outputmatrixtype eq "generic") {
    $paramSuffix="";
    $saveCleanFiles=1;
    $sentenceMatrixFlag=1;
} else {
    $saveCleanFiles=0;
}

if ($outputmatrixtype eq "train") {
    $trainModelsFlag=1} else {
    $trainModelsFlag=0;
}


if ( $dir =~ /^(.+)\\(.+?)$/ig ) {

	#$outputdir=$1."\\";
	$outputdir = $1;
	$domain    = $2;
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


my $p = Lingua::EN::Tagger->new( stem => $stemFlag, relax => $relaxHMMFlag );

if ($stoplistFlag) {
	$stopdirtmp = "$dictionarydir\\stoplists";
	%stopwords  = getHashFromDirFilenameStemFlag($stopdirtmp, $stemFlag);
}
if ($lexicalFlag) {
	%lookup = getHashFromDirFilenameStemFlag("$dictionarydir\\dictionaries", $stemFlag);
}

	%negation = getHashFromDirFilenameStemFlag("$dictionarydir\\negation", $stemFlag);


#$output=$outputdir."\\".$domain.".SimpleMatrix.txt";
#$output=$dir."\\".$domain.".SimpleMatrix.txt";
#open( OUT,    ">$output" )    or die "can't open $output: $!";

#todo : read from directory
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
    	my $tagged_text = $p->add_tags($text);
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
    } #file
   } #classes

if ($trainModelsFlag) {

$modelcommand="start /b /realtime perl E:\\Amazon\\m\\trainmodel.pl \"$fmatrixDoc\" \"$fmodelDoc\"";
#print $modelcommand."\n";
$modelresult=`$modelcommand`;
#print $modelresult."\n";

if ($sentenceMatrixFlag) {
$modelcommand="start /b /realtime perl E:\\Amazon\\m\\trainmodel.pl \"$fmatrixSentence\" \"$fmodelSentence\"";
#print $modelcommand."\n";
$modelresult=`$modelcommand`;
#print $modelresult."\n";
}
}
   
   # end timer
$end = time();

# report
#print "\nTime taken was ", ( $end - $start ), " seconds";
print $fmatrixDoc;
exit;

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

		print "$file\n";
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

		print "$file\n";
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






