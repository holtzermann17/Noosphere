package Noosphere;

use strict;

# get requests "interact" box
#
sub getReqInteract {
	my $rec=shift;

	my $table=getConfig('req_tbl');

	my $title=urlescape($rec->{title});

	return makeBox('Interact',"<center><a href=\"".getConfig("main_url")."/?op=addreq\">add</a> | <a href=\"".getConfig("main_url")."/?op=adden&request=$rec->{uid}&title=$title\">fill</a> | <a href=\"".getConfig("main_url")."/?op=updatereq&reqest=$rec->{uid}\">update</a> | <a href=\"".getConfig("main_url")."/?op=postmsg&from=$table&id=$rec->{uid}\">post</a></center>");
}

# get a count of unfilled requests
#
sub getUnfilledReqCount {
	my $table=getConfig('req_tbl');
	
	my ($rv,$sth)=dbSelect($dbh,{WHAT=>'uid',FROM=>$table,WHERE=>'fulfilled is null'});
	my $count=$sth->rows();
	$sth->finish();

	return $count;
}

# view old (confirmed+filled) requests
#
sub oldReqs {
	my $params=shift;
	my $userinf=shift;

	my $html='';
	my $table=getConfig('req_tbl');

	my $offset=$params->{offset}||0;
	my $total=$params->{total}||-1;
	#my $limit=getConfig('listings_page');
	my $limit=$userinf->{'prefs'}->{'pagelength'};

	# get total
	#
	if ($total == -1) {
		my ($rv,$sth)=dbSelect($dbh,{WHAT=>'uid',FROM=>$table,WHERE=>'closed is not null'});
	$total=$sth->rows(); 
	$sth->finish();
	}

	return paddingTable(clearBox('Old Requests',"No old requests")) if ($total == 0);

	# pull up the rows 
	#
	my ($rv,$sth)=dbSelect($dbh,{WHAT=>"$table.*, u1.username, u2.username as username2",FROM=>"$table, users as u1, users as u2" ,WHERE=>"closed is not null and u1.uid=$table.creatorid and u2.uid=$table.fulfillerid",'ORDER BY'=>'created',DESC=>'',OFFSET=>$offset,LIMIT=>$limit});
	my $returned=$sth->rows();
	my @rows=dbGetRows($sth);

	my $start=$offset+1;
	my $finish=$start+$returned-1;

	# do the listing
	#
	my $ord=$start;
	foreach my $row (@rows) {
	my $date=ymd($row->{created});
		$html.="$ord. $date <a href=\"".getConfig("main_url")."/?op=getobj&from=$table&id=$row->{uid}\">$row->{title}</a> <font size=\"-1\">requested by </font><a href=\"".getConfig("main_url")."/?op=getuser&id=$row->{creatorid}\">$row->{username}</a></a>";
	$html.=" (<font size=\"-1\"><b>filled</b> by</font> <a href=\"".getConfig("main_url")."/?op=getuser&id=$row->{fulfillerid}\">$row->{username2}</a>)";
	$html.="<br>";
		$ord++;
	}
		
	$params->{total}=$total;
	$params->{offset}=$offset;
	$html.=getPager($params,$userinf);
	
	return paddingTable(clearBox("Old Requests: $start-$finish of $total" ,$html));
}

# confirm ALL requests
#
sub confirmAllReq {
	my $params = shift;
	my $userinf = shift;

	my $table = getConfig('req_tbl');

	return errorMessage("Access too low to confirm requests!") if ($userinf->{data}->{access}<getConfig('access_admin'));

	my ($rv,$sth) = dbSelect($dbh,{WHAT => 'uid', FROM=>$table, WHERE => "closed is null and fulfilled is not null"});
	
	my @rows = dbGetRows($sth);
	
	foreach my $row (@rows) {
		dbConfirmReq($row->{uid}, $userinf); 
	}

	return reqList($params,$userinf);
}

# confirm a request fulfillment
#
sub confirmReq {
	my $params = shift;
	my $userinf = shift;

	return errorMessage("Access too low to confirm requests!") if ($userinf->{data}->{access}<getConfig('access_admin'));

	dbConfirmReq($params->{id}, $userinf);

	return reqList($params,$userinf);
}

