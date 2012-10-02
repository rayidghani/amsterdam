#! /usr/local/bin/perl5 -w







# convert documents in smart format to required format

# for SVMlight



# standard Perl packages

use Getopt::Long ;



# --------------------------------------------------------------------

# parse the command line options

# ---------------------------------------------------------------------



# initialize command line arguments

$test = 0 ;

$num_token  = 1 ;

$blocksize=10;

$mixweight=0;

$term_weight="ltc";



# get options

GetOptions("output-loc:s"=>\$output_loc ,

                   "input-file:s"=>\$input_file ,

                   "term-weight:s"=>\$term_weight,

                   "class-list:s"=>\$class_file,

                   "dict:s"=>\$dictionary,

                   "test"=>\$test,

                   "negnum:i"=>\$negnum,

                   "mixweight:i"=>\$mixweight) ;

$negnum=-1; $negnum=-1;

$term_weight_array[0]=substr($term_weight,0,1);

$term_weight_array[1]=substr($term_weight,1,1);

$term_weight_array[2]=substr($term_weight,2,1);

print "$term_weight_array[0]  $term_weight_array[1]  $term_weight_array[2]\n";





$old_input_file=$input_file;



#create the output directory

if (! (-d $output_loc)) {

  mkdir ($output_loc, 0777) or  die "Cannot create directory $output_loc: $!\n" ;

}



if ($test == 0) {

  if ($term_weight_array[1] eq "c"){

    $cmd="lf_smart2svm_wordlist.pl -input_file $input_file -dict $dictionary -tw chi"; print "$cmd\n"; system $cmd;

  }else{

    $cmd="lf_smart2svm_wordlist.pl -input_file $input_file -dict $dictionary"; print "$cmd\n"; system $cmd;

  }

}









@dirs = split /\//, $input_file ;  $input_file = $dirs[$#dirs] ;

$output_trainfile = $output_loc."/".$input_file."_svm_".".train" ;

$output_testfile =  $output_loc."/".$input_file."_svm_".".test" ;

if ($test==0) {

  open (TRAIN, ">$output_trainfile") or die "Cannot open file $output_trainfile to write:$!\n" ;

} else{

  open (TEST, ">$output_testfile") or die "Cannot open file $output_testfile to write:$!\n" ;

}







%token_map = ();



open WORD, "<$dictionary" or die "cannot open file to read $dictionary:$!" ;



$line=<WORD>; chop($line);  @tmp=split(/\s+/,$line);

$docnum=$tmp[0]; $avglen=$tmp[1];

print "docnum=$docnum  avglen=$avglen\n";

while (<WORD>) {

  ($word, $word_id, $token_idfv) = split ;

  $token_map{$word} = $word_id ;   $token_idf{$word} = $token_idfv ;

  $num_token++;

}

close WORD ;





open (INPUT, $old_input_file) or

    die "Cannot open file $old_input_file to read: $!\n" ;





# initialize global variables

%classes = () ; # classes/categories for the whole corpus



# average document length in the corpus

@document_length = () ;

@document_frequency = () ;

%corpus_word_freq = () ;



$total_doc_id=1;

$doc_id=-1;

$old_total_doc_id=-1;



while (<INPUT>){



  if ((($total_doc_id % 1000)==0)&&($total_doc_id!= $old_total_doc_id)) {

    print "$total_doc_id\n"; $old_total_doc_id=$total_doc_id;

  }

  if ($doc_id>=$blocksize){

    $total_doc_id--;

    print_svm() ;

    $doc_id=-1;$c_flag = 0 ;



    #for ($i=0; $i<=$#doc_word_freq; $i++) {

       #foreach $the_key (keys %{$doc_word_freq[$i]}

      #delete $doc_word_freq[$i]{keys %{$doc_word_freq[$i]}};

    #}

    #undef (%doc_word_freq);

    @doc_word_freq = ();# word and its tf in each document

  }



    if (/^\.I/) {

                # begin of a new document

                $doc_id++ ;        $total_doc_id++ ;

        if ($doc_id>=$blocksize){ redo;}

                $document_length[$doc_id] = 0 ;

                $w_flag = 0 ;

    }elsif (/^\.C/) {

                chop ;

                $c_flag = 1 ;

                next ;

    }elsif (/^\.T/) {

                $t_flag = 1 ;

    }

    elsif (/^\.W/) {

                $t_flag = 0 ;

                $w_flag = 1 ;

    }

    elsif ($c_flag) { # parse the catogory section

        chop ; chop;





                # get the classes, insert them into the hash table %classes

                s/1;/ /g ;

                my (@cls) = split ;

                foreach $cl (@cls) {

                  $classes{$cl} ++ ;

                }

                $c_flag = 0 ;

    }

    elsif ($t_flag || $w_flag) {

        my (@tokens) = split ;

        if ($doc_id==-1) {print "warn\n";}

                foreach $token (@tokens) { &process_token ($token) ;}

    }

}



$total_doc_id=$total_doc_id+($blocksize-$doc_id-1);

$doc_id++;

print_svm() ;

