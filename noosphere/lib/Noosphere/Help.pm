package Noosphere;

use strict;

sub getHelp {  
  my $params=shift;
  my $key=$params->{key};
  
  my $html="";

  $html.="<body bgcolor=\"#ffffcc\">"; 
  $html.="<h3>".getConfig('projname')." Help</h3>";

  my $helptext=getHelpText($key);
  if (nb($helptext)) {
    $html.="<i>".$helptext."</i>";
  } else {
	$html.="<i>No help found for '$key', this shouldn't happen.</i>";
  }

  $html.="</body>";

  return $html;
}

1;