# do db and back-end stuff for confirming a request
#
sub dbConfirmReq {
	my $rid = shift;
	my $userinf = shift;

	my $table = getConfig('req_tbl');

	# modify the request data
	#
	my ($rv,$sth) = dbUpdate($dbh,{WHAT=>$table,SET=>'closed = CURRENT_TIMESTAMP',WHERE=>"uid=$rid"});

	# send out notices (this should get owner and filer too)
	#
	updateEventWatches($rid, 
										 $table, 
					 $userinf->{uid},
					 'Request fulfillment confirmed');
}

# form to get a reason before denying a request
#
sub denyReqForm {
	my $params = shift;
	my $userinf = shift;

	my $html = '';
	my $table = getConfig('req_tbl');

	return errorMessage("Access too low to deny requests!") if ($userinf->{data}->{access} < getConfig('access_admin'));

	# do the denial in the database
	#
	if ($params->{deny}) {
		denyReq($params->{id}, $userinf->{uid}, $params->{reason});
		$html = reqList($params,$userinf);
	} 
	
	# show the initial form
	# 
	else {
		my $title = lookupfield($table, 'title', "uid=$params->{id}");
		my $content = lookupfield($table, 'data', "uid=$params->{id}");
		my $clinks = printContextLinks($params->{id});

		my $template = new XSLTemplate('reqdeny.xsl');

		# send output data
		#
		$template->addText('<reqdeny>');
		$template->setKey('title', $title);
		$template->setKey('content', $content);
		$template->setKey('clinks', $clinks);
		$template->setKeys(%$params);
		$template->addText('</reqdeny>');

		$html = paddingTable(makeBox('Deny a Request Fulfillment', $template->expand()));
	}

	return $html;
}

# form to get a reason before deleting a request
#
sub deleteReqForm {
	my $params = shift;
	my $userinf = shift;

	my $html = '';
	my $table = getConfig('req_tbl');

	return errorMessage("Access too low to delete requests!") if ($userinf->{data}->{access} < getConfig('access_admin'));

	# do the deletion in the database
	#
	if ($params->{'delete'}) {
		deleteReq($params->{id}, $userinf->{uid}, $params->{reason});
		$html = reqList($params,$userinf);
	} 
	
	# show the initial form
	# 
	else {
		my $title = lookupfield($table, 'title', "uid=$params->{id}");
		my $content = lookupfield($table, 'data', "uid=$params->{id}");
		my $clinks = printContextLinks($params->{id});

		my $template = new XSLTemplate('reqdelete.xsl');

		# send output data
		#
		$template->addText('<reqdelete>');
		$template->setKey('title', $title);
		$template->setKey('content', $content);
		$template->setKey('clinks', $clinks);
		$template->setKeys(%$params);
		$template->addText('</reqdelete>');

		$html = paddingTable(makeBox('Delete a Request', $template->expand()));
	}

	return $html;
}

# deny a request fulfillment
#
sub denyReq {
	my $rid = shift;
	my $userid = shift;
	my $reason = shift;

	my $table = getConfig('req_tbl');

	# update the request record 
	#
	my ($rv,$sth) = dbUpdate($dbh,{WHAT=>$table,SET=>'fulfilled = NULL, fulfillerid = NULL',WHERE=>"uid=$rid"});
 
	# send out notices
	#
	updateEventWatches($rid, 
										 $table, 
					 $userid,
					 'Request fulfillment has been rejected',
					 'Reason: '.$reason);
	
	# remove context links
	#
	($rv,$sth) = dbDelete($dbh,{FROM=>'objlinks',WHERE=>"srcid=$rid and srctbl='$table'"});
}

# delete a request
#
sub deleteReq {
	my $rid = shift;
	my $userid = shift;
	my $reason = shift;

	my $table = getConfig('req_tbl');

	# remove the request record 
	#
	my ($rv,$sth) = dbDelete($dbh,{FROM=>$table,WHERE=>"uid=$rid"});
	$sth->finish();
 
	# send out notices
	#
	updateEventWatches($rid, 
										 $table, 
					 $userid,
					 'Request has been deleted',
					 'Reason: '.$reason);
	
	# remove context links
	#
	($rv,$sth) = dbDelete($dbh,{FROM=>'objlinks',WHERE=>"srcid=$rid and srctbl='$table'"});
}

