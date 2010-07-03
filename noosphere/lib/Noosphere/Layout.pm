package Noosphere;
use strict;

use vars qw(%templates %cached_env_img);

sub getViewStyleWidget {
	my $params = shift;
	my $method = shift;

	my $prefsinf = getConfig('prefs_schema');
	my $methodinfo = $prefsinf->{'method'};

	my $viewstylesel = getSelectBox('method', $methodinfo->[3], $method, 'onchange="methodform.submit()" class="small"');
	my $formvars = hashToFormVars(hashExcept($params,'method'));

	my $xhtml = "<form method=\"get\" action=\"/\" name=\"methodform\">
		View style: $viewstylesel 
                <input type=\"hidden\" value=\"$params->{id}\" name=\"id\"/>
                <input type=\"hidden\" value=\"getobj\" name=\"op\"/>
                <input type=\"hidden\" value=\"$params->{from}\" name=\"from\"/>
		<input type=\"submit\" value=\"reload\" class=\"small\"/></form>";
		#$formvars

	return $xhtml;
}

# error message for attempting to access a feature when an account is 
# needed
#
sub needAccount {

	return errorMessage("You must be logged in to do this! <br><br>If you don't have an account, its easy to <a href=\"".getConfig("main_url")."/?op=newuser\">make one</a>.");
}

# show an internal server error
#
sub showISE {
	
	# just load up the HTML template
	my $template = new Template('ise.html');

	return paddingTable(
				clearBox(
				'Noosphere error!', 
				$template->expand()
			)
		);
}

# insufficient access message
#
sub noAccess {
	
	return errorMessage("Insufficient access.");
}

# standard formatting for an error message.
#
sub errorMessage {
	my $message = shift; 
	my $template = new Template('error.html');
	
	$template->setKey('error', $message);

	return paddingTable(makeBox('Error',$template->expand()));
}

# draws a sub message in error box.
# 
sub stubMessage {
	return errorMessage('code me!');
	#return errorMessage('&lt;stub&gt;');
}


# generate an internal server error (for testing the system's response to them)
#
sub makeISE {
	die "breaking the server";
}

# return the maintenance page
#
sub getMaintenance {
	
	my $template = new Template('maintenance.html');

	return $template->expand();
}

# get html for the up arrow control (i.e. for going to parent)
#
sub getUpArrow {
	my $url = shift;
	my $alt = shift || '';
	my $title = shift || '';

	return "<a ".($title ? "title=\"$title\"" : '')." href=\"$url\"><img src=\"".getConfig('image_url')."/uparrow.png\" ".($alt ? "alt=\"[$alt]\"" : '')." border=\"0\"></a> ";
}

# get a meta redirect string for a URL
#
sub getMetaRedirect {
	my $url = shift;
	my $manual = shift;	 

	return " If this does not work, click <a href=\"$url\">here</a>.\n<meta http-equiv=\"refresh\" content=\"0; url=$url\">" if ($manual);

	return "<meta http-equiv=\"refresh\" content=\"0; url=$url\">";
}

# return a message box with a redirect to a url. this is meant for post-post,
# or post-edit status screens.
#
sub messageWithRedirect {
	my $title = shift;
	my $url = shift;
	my $content = shift;
	my $manual = shift;		# flag to put up a manual click message

	return paddingTable(makeBox($title,$content.getMetaRedirect($url,$manual)));
}

sub getTemplate {
	my $file=shift;
	my $tpath=getConfig("template_path");
	$templates{$file}||=readFile("$tpath/$file"); 
	my $addrhash=getConfig("siteaddrs");
	foreach my $key (keys %$addrhash) {
		$templates{$file}=~s/\$${key}siteaddr/$addrhash->{$key}/g;
	}
	return($templates{"$file"}); 
}

sub makeBox {
	my $title = shift;
	my $content = shift;
	
	my $box = new Template("box.html");
	$box->setKeys("title" => $title, "content" => $content);
	
	return $box->expand();
}

sub adminBox {
	my ($title, $content) = @_;
	my $box = new Template("adminbox.html");
	
	$box->setKeys("title" => $title, "content" => $content);
	return $box->expand();
}

sub mathBox {
	my $title = shift;
	my $content = shift;
 

	my $box = new Template("mathbox.html");

	$box->setKeys('title' => $title, 'content' => $content);

	
	return $box->expand();
}

