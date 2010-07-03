package Noosphere::Ratings::Ratings;
use strict;
use warnings;

use Noosphere;
use Noosphere::DB;
use Noosphere::Util;
use Noosphere::UserData;
use Noosphere::XSLTemplate;

sub aboutRatings {

	my $template = new XSLTemplate('aboutratings.xsl');

	$template->addText("<aboutratings></aboutratings>");	# no data

	return $template->expand();
}

sub getObjectRating {
	my $recid = shift;
	my $userid = shift;
	
	my $userrating = -1.0;
	my $entryrating = -1.0;
	
	my ($rv, $sth) = Noosphere::dbSelect($Noosphere::dbh, {WHAT=>'value',FROM=>'users_rating',WHERE=>'userid='.$userid});
	
	my $row = $sth->fetchrow_hashref();
	$sth->finish();
	if ($sth->rows != 0) {
		$userrating = $row->{'value'};
	}

	($rv, $sth) = Noosphere::dbSelect($Noosphere::dbh, {WHAT=>'value',FROM=>'object_rating',WHERE=>'uid='.$recid});
	$row = $sth->fetchrow_hashref();
	$sth->finish();
	if ($sth->rows != 0) {
		$entryrating = $row->{'value'} / 4;
	}
		
	my $response .= ratBox($entryrating, $userrating);
	return $response;
}

sub ratBox {
	my $entryrat = shift;
	my $userrat = shift;

	my $userimage = Noosphere::getConfig('image_url')."/bar-".decodeValueUserImg($userrat) . ".png";
	my $useralt = "Owner confidence rating: " . decodeValueUser($userrat);
	my $entryimage = Noosphere::getConfig('image_url')."/bar-".decodeValueEntryImg($entryrat). ".png";
	my $entryalt = "Entry average rating: " . decodeValueEntry($entryrat);
	
	my $box = new Template("ratingsbar.html");
	$box->setKeys('userrating'=>"<img border=\"0\" src=\"" . $userimage . "\" alt=\"" . $useralt . "\"/>", 
				  'entryrating'=>"<img border=\"0\" src=\"" . $entryimage . "\" alt=\"" . $entryalt . "\"/>",
				  'useralt'=>$useralt,
				  'entryalt'=>$entryalt);
	return $box->expand();
}

sub decodeValueUser {
	my $value = shift;
	if ($value < 0) {
		return "No information about user quality";
	}
	if ($value < 0.0001) {
		return "Very low";
	}
	if ($value < 0.002) {
		return "Low";
	}
	if ($value < 0.02) {
		return "Medium"
	}
	if ($value < 0.55) {
		return "High";
	}
	return "Very high";
}

sub decodeValueUserImg {
	my $value = shift;
	if ($value < 0) {
		return "noinfo";
	}
	if ($value < 0.0001) {
		return "1";
	}
	if ($value < 0.002) {
		return "2";
	}
	if ($value < 0.02) {
		return "3"
	}
	if ($value < 0.55) {
		return "4";
	}
	return "5";
}

sub decodeValueEntry {
	my $value = shift;
	if ($value < 0) {
		return "No information on entry rating";
	}
	if ($value < 0.2) {
		return "Very low";
	}
	if ($value < 0.4) {
		return "Low";
	}
	if ($value < 0.6) {
		return "Medium"
	}
	if ($value < 0.8) {
		return "High";
	}
	return "Very high";
}

sub decodeValueEntryImg {
	my $value = shift;
	if ($value < 0) {
		return "noinfo";
	}
	if ($value < 0.2) {
		return "1";
	}
	if ($value < 0.4) {
		return "2";
	}
	if ($value < 0.6) {
		return "3"
	}
	if ($value < 0.8) {
		return "4";
	}
	return "5";
}

