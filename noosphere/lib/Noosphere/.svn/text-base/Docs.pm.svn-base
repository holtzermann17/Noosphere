package Noosphere;

use strict;

# show license information for the site
#
sub getLicense {
  
  return paddingTable(clearBox("Legalese",(new Template("license.html"))->expand())); 
  
}

# get the "about" (history, background) page.
#
sub getAbout {

  return paddingTable(clearBox('The '.getConfig('projname').' Story',(new Template('about.html'))->expand())); 
  
}

# get the feedback info page
#
sub getFeedback {

  return paddingTable(clearBox('Feedback',(new Template('feedback.html'))->expand()));

}

1;
