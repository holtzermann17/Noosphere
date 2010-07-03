package Noosphere;
use strict;

sub setCookie {
	my $req = shift;
	my $key = shift;
	my $val = shift;
	my $exp = shift;
 
	my $addrs = getConfig("siteaddrs");
	my $dom = $addrs->{'main'};
	my $pth = '/';
	my $expires = $exp ? "max-age=$exp" : "";
	my $cookie;
 
# planetmath.org does NOT domain-match .planetmath.org, so paranoid browsers
# such as w3m will drop the cookie.  This adds another cookie leaves the
# domain attribute implicit (so it defaults to the request host)
# APK - this still doesn't work in w3m, and people with IE are still unable
# to stay logged in.
#
	$cookie = join ('; ', "$key=$val", "path=$pth", $expires);
	#$cookie="$key=$val; expires=$exp; path=$pth";
	dwarn "setting cookie $cookie";
	$req->headers_out->add("set-cookie" => "$cookie");
}

sub clearCookie {
	my $req = shift;
	my $key = shift;
	setCookie($req,$key,"",0);
}

sub parseCookies {
	my $req = shift;
	
	my $buf = $req->headers_in->{"cookie"};
	
	my @data = split(/;\s*/,$buf);
	
	my %cookies;
	
	dwarn "cookies\n" if (scalar @data);
	foreach my $cookie (@data) {
		
		my ($key,$val) = split(/=/,$cookie);
		$cookies{$key} = $val;
		dwarn "\t$key=>$val\n"; 
	}

	return %cookies; 
}

1;