sub ratingForm {
	my $recid = shift;
	my $params = shift;
	my $userid = shift;
	
	my $i = 0;
	my $j = 0;
	my $a1 = -1; 
	my $a2 = -1; 
	my $a3 = -1;
	my $a4 = -1;
	my $comments = "";
	
	if ($userid >= 0) {
		my ($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{FROM=>'object_rating_all',WHERE=>'weight=20 and ratid=1 and userid='.$userid." and oid=".$recid,WHAT=>"answer, comment"});
		my $row = $sth->fetchrow_hashref();
		if ($row) { $a1 = $row->{'answer'}; $comments=$row->{"comment"}; }
		$sth->finish();
		($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{FROM=>'object_rating_all',WHERE=>'weight=20 and ratid=2 and userid='.$userid." and oid=".$recid,WHAT=>"answer, comment"});
		$row = $sth->fetchrow_hashref();
		if ($row) { $a2 = $row->{'answer'}; $comments=$row->{"comment"}; }
		$sth->finish();
		($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{FROM=>'object_rating_all',WHERE=>'weight=20 and ratid=3 and userid='.$userid." and oid=".$recid,WHAT=>"answer, comment"});
		$row = $sth->fetchrow_hashref();
		if ($row) { $a3 = $row->{'answer'}; $comments=$row->{"comment"}; }
		$sth->finish();
		($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{FROM=>'object_rating_all',WHERE=>'weight=20 and ratid=4 and userid='.$userid." and oid=".$recid,WHAT=>"answer, comment"});
		$row = $sth->fetchrow_hashref();
		if ($row) { $a4 = $row->{'answer'}; $comments=$row->{"comment"}; }
		$sth->finish();
											
		
		my $box = new Template("rateobject.html");
		$box->setKey('id', $recid);
		
		encodeChecked(1, $a1, $box);
		encodeChecked(2, $a2, $box);
		encodeChecked(3, $a3, $box);
		encodeChecked(4, $a4, $box);
		#warn "Comments: " . $comments;
		$box->setKey("comments_text", $comments);
		
		return $box->expand();		
	}

	else {
		my $box = new Template("rateobject-nolog.html");
		$box->setKey('id', $recid);

		return $box->expand();
	}
}

sub encodeChecked {
	my $i = shift;
	my $answer = shift;
	my $box = shift;
	my $j;
	#warn "Generating: ".$i." :: ".$answer;
	for ($j = 0; $j < 6; $j++) {
		if ($answer + 1 == $j) {
	   		$box->setKey("q".($i)."_selected_".($j), "CHECKED");
		} else {
			$box->setKey("q".($i)."_selected_".($j), "");
		}
	}
}

sub getRatingBox {	
	my $params = shift;
	my $uid = $params->{'id'};
	my $userid = shift->{'uid'};

	$Noosphere::dbh->do("lock tables object_rating_all write, object_rating write, objects write, users_clique write, users_clique read, users_clique as uc read");		
	my $sum = getRatingSum($uid);
	my $q1_answer = getAverageRating($uid, "1", $sum);
	my $q2_answer = getAverageRating($uid, "2", $sum);
	my $q3_answer = getAverageRating($uid, "3", $sum);
	my $q4_answer = getAverageRating($uid, "4", $sum);	
	my $avgVal = ($q1_answer + $q2_answer + $q3_answer + $q4_answer) / 4;
	$Noosphere::dbh->do("unlock tables");	
	
	return getBoxInternal($uid, $q1_answer, $q2_answer, $q3_answer, $q4_answer);
}

