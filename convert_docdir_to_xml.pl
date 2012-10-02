$dir=shift;
$outfile=shift;
open(OUT, ">$outfile");
opendir( DIR, "$dir" );
@files = readdir(DIR);
closedir(DIR);
print $dir;
foreach $f (@files) {
	next if $f =~ /^\.\.?$/;
	$fname=$dir.$f;
	open(IN, $fname);
	$filetext=<IN>;
	
print OUT "<document>\n<id>$f</id>\n<title></title>\n<body>\n<text>";
print OUT "$filetext<text>\n</body>\n";
print OUT "<category attribute=\"unknown\">unknown</category>\n</document>\n";

}
close OUT;
