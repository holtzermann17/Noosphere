package Noosphere;
use strict;

#
# modified 2002-02-21 by Aaron Krowne, de-objectified, made part of PM
# removed old documentation, kind of obvious (get Hussein's newest XMLIR if
# you want it.)
#
#  ----------------------------------------------------------------------
# | Trivial Information Retrieval System                                 |
# | Hussein Suleman                                                      |
# | May 2001                                                             |
#  ----------------------------------------------------------------------
# |  Virginia Polytechnic Institute and State University                 |
# |  Department of Computer Science                                      |
# |  Digital Libraries Research Laboratory                               |
#  ----------------------------------------------------------------------

# run the stemmer on a list, returning a new, stemmed list
#
sub stemList {

  my @inlist=@_;

  my @outlist=();

  foreach my $word (@inlist) {
    push @outlist, stem ($word);
  }

  return @outlist;
}

sub porterm
{
   my $aword=shift;
   
   # change all consonants to "c"
   $aword =~ s/(?<=[aeiou])y|[^aeiouy]/c/go;
   # change all vowels to "v"
   $aword =~ s/[^c]/v/go;
   # change multiple occurrences to single
   $aword =~ s/c+/C/go;
   $aword =~ s/v+/V/go;
   # check for internal VCs and count them
   $aword =~ s/^(C?)((VC)*)(V?)$/(length ($2)\/2)/oe;
   
   $aword;
}

