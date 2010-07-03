package Noosphere;

use strict;

# checkdoc - spellcheck an entire "document" (basically any bunch of words)
#						returns the "document" with mispelled words highlighted
#
sub checkdoc {
	my $text = striphtml(shift);

	my $cmd = getConfig('spellcmd');
	
	my $prehighlight = "<a class=\"spell\" href=\"".getConfig("main_url")."/?op=checkword&word=\$word\" target=\"ZxbcMZXC\" onclick=\"window.open('".getConfig("main_url")."/?op=checkword&word=\$word', 'ZxbcMZX', 'width=300,height=120'); return false\">";
	my $posthighlight = "</a>";

	# TODO: write a "shellescape" function and use it here? - apk
	#
	#$text =~ s/\(/\\(/gs;
	#$text =~ s/\)/\\)/gs;
	$text =~ s/'/''/gs;
	my $out = `echo '$text' | $cmd`;
	my @lines = split('\n',$out);

	my %words;

	foreach my $line (@lines) {
		if ($line =~ /^#/) {
			$line =~ /^#\s(.*?)\s/;
			$words{$1} = 1;
		} elsif ($line =~ /^&/) {
			$line =~ /^&\s(.*?)\s/;
			$words{$1} = 1;
		}
	}

	my @warray = keys %words;
	if ($#warray < 0) { return "No spelling errors (congrats!)"; }

	foreach my $word (@warray) {
		my $pre = $prehighlight;
		$pre =~ s/\$word/$word/g;
		$text =~ s/([^\w]|^)$word([^\w]|$)/$1$pre$word$posthighlight$2/gs;
	}

	# un-shellescape text
	#
	$text =~ s/''/'/gs;	 

	return $text;
}

# checkword - spellcheck a single word
#
sub checkword {	
	my $params = shift;

	my $word = $params->{'word'};
	my $cmd = getConfig('spellcmd');
	my $template = new Template('checkword.html');
	my $result = "";

	my $out = `echo "$word" | $cmd`;
	my ($header,$line) = split('\n',$out);

	if ($line =~ /^\*/ || $line =~ /^\+/) {
		$result = "correct spelling.";
	} else {
		if ($line =~ /^&/) {
			$line =~ /:\s(.*)$/;
			$result = "misspelled. suggestions: $1";
		} elsif ($line =~ /^#/) {
			$result = "misspelled. no suggestions.";
		}
	}

	$template->setKeys('word' => $word, 'result' => $result);
 
	return $template->expand();
}

1;