sub rateObject {
	my $params = shift;
	my $uid = $params->{'id'};
	my $userid = shift->{'uid'};

#warn "Rating object!!!";
#warn "Params: ".$params;
	
	my $q1 = $params->{'q1_answer'};
	my $q2 = $params->{'q2_answer'};
	my $q3 = $params->{'q3_answer'};
	my $q4 = $params->{'q4_answer'};
	my $comments = $params->{'comments'};


	my $karma = getKarma($userid);
	my $rated = 0;
	
#warn "User id = $userid, karma = $karma";	
#my ($rv,$sth) = Noosphere::dbDelete($Noosphere::dbh,{FROM=>'object_rating_all',WHERE=>'weight=20 and userid='.$userid." and oid=".$uid});
#$sth->finish();
	if (($q1 != -1 && $karma - $rated - 1 >= 0) || ($q1 == -1)) {
		my ($rv,$sth) = Noosphere::dbDelete($Noosphere::dbh,{FROM=>'object_rating_all',WHERE=>'weight=20 and ratid=1 and userid='.$userid." and oid=".$uid});
		$sth->finish();
		if ($q1 != -1) {
			($rv,$sth) = Noosphere::dbInsert($Noosphere::dbh,{INTO=>"object_rating_all",COLS=>"oid,ratid,answer,weight,userid,date,comment",VALUES=>$uid.",1,".$q1.",20,".$userid.',now(),"'.$comments.'"'});
			$sth->finish();
			$rated += 1;
		}
	}
	if (($q2 != -1 && $karma - $rated - 1 >= 0) || ($q2 == -1)) {
		my ($rv,$sth) = Noosphere::dbDelete($Noosphere::dbh,{FROM=>'object_rating_all',WHERE=>'weight=20 and ratid=2 and userid='.$userid." and oid=".$uid});
		$sth->finish();
		if ($q2 != -1) {
			($rv,$sth) = Noosphere::dbInsert($Noosphere::dbh,{INTO=>"object_rating_all",COLS=>"oid,ratid,answer,weight,userid,date,comment",VALUES=>$uid.",2,".$q2.",20,".$userid.',now(),"'.$comments.'"'});
			$sth->finish();
			$rated += 1;
		}
	}
	if (($q3 != -1 && $karma - $rated - 1 >= 0) || ($q3 == -1)) {
		my ($rv,$sth) = Noosphere::dbDelete($Noosphere::dbh,{FROM=>'object_rating_all',WHERE=>'weight=20 and ratid=3 and userid='.$userid." and oid=".$uid});
		$sth->finish();
		if ($q3 != -1) {
			($rv,$sth) = Noosphere::dbInsert($Noosphere::dbh,{INTO=>"object_rating_all",COLS=>"oid,ratid,answer,weight,userid,date,comment",VALUES=>$uid.",3,".$q3.",20,".$userid.',now(),"'.$comments.'"'});
			$sth->finish();
			$rated += 1;
		}
	}
	if (($q4 != -1 && $karma - $rated - 1 >= 0) || ($q4 == -1)) {
		my ($rv,$sth) = Noosphere::dbDelete($Noosphere::dbh,{FROM=>'object_rating_all',WHERE=>'weight=20 and ratid=4 and userid='.$userid." and oid=".$uid});
		$sth->finish();
		if ($q4 != -1) {
			($rv,$sth) = Noosphere::dbInsert($Noosphere::dbh,{INTO=>"object_rating_all",COLS=>"oid,ratid,answer,weight,userid,date,comment",VALUES=>$uid.",4,".$q4.",20,".$userid.',now(),"'.$comments.'"'});
			$sth->finish();
			$rated += 1;
		}
	}

	my ($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{FROM=>"objects",WHAT=>"userid",WHERE=>"uid=".$uid});
	my $row = $sth->fetchrow_hashref();
	my $objectowner = $row->{'userid'};
	$sth->finish();

	if (isSpammer($userid, $objectowner) == 0) {
		Noosphere::changeUserScore($userid, $rated, 1);
	}
	updateKarma($userid, $rated);

	$Noosphere::dbh->do("lock tables object_rating_all write, object_rating write, objects write, users_clique read, users_clique as uc read");		
	my $sum = getRatingSum($uid);
	my $q1_answer = getAverageRating($uid, "1", $sum);
	my $q2_answer = getAverageRating($uid, "2", $sum);
	my $q3_answer = getAverageRating($uid, "3", $sum);
	my $q4_answer = getAverageRating($uid, "4", $sum);	
#	my $avgVal = ($q1_answer + $q2_answer + $q3_answer + $q4_answer) / 4;
    
	$Noosphere::dbh->do("delete from object_rating where uid=".$uid);
	my $ins = "insert into object_rating (uid, userid, value) select * from (select ".'object_rating_all.oid, objects.userid, sum((1 - (select case when sum(probability) is null then 0 else sum(probability) end from users_clique where rating_user = object_rating_all.userid and rated_user=objects.userid)) * answer) / sum(1 - (select case when sum(probability) is null then 0 else sum(probability) end from users_clique as uc where rating_user = object_rating_all.userid and rated_user=objects.userid)) as value from '.'object_rating_all, objects where '."object_rating_all.oid = objects.uid and oid=".$uid." group by object_rating_all.oid, objects.userid) as a where value is not null";
#warn "select: " . $ins;
	$Noosphere::dbh->do($ins);
	#($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{WHERE=>"a.oid = b.uid and oid=".$uid." group by a.oid, b.userid order by a.oid",FROM=>'object_rating_all a, objects b',WHAT=>'avg((1 - (select case when sum(probability) is null then 0 else sum(probability) end from users_clique where rating_user = a.userid and rated_user=b.userid)) * answer) as value'});
	#$row = $sth->fetchrow_hashref();
	#$sth->finish();
	#my $avgVal = $row->{'value'};

	#$Noosphere::dbh->do("insert into object_rating (uid, userid, value) values (".$uid.",".$objectowner.",".$avgVal.")");
	
	$Noosphere::dbh->do("unlock tables");	
	
	return getBoxInternal($uid, $q1_answer, $q2_answer, $q3_answer, $q4_answer, $karma, $rated);
}