sub stem
{
   my $aword=shift; 
   
   if ($aword !~ /^[a-z']+$/)
   { return $aword; }
   
   my $bword;

   # step 1A
   if ($aword =~ /sses$/)
   { $aword =~ s/sses$/ss/o; }
   elsif ($aword =~ /ies$/)
   { $aword =~ s/ies$/i/o; }
   elsif ($aword =~ /ss$/)
   { $aword =~ s/ss$/ss/o; }
   elsif ($aword =~ /s'$/)   # APK : added
   { $aword =~ s/s'$//o; }
   elsif ($aword =~ /'s$/)   # APK : added
   { $aword =~ s/'s$//o; }
   elsif ($aword =~ /s's$/)  # APK : added
   { $aword =~ s/s's$//o; }
   elsif ($aword =~ /s$/)
   { $aword =~ s/s$//o; }
   
   # step 1B
   my $secondorthird = 0;
   if ($aword =~ /eed$/)
   {
      $bword = substr ($aword, 0, -3);
      if (porterm($bword) > 0)
      {
         $aword = $bword.'ee'; 
      }
   }
   elsif ($aword =~ /ing$/)
   {
      $bword = substr ($aword, 0, -3);
      if ($bword =~ /[aeiou]|(?<=[^aeiou])y/)
      {
         $aword = $bword;
         $secondorthird = 1;
      }
   }
   elsif ($aword =~ /ed$/)
   {
      $bword = substr ($aword, 0, -2);
      if ($bword =~ /[aeiou]|(?<=[^aeiou])y/)
      {
         $aword = $bword;
         $secondorthird = 1;
      }
   }
   if ($secondorthird == 1)
   {
      if ($aword =~ /at$/)
      { $aword =~ s/at$/ate/o; }
      elsif ($aword =~ /bl$/)
      { $aword =~ s/bl$/ble/o; }
      elsif ($aword =~ /iz$/)
      { $aword =~ s/iz$/ize/o; }
      elsif ($aword =~ /((?<=[aeiou])y|[^aeioulsz]){2}$/)
      { $aword = substr ($aword, 0, -1); }
      elsif ((porterm($aword) == 1) && ($aword =~ /((?<=[aeiou])y|[^aeiou])((?<=[^aeiou])y|[aeiou])([^aeiouwxy])$/))
      { $aword .= 'e'; }
   }
   
   # step 1C
   if ($aword =~ /y$/)
   {
      $bword = substr ($aword, 0, -1);
      if ($bword =~ /[aeiou]|(?<=[^aeiou])y/)
      {
         $aword = $bword.'i';
      }
   }
   
   # step 2
   if ($aword =~ /(ational|tional|enci|anci|izer|abli|alli|entli|eli|ousli|ization|ation|ator|alism|iveness|fulness|ousness|aliti|iviti|biliti)$/)
   {
      $bword = $aword;
      $bword =~ s/(.*?)(ational|tional|enci|anci|izer|abli|alli|entli|eli|ousli|ization|ation|ator|alism|iveness|fulness|ousness|aliti|iviti|biliti)$/$1 $2/o;
      my %replacer = qw(ational ate tional tion enci ence anci ance izer ize
                     abli able alli al entli ent eli e ousli ous ization ize
                     ation ate ator ate alism al iveness ive fulness ful
                     ousness ous aliti al iviti ive biliti ble);
      my @bwords = split (' ', $bword);
      if (($#bwords == 1) && 
          (porterm ($bwords[0]) > 0))
      {
         $aword = $bwords[0].$replacer{$bwords[1]};
      }
   }
   
   # step 3
   if ($aword =~ /(icate|ative|alize|iciti|ical|ful|ness)$/)
   {
      $bword = $aword;
      $bword =~ s/(.*?)(icate|ative|alize|iciti|ical|ful|ness)$/$1 $2/o;
      my %replacer = ('icate', 'ic', 'ative', '', 'alize', 'al', 'iciti', 'ic',
                   'ical', '', 'ful', '', 'ness', '');
      my @bwords = split (' ', $bword);
      if (($#bwords == 1) && 
          (porterm ($bwords[0]) > 0))
      {
         $aword = $bwords[0].$replacer{$bwords[1]};
      }
   }
   
   # step 4
   if ($aword =~ /(al|ance|ence|er|ic|able|ible|ant|ement|ment|ent|(?<=[st])ion|ou|ism|ate|iti|ous|ive|ize)$/)
   {
      $bword = $aword;
      $bword =~ s/(.*?)(al|ance|ence|er|ic|able|ible|ant|ement|ment|ent|(?<=[st])ion|ou|ism|ate|iti|ous|ive|ize)$/$1/o;
      if (porterm ($bword) > 1)
      {
         $aword = $bword;
      }
   }
   
   # step 5A
   if (substr ($aword, -1) eq 'e')
   {
      my $s1 = substr ($aword, 0, -1);
      my $mm = porterm ($s1);
      if (($mm > 1) || 
          (($mm == 1) && ($s1 !~ /((?<=[aeiou])y|[^aeiou])((?<=[^aeiou])y|[aeiou])([^aeiouwxy])$/)))
      {
         $aword = $s1;
      }
   }
   
   # step 5B
   if ((porterm ($aword) > 1) && ($aword =~ /ll$/))
   {
      $aword = substr ($aword, 0, -1);
   }
   
   $aword;
}

sub testStemmer {

   my @words = qw (tr ee tree y by trouble oats trees ivy troubles private 
                oaten orrery toy caresses ponies ties caress cats
                feed agreed plastered bled motoring sing
                conflated troubling sized hopping tanned falling
                hissing fizzing failing filing happy sky
                relational conditional rational valency hesitancy
                digitizer conformability radically differently vilely
                analogously vietnamization predication operator feudalism
                decisiveness hopefulness callousness formality sensitivity
                sensibility
                triplicate formative formalize electricity electrical hopeful
                goodness revival allowance inference airliner gyroscopic 
                adjustable defensible irritant replacement adjustment 
                dependent adoption homologous communism activate angularity
                homologou effective bowdlerize
                probate rate cease
                controlling rolling
                generalizations oscillators
                relate probate conflate pirate prelate
                derivate activate demonstrate necessitate renovate);

   foreach my $word (@words)
   {
      print "$word --> ".stem ($word)."\n";
   }
}

1;