# add a request
#
sub addReq {
	my $params = shift;
	my $userinf = shift;

	return needAccount() if ($userinf->{'uid'} <= 0);
	
	my $template=new Template('addreq.html');
	my $error='';

	if (defined $params->{submit}) {
		foreach my $field ('text','title') {
			if (! nb($params->{$field})) {
			$error="Blank fields not allowed.<br>";
		}
	}
	if (!$error) {
			return insertRequest($params,$userinf);
	}
	} else {
		$template->unsetKeys('text','title','error')
	}
	
	if ($error) {
		$template->setKey('error', $error);
	}

	$template->setKeys(%$params);

	return paddingTable(makeBox("Make a Request",$template->expand()));
}

# actually make a database record
#
sub insertRequest {
	my $params = shift;
	my $userinf = shift;

	my $userid = $userinf->{data}->{uid};
	my $table = getConfig('req_tbl');

	# get a new UID for the entry
	#
	my $newid = nextval($table."_uid_seq");

	my ($rv,$sth) = dbInsert($dbh,{INTO=>$table,COLS=>'created,uid,creatorid,title,data',VALUES=>"now(),$newid,$userid,'".sq($params->{title})."','".sq($params->{text})."'"});

	# add a watch on the request (if the user has the auto-add option on)
	#
	addWatchIfAllowed($table,$newid,$userinf,'objwatch');

	return reqList($params,$userinf);	 # show the list
}

# update a request to be filled by a particular object
#
sub updateRequest { 
	my $params = shift;
	my $userinf = shift;
	
	my $table = getConfig('req_tbl');
	my $olinks = getConfig('olinks_tbl');

	my $identifier = $params->{identifier};
	my $rid = $params->{request};

	# resolve id
	#
	my $id = 0;
	if ($identifier=~/^[0-9]+$/) {
		$id = $identifier;
	} else {
		$id = getidbyname($identifier);
	}

	# see if the request is already filled
	#
	my $filled = lookupfield($table,'fulfilled',"uid=$rid");
	return reqList($params,$userinf) if ($filled);	 # should be undefined

	# get user id (from the object that fills the request)
	# 
	my $userid = lookupfield(getConfig('en_tbl'),'userid',"uid=$id");
	
	# fill the request
	#
	my ($rv,$sth) = dbUpdate($dbh,{WHAT=>$table,SET=>"fulfilled=CURRENT_TIMESTAMP,fulfillerid=$userid",WHERE=>"uid=$rid"});

	# put in context link
	#
	my $en = getConfig('en_tbl');
	($rv,$sth) = dbInsert($dbh,{INTO=>$olinks,COLS=>'srctbl,srcid,desttbl,destid,note',VALUES=>"'$table',$rid,'$en',$id,'request fill'"});

	# send notices for this event
	#
	updateWatches($rid,		# request pointer
								$table,	
				$id,		 # fulfilling object pointer
				$en,
						$userinf->{uid},	# fulfilling user pointer
				'request reported as fulfilled');

	# add watch for fulfillment reporter
	#
	addWatchIfAllowed($table, $rid, $userinf, 'reqfywatch');

	# add watch for fulfillment object author
	#
	my $auid = lookupfield($en,'userid',"uid=$id");
	my $auserinf = {userInfoById($auid)};
	addWatchIfAllowed($table, $rid, $auserinf, 'reqfowatch');

	return reqList($params, $userinf);	 # show the list
}

# form interface for updating the status of a request 
#
sub updateReq {
	my $params = shift;
	my $userinf = shift;

	my $template = new Template("updatereq.html");
	my $error = '';

	return errorMessage("You have to be logged in for this!") if ($userinf->{uid} <= 0);

	if (defined $params->{submit}) {
		$error.="You must select a request.<br>" if ($params->{request} == -1 || $params->{request} eq "[none]");
	$error.="No object found for identifier.<br>" if (!objectExistsByAny($params->{identifier}));

	if (!$error) {
			return updateRequest($params, $userinf);
	}
	} else {
		$template->unsetKey('identifier');
	}

	my $updater = getRequestUpdater($params);
	$template->setKeys(%$params);
	$template->setKeys('error' => $error, 'updater' => $updater);
	
	return paddingTable(makeBox('Update a request',$template->expand()));
}

# return html for self-contained request updater widget
#
sub getRequestUpdater {
	my $params = shift;

	my $html = '';
	my $options = getUnfilledReqs();
	my $request = $params->{request}||-1;

	$html = 'Update filled status for: '.getSelectBoxSortByValue('request',$options,$request);

	return $html;
}