sub isSpammer {
	my $ratingUser = shift;
	my $ratedUser = shift;
	my ($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{WHAT=>"count(*) as cnt", FROM=>'users_clique',WHERE=>"rating_user=$ratingUser and rated_user=$ratedUser"});
	my $row = $sth->fetchrow_hashref();
	$sth->finish();
	return $row->{"cnt"};
}

sub getKarma {
	my $userid = shift;
	my ($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{WHAT=>"karma", FROM=>'users',WHERE=>'uid='.$userid});
	my $row = $sth->fetchrow_hashref();
	$sth->finish();
	return $row->{"karma"};
}

sub updateKarma {
	my $userid = shift;
	my $rated = shift;
	
	my ($rv,$sth) = Noosphere::dbUpdate($Noosphere::dbh,{WHAT=>"users", WHERE=>"uid=$userid", SET=>"karma = karma - $rated"});
	$sth->finish();
}

sub getBoxInternal {
	my $uid = shift;	
	my $q1_answer = shift;
	my $q2_answer = shift;
	my $q3_answer = shift;
	my $q4_answer = shift;	
	my $karma = shift;
	my $rated = shift;
	
	my $avgVal;
	my $avgVal1 = 0;
	my $sum = 0;

	if (defined $q1_answer) {$avgVal1 += $q1_answer; $sum++;}
	if (defined $q2_answer) {$avgVal1 += $q2_answer; $sum++;}
	if (defined $q3_answer) {$avgVal1 += $q3_answer; $sum++;}
	if (defined $q4_answer) {$avgVal1 += $q4_answer; $sum++;}
	if ($sum != 0) {
		$avgVal = $avgVal1 / $sum;
	}
	
	my $html = "";
	my $box = new XSLTemplate('ratedobject.xsl');

	my $xml = "<ratedobject>\n";

	$xml .= "<objectid>$uid</objectid>\n";
	my $title = Noosphere::lookupfield('objects','title',"uid=$uid");
	$xml .= "<title>".Noosphere::htmlescape($title)."</title>\n";

	
	
	my ($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{FROM=>'object_rating_all',WHAT=>'count(*) as value',WHERE=>'oid = '.$uid.' and weight=20'});
 	my $row = $sth->fetchrow_hashref();
	$sth->finish();
	my $recent = $row->{'value'};
	
	($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{FROM=>'object_rating_all',WHAT=>'count(*) as value',WHERE=>'oid = '.$uid});
	$row = $sth->fetchrow_hashref();
	$sth->finish();
	my $all = $row->{'value'};

	($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{FROM=>'object_rating_all',WHAT=>'count(*) as value',WHERE=>'oid = '.$uid.' and weight > 0'});
	$row = $sth->fetchrow_hashref();
	$sth->finish();
	my $active = $row->{'value'};

#	warn "Box internal: ".$q1_answer." ".$q2_answer." ".$q3_answer." ".$q4_answer;
	my $q1_image = Noosphere::getConfig('image_url')."/bar-".(defined $q1_answer ? decodeValueEntryImg($q1_answer/4) : "noinfo") . ".png";	
	my $q2_image = Noosphere::getConfig('image_url')."/bar-".(defined $q2_answer ? decodeValueEntryImg($q2_answer/4) : "noinfo") . ".png";
	my $q3_image = Noosphere::getConfig('image_url')."/bar-".(defined $q3_answer ? decodeValueEntryImg($q3_answer/4) : "noinfo") . ".png";
	my $q4_image = Noosphere::getConfig('image_url')."/bar-".(defined $q4_answer ? decodeValueEntryImg($q4_answer/4) : "noinfo") . ".png";
	my $avg_image = Noosphere::getConfig('image_url')."/bar-".(defined $avgVal ? decodeValueEntryImg($avgVal/4) : "noinfo") . ".png";

#warn "Q1 before: ".$q1_answer;
#warn "Q2 before: ".$q2_answer;
#warn "Q3 before: ".$q3_answer;
#warn "Q4 before: ".$q4_answer;
	
	if (defined $q1_answer) {$q1_answer++;} 
	if (defined $q2_answer) {$q2_answer++;} 
	if (defined $q3_answer) {$q3_answer++;} 
	if (defined $q4_answer) {$q4_answer++;} 
	if (defined $avgVal) {$avgVal++;}
	
#warn "Q1: ".$q1_answer;
#warn "Q2: ".$q2_answer;
#warn "Q3: ".$q3_answer;
#warn "Q4: ".$q4_answer;

	$xml .= "<q1_answer>".(defined $q1_answer ? $q1_answer : "?")."</q1_answer>\n";
	$xml .= "<q2_answer>".(defined $q2_answer ? $q2_answer : "?")."</q2_answer>\n";
	$xml .= "<q3_answer>".(defined $q3_answer ? $q3_answer : "?")."</q3_answer>\n";
	$xml .= "<q4_answer>".(defined $q4_answer ? $q4_answer : "?")."</q4_answer>\n";
	$xml .= "<q1_image>$q1_image</q1_image>\n";
	$xml .= "<q2_image>$q2_image</q2_image>\n";
	$xml .= "<q3_image>$q3_image</q3_image>\n";
	$xml .= "<q4_image>$q4_image</q4_image>\n";
	$xml .= "<all>$all</all>\n";
	$xml .= "<avg>".($avgVal ? $avgVal : "?")."</avg>\n";
	$xml .= "<avg_image>$avg_image</avg_image>\n";
	$xml .= "<recent>$recent</recent>\n";
	$xml .= "<active>$active</active>\n";
	$xml .= "<details>";

	($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{FROM=>'object_rating_all a, users b',WHAT=>'username, weight, date, comment, sum(if (ratid=1, answer+1, 0)) as a1, sum(if (ratid=2, answer+1, 0)) as a2, sum(if (ratid=3, answer+1, 0)) as a3, sum(if (ratid=4, answer+1, 0)) as a4',WHERE=>'oid = '.$uid.' and weight > 0 and a.userid=b.uid and a.userid!=0 group by username, weight order by date'});

	
	
	while ($row = $sth->fetchrow_hashref()) {
		$xml .= "<rate><user>".$row->{"username"}."</user><date>".$row->{"date"}."</date>".
				"<a1>".($row->{"a1"} != 0 ? $row->{"a1"} : "?")."</a1>".
				"<a2>".($row->{"a2"} != 0 ? $row->{"a2"} : "?")."</a2>".
				"<a3>".($row->{"a3"} != 0 ? $row->{"a3"} : "?")."</a3>".
				"<a4>".($row->{"a4"} != 0 ? $row->{"a4"} : "?")."</a4><comment>".$row->{"comment"}."</comment></rate>\n";
	}
	$sth->finish();
	
	$xml .= "</details>\n";
	if (defined $karma) {
		$xml .= "<karmainfo>1</karmainfo><karma>".($karma - $rated)."</karma><rated>$rated</rated>";
	}
	$xml .= "</ratedobject>\n";

	$box->addText($xml);

#	$box->setKeys('q1_answer'=>$q1_answer+1,'q2_answer'=>$q2_answer+1,'q3_answer'=>$q3_answer+1,'q4_answer'=>$q4_answer+1);
#	$box->setKeys('recent'=>$recent,'all'=>$all,'avg'=>$avgVal+1);
	
	$html = $box->expand();	
	return $html;
}