sub clearBox {
	my $title = shift;
	my $content = shift;

	my $box = new Template("clearbox.html");
	$box->setKeys('title' => $title, 'content' => $content, 'templatehack' => '<'.getConfig('template_cmd_prefix').':template');
	
	return $box->expand();
}

sub paddingTable {
	my $content = shift;

	my $pad = new Template("padding.html");
	$pad->setKeys('content' => $content, 'templatehack' => '<'.getConfig('template_cmd_prefix').':template');
	
	return $pad->expand();
}

sub getBullet {
	my $type = shift;

	return "";

	if (!defined($type)) {
		$type = "bullet";
	}

	return "<img src=\"".getConfig('image_url')."/$type.png\" alt=\"*\">";
 
}

# getPager - get the widget for allowing the user to navigate through
#						a list in "pages"
#
sub getPager {
	my $params = shift;	 # get current param hash
	#	 offset	 (current item offset)
	#	 total		(number of items, not pages)
	my $userinf = shift;
	my $scale = shift;

	my $slicesize = $userinf->{'prefs'}->{'pagelength'} || '020';

	$scale = 1 unless $scale;
	$slicesize =~ s/^0*//go;
	$slicesize = int($slicesize / $scale);

	my $html = '';
	my $offset = $params->{'offset'} || 0;
	my $pages = int (($params->{'total'} + $slicesize - 1)/$slicesize);
	my $page = int ($offset/$slicesize) + 1;
	
	# we need a total
	#
	return '' if (not defined $params->{'total'} or $params->{'total'} == 0);
	my $total = $params->{'total'};

	return "<br><center>displaying all $total items.</center>" if ($pages == 1);
	
	# build param string
	# 
	my @parray = ();
	foreach my $key (keys %$params) {
		if ($key eq 'offset') { 
		push @parray,"offset=\$offset";		# replaceable portion of the string
	} else {
		my $val = urlescape($params->{$key});
		push @parray,"$key=$val";
	}
	}
	if (not defined($params->{offset})) {
	push @parray,"offset=\$offset";		# replaceable portion of the string
	}
	my $pstring = join(';',@parray);
 
	# number of pages to list that are clickable for jumping to by default
	my $width = getConfig("page_widget_width");
 
	my $ofs;					# place to hold offset calculations
	my $ps;					 # place to hold param string building
	
	$html .= "<br/><center>";

	# find the "window" of the page jump list
	#
	my $margin = int($width/2);
	my $rightpages = $pages - $page;
	my $extra = $margin > $rightpages ? $margin - $rightpages : 0;
	my $startpage = $page - ($margin + $extra) < 1 ? 1 :
 		$page - ($margin + $extra);
	my $endpage = $startpage + $width - 1 > $pages	? $pages : 
		$startpage + $width - 1;
 
	$html .= "jump to page: ";

	if ($page > 1) {
		$ofs = $offset - $slicesize;
		$ps = $pstring;
		$ps =~ s/\$offset/$ofs/;
		$html .= "<a href=\"".getConfig("main_url")."/?$ps\">&lt;&lt;</a> ";
	}

	# actually build the jump pages
	#
	for (my $i = $startpage; $i <= $endpage; $i++) {
		$ofs = ($i-1)*$slicesize;
	$ps = $pstring;
	$ps =~ s/\$offset/$ofs/;
	if ($offset == $ofs) {
			$html .= "$i "
	} else {
			$html .= "<a href=\"".getConfig("main_url")."/?$ps\">$i</a> "
	}
	}
	
	if ($page < $pages) {
		$ofs = $offset + $slicesize;
		$ps = $pstring;
		$ps =~ s/\$offset/$ofs/;
		$html .= "<a href=\"".getConfig("main_url")."/?$ps\">&gt;&gt;</a>";
	}

	$html .= " of $pages ($total items)</center>";

	return $html;
}