# return html for a self-contained request filler widget
#
sub getRequestFiller {
	my $params = shift;

	my $html = '';
	my $options = getUnfilledReqs();

	$html = getSelectBox('request', $options, $params->{request}||-1);

	return $html;
}

# get a list of currently unfulfilled requests (as an id->title hash)
#
sub getUnfilledReqs {
	my %hash;

	my $table=getConfig('req_tbl');
	
	my ($rv,$sth)=dbSelect($dbh,{WHAT=>'uid,title',FROM=>$table,WHERE=>'fulfilled is null','ORDER BY'=>'lower(title)'});
	my @rows=dbGetRows($sth);

	$hash{"-1"}="[none]";	 # default entry

	foreach my $row (@rows) {
		$hash{$row->{uid}}=$row->{title};
	}

	return {%hash};
}

# fill a request (add a link to fulfilling object)
#
#	this should be called for a fulfillment by the action of the creation of
#	a new object, NOT by the linking of an existing object to a request by a
#	third party (see updateRequest for that)
#
sub fillReq {
	my $rid = shift;
	my $userinf = shift;
	my $objtbl = shift;
	my $objid = shift;

	my $rtbl = getConfig('req_tbl');
	my $otbl = getConfig('olinks_tbl');

	# set request to filled
	#
	my ($rv,$sth) = dbUpdate($dbh,{WHAT=>$rtbl,SET=>"fulfillerid=$userinf->{uid},fulfilled=CURRENT_TIMESTAMP", WHERE=>"uid=$rid"}); 
	
	# add a context link from request object to object which fills it
	#
	($rv,$sth) = dbInsert($dbh,{INTO=>$otbl,COLS=>'srctbl,srcid,desttbl,destid,note',VALUES=>"'$rtbl',$rid,'$objtbl',$objid,'fulfilling request'"});

	# send notices for this event
	#
	updateWatches($rtbl,		# request pointer
								$rid, 
				$objtbl,	# fulfilling object pointer
								$objid,
						$userinf->{uid},	# fulfilling user pointer
				'request set as fulfilled',
				'a new object was created');
	
	# add another watch for fulfiller (if allowed). this allows them to later
	# be notified when their fulfillment is accepted or rejected.
	#
	addWatchIfAllowed($rtbl, $rid, $userinf, 'reqfwatch');
}

# get a list of currently active requests
#
sub reqList {
		my $params = shift;
		my $userinf = shift;
		my $table = getConfig('req_tbl');
		my $template = new XSLTemplate('reqlist.xsl');
		my ($rv, $sth) = dbSelect($dbh, { WHAT => "$table.*, users.username",
																			FROM => "$table, users",
																			WHERE => "closed is null and users.uid = $table.creatorid",
																			'ORDER BY' => 'created',
																			DESC => '' });
		my @rows = dbGetRows($sth);
		my @rowsa;
		my @rowsb;

		foreach my $row (@rows) {
				if(defined $row->{fulfilled}) {
						push @rowsb, $row;
				} else {
						push @rowsa, $row;
				}
		}
		$template->addText("<requests>");
		foreach my $row (@rowsa, @rowsb) {
				my $date = ymd($row->{created});

				# <request [fillhref="..." updatehref="..."]>
				#		 <date>YYYY-MM-DD</date>
				#		 <title href="...">...</title>
				#		 <requester href="...">...</requester>
				#		 [<filler href="...">...</filler>]
				#		 [<messages [unseen="n"] total="n"/>]
				# </request>
				$template->addText("<request");
				if(not defined($row->{fulfilled})) {
						my $title = urlescape($row->{title});

						$template->addText(" fillhref=\"".getConfig("main_url")."/?op=adden;request=$row->{uid};title=$title\"\n");
						$template->addText(" updatehref=\"".getConfig("main_url")."/?op=updatereq;request=$row->{uid}\"\n");
		}
				$template->addText(">\n");
				$template->addText("<date>$date</date>\n");
				$template->addText("<title href=\"".getConfig("main_url")."/?op=getobj;from=$table;id=$row->{uid}\">".htmlescape($row->{title})."</title>\n");
				$template->addText("<requester href=\"".getConfig("main_url")."/?op=getuser;id=$row->{creatorid}\">$row->{username}</requester>\n");
				$template->addText(msgCountWithNewXML($table, $row->{uid}, $userinf->{uid}));
				if(defined($row->{fulfilled})) {
						($rv, $sth) = dbSelect($dbh, { WHAT => 'username',
																					 FROM => 'users',
																					 WHERE => "uid=$row->{fulfillerid}" });
						my $urec = $sth->fetchrow_hashref();

						$sth->finish();
						$template->addText("<filler href=\"".getConfig("main_url")."/?op=getuser;id=$row->{fulfillerid}\">$urec->{username}</filler>\n");
				}
				$template->addText("</request>\n");
		}
		$template->addText("</requests>\n");
		$template->setParam('admin', '1') unless $userinf->{data}->{access} < getConfig('access_admin');
		return $template->expand();
}

