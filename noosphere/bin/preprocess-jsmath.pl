#!/usr/bin/perl


#use LaTeX::TOM;
use Data::Dumper;
use HTML::Entities;
use Cwd;
use File::Basename;

$timeout = 60; # seconds until render call is considered locked
$timeoutprog = "/var/www/noosphere/bin/timeout -t 30";

#writing my own math mode latex parser
#
foreach my $f (@ARGV) {
	runme($f);
}
exit();

sub runme {
	my $filename = shift;
#my $parser = new LaTeX::TOM->new(0,0,1);
my $latexsource = `texexpand $filename`;
$latexsource =~ s/[^\\]\\\[/\$\$/g;
$latexsource =~ s/[^\\]\\\]/\$\$/g;
#my $document = $parser->parse($latexsource);
#print Dumper ($parser->{USED_COMMANDS});
#print "parsing done";
#$latexsource = $document->toLaTeX;
#
# don't uncomment this
#print STDERR "After parsing:\n$latexsource\n";

#build the jsMath macros for user defined commands

#This is the form of newcommand:
#\newcommand{\ad}{\mathrm{ad}}
#
#\newcommand{\Aff}[2]{	\mathrm{Aff}_{#1} #2}
#\def\Bset{\mathbb{B}}
#% \frac overwrites LaTeX's one (use TeX \over instead)
#%def\fraq#1#2{{}^{#1}\!/\!{}_{\,#2}}
#\def\frac#1#2{\mathord{\mathchoice%
#{\T{#1\over#2}}
#{\T{#1\over#2}}
#{\S{#1\over#2}}
#{\SS{#1\over#2}}}}
#%def\half{\frac12}


# we need to genereate the jsMath javacript code
#this is a list of unsupported environments and commands that we force l2h to handle
# once jsmath supports the environment it should be removed from this list
my @unsupported = ("\\begin{pspicture}", "\\xymatrix", "\\mathbbm", "\\mathbbmss", "\\begin{align", "\\ensuremath", "\\begin{picture}" , "\\lhd",  "\\\$", "\\mathscr", "\\begin{array", "\\dotsc", "\\qedhere" , "\\Box", "\\hspace", "\\boldmath", "\\dotsb", "\\mathsf" , "\\begin{cases", "\\begin{xy", "\\hdots", "\\label");

my $commands = "";
#while ( $latexsource =~ /\\newcommand{(.*)}(\[\d+\])?{(.*)}/g ) {
#	my $command = $1;
#	my $num = $2;
#	my $content = $3;
#	$num =~ s/\[//g;
#	$num =~ s/\]//g;
#	$content =~ s/\\/\\\\/g;
#	print STDERR "defining '$command' '$num' '$content'\n";
#	$command =~ s/^\\//;
#	$num = 0 if ( $num eq '' );
#	$commands .= "<SCRIPT> jsMath.Macro( '$command', '$content', $num) </SCRIPT>\n";
#}

# if a definied command actually uses an unsupported environment call we must also put
# it in the unsupported list - nifty huh?

my @chars = split( /(\W)/, $latexsource );
for ( my $i = 0; $i < @chars; $i++ ) {
	if ( $chars[$i] eq "" ) {
		splice ( @chars, $i, 1 );
	}
}
for ( my $i = 0; $i < @chars; $i++ ) {
#	print "$chars[$i]\n";
	if ( $chars[$i] eq "\\" ) {
		$i++;
		if ( ($chars[$i] eq "def") || ($chars[$i] =~ /command/) ) {
			if ( $chars[$i] eq "newcommand" || $chars[$i] eq "providecommand" ) {
				$i++;
				my $command = "";
				($command, $i) = readToNextMatch( '{' , '}', \@chars, $i);
			#	print "detected new or provide command: $command\n";
				$i++;
				my $numargs = 0;
				if ( $chars[$i] eq '[' ) {
					($numargs,$i) = readToNextMatch( '[' , ']', \@chars, $i);
					$i++;
				} 
				my $content = "";
				($content, $i)  = readToNextMatch( '{' , '}', \@chars, $i);
			#	print "Building (\n$command\n$numargs\n$content\n)\n";
				$command =~ s/\\//;
				foreach my $u ( @unsupported ) {
#					print "checking if $content contains $u\n";
					my $b = $u;
					$b =~ s/\\/\\\\/;
					if ( $content =~ /$b/ ) {
#						print "adding \\$command to unsupported becaues of $b\n";
						push @unsupported, "\\$command";
						last;
					}
				}
				$content =~ s/\\/\\\\/g;
				$commands .= "<SCRIPT> jsMath.Macro( '$command', '$content', $numargs) </SCRIPT>\n";
			} elsif ( $chars[$i] eq "def" ) {
				$i++;
				print "i = $i and chars[i] = $chars[$i]\n";
				my $command = "";
				($command, $i) = readToNextMatch( "\\" , '{', \@chars, $i);
			#	print "detected def $command\n";
				my $numargs = 0;
				if ( $command =~ /(\w+)#.*(\d+)/ ) {
					$command = $1;
					$numargs = $2;
				}
				my $content = "";
				($content, $i) = readToNextMatch ( '{', '}', \@chars, $i);
			#	print "Building (\n$command\n$numargs\n$content\n)\n";
				$command =~ s/\\//;
				foreach my $u ( @unsupported ) {
					my $b = $u;
					$b =~ s/\\/\\\\/;
					if ( $content =~ /$b/ ) {
						push @unsupported, "\\$command";
						last;
					}
				}
				$content =~ s/\\/\\\\/g;
				$commands .= "<SCRIPT> jsMath.Macro( '$command', '$content', $numargs) </SCRIPT>\n";
			}	
		} elsif ( $chars[$i] eq "DeclareMathOperator" ) {
				$i++;
				my $command = "";
				($command, $i) = readToNextMatch( '{', '}', \@chars, $i);
				$command =~ s/\\//;
				$i++;
				my $content = "";
				($content, $i) = readToNextMatch( '{', '}', \@chars, $i);
				$commands .= "<SCRIPT> jsMath.Macro( '$command', '\\\\mathop{\\\\rm $content}', 0) </SCRIPT>\n";

		}
	}
}

sub readToNextMatch {
	my $mbegin = shift; #first char to match e.g. ( 
	my $mend = shift;  #matching char to first e.g. )
	my $charptr = shift;
	my $index = shift; 
				#(chars can actually be strings) to be parsed in the chars array.
	my $j = 0; #  $j is the number of $m remaining that need to be matched
	my $textRead = "";

	for ( my $i = $index; $i < @$charptr; $i++ ) {
		if ( $charptr->[$i] eq "$mbegin" ) {
			$j++; #this is the stack (we only need to count).
			next if ( $j == 1 );
		} elsif ( $charptr->[$i] eq "$mend") {
			$j--;
			if ( $j == 0 ) {
				#done we found the matching }
				#return all of the text read up until now
				#and return the number of characters read.
				#	or we could return the rest of the characters.
				return ( $textRead, $i );
			}
		} 
		if ( $j > 0 ) { 
			$textRead .= $charptr->[$i];
		}
	}
}


my @matharray = ();
my $mathcnt = 0;



my @results = ();
my @tokens = split( /(\W)/ , $latexsource );
for (my $i = 0; $i < $#tokens+1; $i++ ) { 
	if ( $tokens[$i] eq '' ) {
		splice( @tokens, $i, 1);
	}
}

# these commands switch out of math mode.
#(\\textrm|\\textsl|\\textit|\\texttt|\\textbf|\\text|\\hbox)

my $j = 0;
my $mathcontent = "";

#we should rework this parsing. It relies a little too much on string matching
#which can cause errors based on the content of the articles.
for (my $i = 0; $i < $#tokens+1; $i++) {
	if ( $tokens[$i] eq '$' && $tokens[$i-1] ne "\\" ) {
		$mathcontent = "";
		if ( $tokens[$i+1] eq '$' ) {
#	print "found begin of newline \$\$\n";
		#this is seperate line math mode;
			for( $j=$i+2; $j < $#tokens+1; $j++ ) {
				if ( $tokens[$j] eq '$' && $tokens[$j+1] eq '$' ) {
#					print "found end of \$\$\n";
					last;
				}
				$mathcontent .= $tokens[$j];
			}
			$i = $j+1;
			$mathcontent = "\$\$$mathcontent\$\$";
		} else {
		#this is inline math mode;
#			print "found begin of inline \$\n";
			my $waitForBrace = 0;
			for( $j=$i+1; $j < $#tokens+1; $j++ ) {
				if ( $tokens[$j] eq "\\" && $tokens[$j+1] =~ /(textrm|textsl|textit|texttt|textbf|text|hbox)/ ) {
						my $numlbrace = 0;
						my $k = $j+2;
						for ( $k = $j+2; $k < $#tokens+1; $k++ ) {
							$mathcontent .= $tokens[$k];
							if ( $tokens[$k] eq '{' ) {
								$numlbrace++;	
							} elsif ( $tokens[$k] eq '}' ) {
								$numlbrace--;	
								if ( $numlbrace == 0 ) {
									last;
								}
							}
						}
						$j = $k+1;
				}

				if ( $tokens[$j] eq '$') {
#print "found end of \$\n";
					last;
				}
				$mathcontent .= $tokens[$j];
			}
			$i = $j;
			$mathcontent = "\$$mathcontent\$";
		}
#		print "Storing math: [$mathcontent]\n";
		$matharray[$mathcnt] = $mathcontent;
		push @results, "JG-" . $mathcnt++ . "-JG ";
	} elsif ($tokens[$i] eq "\\" && $tokens[$i+1] !~ /htmladdn/)  {
		my $text = join( '', @tokens[$i..($i+4)] );
		my $j = 0;
		if ( $text =~ /begin{eqnarray/ || $text=~ /begin{equation/ || $text =~ /begin{align/ || $text =~ /begin{pspicture/ || $text =~ /begin{picture/ || $text =~ /begin{array/ ) {
#			print "begin equation type environment\n";
#			print "[$text]\n";
			$mathcontent = $text;
			for ( $j = $i+5; $j < $#tokens+1; $j++ ) {
				$text = join( '', @tokens[$j..($j+4)] );
				if ( $text =~ /end{eqnarray.*}/ ||  $text =~ /end{equation.*}/ || $text =~ /end{align.*}/ || $text =~ /end{pspicture}/ || $text =~ /end{array.*}/ ) {
#			print "end equation type environment\n";
						$mathcontent .= $text;
						last;
				} else {
					$mathcontent .= $tokens[$j];
				}
			}
			$matharray[$mathcnt] = $mathcontent;
			push @results, "JG-" . $mathcnt++ . "-JG";
			$i = $j+5;
		} else {
			push @results, $tokens[$i];
		}
#handle environments
	} else {
		push @results, $tokens[$i];
	}
}



#foreach my $r ( @results ) {
#	print "[$r]\n";
#}
#print STDERR Dumper( \@matharray );
my $preprocessedTex = join( '', @results );

#we now loop through and replace the environments that are currently not supported by jsmath.
#Note we still leave align and equation stuff even though it causes jsmath to crash because jsmath
# is supposed to support it

#print "unsupported used commands in this article are @unsupported\n";

for ( my $i = 0; $i < $#matharray+1; $i++ ) {
	my $math = $matharray[$i];
	foreach my $u ( @unsupported ) {
		my $b = $u;
		$b =~ s/\\/\\\\/;
		if ( $math =~ /$b/ ) {
			$preprocessedTex =~ s/JG-$i-JG/$math/;
			last;
		}
	}
}


$filename =~ s/\.tex/-pre.tex/;
open ( OUT, ">$filename" );
#open ( OUT, ">./temp/$filename" );
print OUT $preprocessedTex;
close (OUT);
#chdir(  "./temp/" );

#`latex \"$filename\"`;
#`bibtex \"$short\"`;
#`latex \"$filename\"`;
#`latex \"$filename\"`;
# we need to change to the correct directory.
my $dir = dirname( $filename );
my $currentdir = `pwd`;
chdir "$dir";

print "checkpoint 1\n";

#we need to implement this if statment and only run latex if 
# we need to.
#my $reruns = "ref|eqref|cite";
#if ($latex =~ /\\($reruns)\W/) {
`latex "$filename" 1>&2 2>/dev/null`;
#}

print "checkpoint 2\n";

#`ulimit -t $timeout ; latex2html "$filename" 1>&2 2>/dev/null`;
`$timeoutprog latex2html "$filename" 1>&2 2>/dev/null`;
chdir "$currentdir";


print "checkpoint 3\n";

open( IN, "index.html" );
my $html = ""; 
while ( <IN> ) {
	$html .= $_;
}
close( IN );

print "checkpoint 4\n";

for (my $i=0; $i < $#matharray+1; $i++ ){
	my $math = $matharray[$i];
	encode_entities($math, q{<>&"'});
	$html =~ s/JG-$i-JG/<SPAN class=\"nolink\">$math<\/SPAN>/g;
}
#my $script = "<SCRIPT SRC=\"http://images.planetmath.org:8089/jsMath/easy/load.js\"></SCRIPT>";

$html =~ s/<body.*?>/<body>$commands/i;


print "checkpoint 5\n";


open( OUT , ">index.html" );
print OUT $html;
close( OUT );
#chdir ( "..");
}