#--------------------------------------------------------



close TRAIN ;

close TEST ;



# open class file to write down the class names

if ($test == 0) {    $class_file.="_train";}

open (CLASS_FILE, ">$class_file") or die "Cannot open file $class_file to write:$!\n" ;



foreach $cl (sort by_freq (keys %classes)) {

  # write down the class names

  print "$cl\n";

  print CLASS_FILE "$cl\n" ;

}# for each class



close CLASS_FILE ;









# ----------------------------------------------------------------------

# subroutine to add a token $token

# ----------------------------------------------------------------------

sub process_token {

    my ($token) = @_ ;

    my ($tf) = 0 ;



    $document_length[$doc_id]++ ;



     # add into the global mapping



    if (! exists $token_map{$token}) { return ; }# discard words not in training set





    # calculate the term frequency

    $doc_word_freq[$doc_id]{$token} ++ ;

    $tf = $doc_word_freq[$doc_id]{$token} ;

    # calculate the corpus term frequency

    $corpus_word_freq{$token} ++ ;



    # record document frequency for this word

    if ($tf == 1) { #first appeared in this document

                $document_frequency{$token} ++ ;

    }

}





# -----------------------------------------------------------------------

# subroutine to output the svm format files

# ----------------------------------------------------------------------

sub print_svm {



      for ($doc_i = 0 ; $doc_i<$doc_id ; $doc_i ++) {

        $norm=0;

        # is this document an empty document?

        # if ($document_length[$doc_i] == 0) {   next ;    }



        # does this document belong to training or test set?

        if ($test==0) {

                  $output_handle = \*TRAIN ;

        } else {

                  $output_handle = \*TEST ;

        }



        #$real_id=$doc_i+$total_doc_id -$blocksize;

                #print $output_handle "_$real_id " ;



        # output words in document $doc_i

        my @words = sort (keys %{$doc_word_freq[$doc_i]}) ;



        $maxtf=0; $this_doc_len=0;

        foreach $w (@words) {

          $this_doc_len+=$doc_word_freq[$doc_i]{$w};

          if ($maxtf<$doc_word_freq[$doc_i]{$w}) {$maxtf=$doc_word_freq[$doc_i]{$w};}

        }



        foreach $w (@words) {

                  # compute the term weighting of this word $w

                  my ($tf, $tw) ;

                  $tf = $doc_word_freq[$doc_i]{$w} ;



                  if ($term_weight_array[0] eq "b") {$tf1=1;}

          elsif ($term_weight_array[0] eq "l") {$tf1=1+(log($tf));}

          elsif ($term_weight_array[0] eq "n") {$tf1=$tf;}

          elsif ($term_weight_array[0] eq "a") {$tf1=0.5+0.5*($tf/$maxtf);}

          elsif ($term_weight_array[0] eq "s") {$tf1=$tf*$tf;}

          elsif ($term_weight_array[0] eq "m") {$tf1=$tf/$maxtf;}

          elsif ($term_weight_array[0] eq "o") {$tf1=($tf+0.5)/($tf+0.5+1.5*$avglen/$this_doc_len);}



                  if ($term_weight_array[1] eq "n") {$idf1=1;}

          elsif ($term_weight_array[1] eq "t") {$idf1=$token_idf{$w}; }

          elsif ($term_weight_array[1] eq "c") {$idf1=$token_idf{$w}; }

          elsif ($term_weight_array[1] eq "f") {$idf1=1/$docnum;}

          elsif ($term_weight_array[1] eq "s") {$idf1=$token_idf{$w}*$token_idf{$w};}

          elsif ($term_weight_array[1] eq "p") {$rate=exp($token_idf{$w}); $idf1=log($rate-1);}

          elsif ($term_weight_array[1] eq "o") {

            $pure_idf=$docnum/exp($token_idf{$w}); $idf1=log($docnum-$pure_idf+0.5)/($pure_idf+0.5);

          }





          $tw=$tf1*$idf1;



          if ($mixweight==1){

            if (length($w)==3) {$tw=$tw*0.538;}

            elsif (length($w)==2) {$tw=$tw*0.483;}

            else {$tw=$tw*0.01;} #notice !!!! if the weight is 0 here, the program may terminate unnormally becayse /0

          }

          $doc_word_score[$doc_i]{$w}=$tw;



                  $norm+=$tw*$tw;

                  # output this word

                }   # for each word



        $norm=sqrt($norm);

        if ($term_weight_array[2] eq "n") {$norm=1;}



        foreach $w (@words) {

          $tw=$doc_word_score[$doc_i]{$w}/$norm;

                  print $output_handle (" ", $token_map{$w}, ":", $tw) ;

        }

                print $output_handle "\n" ;

        #if (($doc_i % 500)==0) {print "$doc_i...";}

        #if (($doc_i % 3000)==0) {print "\n";}

      }  #for each doc



}











# --------------------------------------------------------------------

# subroutine to sort classes according to their frequency

# --------------------------------------------------------------------

sub by_freq {

    $classes{$b} <=> $classes{$a} ;

}
