# get printed context links
#
sub printContextLinks {
	my $id = shift;	# request id

	my $html = '';
	my $table = getConfig('req_tbl');

		my ($rv,$sth) = dbSelect($dbh,{WHAT=>"destid,desttbl",FROM=>'objlinks',WHERE=>"srcid=$id and srctbl='$table'"});

	if ($sth->rows()>0) {
		my @rows = dbGetRows($sth);

		foreach my $link (@rows) {
			my $title = lookupfield($link->{desttbl},'title',"uid=$link->{destid}");
			$html .= "<a href=\"".getConfig("main_url")."/?op=getobj&amp;from=$link->{desttbl}&amp;id=$link->{destid}\">$title</a> "
		}
	}

	return $html;
}

# view a single request record
#
sub getReq {
	my $params = shift;
	my $userinf = shift;

	my $id = $params->{id};

	my $template = new Template('reqobj.html');

	my $html = '';
	my $table = getConfig('req_tbl');

	my ($rv,$sth) = dbSelect($dbh,{WHAT=>"$table.*,username as createname",FROM=>"$table,users",WHERE=>"$table.uid=$id and users.uid=creatorid"});

	return errorMessage('Error with query') if (!$rv); 
	return errorMessage('Couldn\'t find record!') if ($sth->rows()<1);

	my $row = $sth->fetchrow_hashref();
	$sth->finish();

	my $status = "opened";
	my $filledflag = 0;
	
	if (defined $row->{fulfilled}) {
		$status = "filled (unconfirmed)";
	$filledflag = 1;
	}
	if (defined $row->{closed}) {
		$status = "filled (confirmed)";
	}

	$html .= "Request by: $row->{createname}<br>";
	$html .= "Date: $row->{created}<br>";
	$html .= "Status: $status<br>";
	if ($filledflag) {
		$html .= "Date: $row->{fulfilled}<br>";
	}
	
	$html .= "<br>Title: $row->{title}<br>";

	$html .= "<br>Text:<br>";
	
	$html .= "<table width=\"100%\" cellpadding=\"5\">";
	$html .= "	<tr>";
	$html .= "		<td bgcolor=\"#ffffff\">";
	my $text = tohtmlascii($row->{data});
	$html .= "		$text";
	$html .= "		</td>";
	$html .= "	</tr>";
	$html .= "</table>";

	# show context links
	#
	if ($filledflag) {
	my $clinks = printContextLinks($id);

	if ($clinks) {
		$html .= "<br>Context: ";
		$html .= "<table cellpadding=\"5\"><td>$clinks</td></table>";
	}
	}

	# admin controls 
	#
	if ($userinf->{'data'}->{'access'} >= getConfig('access_admin')
		&& (not defined $row->{'closed'})) {

		$html .= "<center><br>";
		$html .= "[ ";

		if (defined $row->{'fulfilled'}) {
			$html .= "<a href=\"".getConfig("main_url")."/?op=confirmreq&id=$params->{id}\">confirm</a> | ";
			$html .= "<a href=\"".getConfig("main_url")."/?op=denyreq&id=$params->{id}\">deny</a> | ";
		}

		$html .= "<a href=\"".getConfig("main_url")."/?op=deletereq&id=$params->{id}\">delete</a>";
		$html .= " ]";
		$html .= "</center>";
		$html .= "<br>";
	}

	my $interact=getReqInteract($row);
	
	my $up='';
	if ($filledflag && defined $row->{closed}) {
		$up=getUpArrow("".getConfig("main_url")."/?op=oldreqs",'up');
	} else {
		$up=getUpArrow("".getConfig("main_url")."/?op=reqlist",'up');
	}
	
	$template->setKey('request',makeBox("$up Viewing Request",$html));
	$template->setKey('interact',$interact);

	return $template;
}

1;