sub getAverageRating {
	my $uid = shift;
	my $qid = shift;
	my $sum = shift;
	my ($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{FROM=>'(select sum((1 - (select case when sum(probability) is null then 0 else sum(probability) end from users_clique where rating_user = object_rating_all.userid and rated_user=objects.userid)) * answer) / sum(1 - (select case when sum(probability) is null then 0 else sum(probability) end from users_clique as uc where rating_user = object_rating_all.userid and rated_user=objects.userid)) as average from object_rating_all, objects where object_rating_all.oid=objects.uid and object_rating_all.oid = '.$uid.' and ratid='.$qid.') as a',WHAT=>'a.average as value'});
	my $row = $sth->fetchrow_hashref();
	$sth->finish();
	return $row->{'value'};
}

sub decreaseObjectRatings {
	my $uid = shift;
	
	my ($rv,$sth) = Noosphere::dbUpdate($Noosphere::dbh,{WHAT=>"object_rating_all",
			SET=>"weight = case when weight - 1 > 0 then weight - 1 else 0 end",
			WHERE=>"oid = " . $uid});
	$sth->finish();
	
}

sub getRatingSum {
	my $oid = shift;
	my ($rv,$sth) = Noosphere::dbSelect($Noosphere::dbh,{FROM=>'object_rating_all',WHERE=>"oid=".$oid,WHAT=>"distinct weight as val"});
	my $row;
	my $sum = 0;
	while ($row = $sth->fetchrow_hashref()) {
		#warn "get :" . $row->{'val'};
		$sum += $row->{'val'};
	}
	return $sum;
}

BEGIN {
	warn "Ratings module loaded\n";
#	print "Print from init\n";
}

1;