# XML-embeddable version of the pager
#
sub getPageWidgetXSLT {
	my ($template, $params, $userinf, $scale) = @_;

	my $slicesize = $userinf->{'prefs'}->{'pagelength'} || '020';

	$scale = 1 unless $scale;
	$slicesize =~ s/^0*//go;
	$slicesize = int($slicesize / $scale);

	return 0 if (not defined $params->{total} or $params->{total} == 0);

	my $total = $params->{total};
	my $offset = $params->{offset}||0;
	my $pages = int(($params->{total} + $slicesize - 1) / $slicesize);
	my $page = int($offset / $slicesize) + 1;

	# <pager total="n" pages="n" [current="n" [prevhref="..."] [nexthref="..."]])>
	#		 <page number="n" (href="..." | selected="1")/>...
	# </pager>
	# if total attribute is set, pager is an empty element

	if($pages == 1) {
		$template->addText("<pager total=\"$total\" pages=\"1\"/>");
		return;
	}

	my @parray = ();

	foreach my $key (keys(%$params)) {
		if($key eq 'offset') {
			push @parray, "offset=\$offset";
		} else {
				push @parray, "$key=$params->{$key}";
		}
	}
	push @parray, "offset=\$offset" unless defined($params->{offset});

	my $pstring = join(';', @parray);
	my $width = getConfig("page_widget_width");
	my $ofs;
	my $ps;

	# find the "window" of the page jump list
	#
	my $margin = int($width/2);
	my $rightpages = $pages - $page;
	my $extra = $margin > $rightpages ? $margin - $rightpages : 0;
	my $startpage = $page - ($margin + $extra) < 1 ? 1 :
		$page - ($margin + $extra);
	my $endpage = $startpage + $width - 1 > $pages	? $pages : 
		$startpage + $width - 1;

	$template->addText("<pager total=\"$total\" current=\"$page\" pages=\"$pages\"");
	if($page > 1) {
		$ofs = $offset - $slicesize;
		$ps = $pstring;
		$ps =~ s/\$offset/$ofs/;
		$template->addText(" prevhref=\"".getConfig("main_url")."/?$ps\"");
	}
	if($page < $pages) {
		$ofs = $offset + $slicesize;
		$ps = $pstring;
		$ps =~ s/\$offset/$ofs/;
		$template->addText(" nexthref=\"".getConfig("main_url")."/?$ps\"");
	}
	$template->addText(">");
	foreach my $i ($startpage..$endpage) {
		$ofs = ($i - 1) * $slicesize;
		$ps = $pstring;
		$ps =~ s/\$offset/$ofs/;
		$template->addText("<page number=\"$i\" ");
		if($offset == $ofs) {
			$template->addText("selected=\"1\"/>");
		} else {
			$template->addText("href=\"".getConfig("main_url")."/?$ps\"/>");
		}
	}
	$template->addText("</pager>");
}

# print math titles with symbol images
#
sub mathTitle {
	my $text = swaptitle(shift);
	my $style = shift || 'normal';

	$text = TeXtoUTF8($text);	# handle TeX internationalization

	my $output = $text;

	my %replaced;	# only do one replace per unique math mode chunk

	# look for math modes
	while ($text =~ /\$(\s*(.+?)\s*)\$/g) {
		my $original = $1;
		my $math = $2;				 # get math
		
		if (not exists $replaced{$original}) {
			my $replace = getRenderedContentImage($math, $style);
				
			# replace symbol in original string
			$output =~ s/\$\Q$original\E\$/$replace/g;

			$replaced{$original} = 1;
		}
	}
	
	return $output || '(no title)';
}

# print math titles with symbol images, for use in XSL
#
sub mathTitleXSL {
	my $text = htmlescape(swaptitle(shift));
	my $style = shift || 'normal';

	my $xml = '';

	$xml .= '<mathytitle>';

	$text = TeXtoUTF8($text);	# handle TeX internationalization

	# split text into math modes and regular text
	#
	my @chunks = split (/(\$\s*.+?\s*\$)/, $text);

	for (my $i = 0; $i <= $#chunks; $i++) {

		# chunk is math
		#
		if ($chunks[$i] =~ /^\$(?:\s*(.+?)\s*)\$$/) {
			$xml .= '<chunk type="math">';
		
			my $math = $1; # get math
		
			my ($url, $align) = getRenderedContentImageURL($math, $style);
				
			$xml .= '	<content>';
			$xml .= htmlescape($math);
			$xml .=	'</content>';
			if (defined $url) {
				$xml .= '	<imageurl>';
				$xml .= $url;
				$xml .= '</imageurl>';
			}
			if (defined $align) {
				$xml .= '	<align>';
				$xml .= $align;
				$xml .= '</align>';
			}

			$xml .= '</chunk>';
		} 

		# chunk is text
		#
		else {
			$xml .= '<chunk type="text">';
			$xml .= '	<content>';
			$xml .= $chunks[$i];
			$xml .= '</content>';
			$xml .= '</chunk>';
		}
	}

	$xml .= '</mathytitle>';
	
	return $xml;
}

1;

