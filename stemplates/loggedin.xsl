<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output omit-xml-declaration="yes"/>
<xsl:template match="/logged_in">
<div id="logged_in"> <h1><xsl:value-of select="username"/></h1>

<div class="logout"> <a href="/?op=logout">Logout</a> </div>
<h2>Do Stuff</h2>
<ul> 
<li><a href="/?op=adden">Create Article</a></li>
<li><a href="/?op=addobj;to=papers">Add a Paper</a></li>
<li><a href="/?op=addobj;to=books">Add a Book</a></li>
<li><a href="/?op=addobj;to=lec">Add a Lecture</a></li>
</ul>
        
<h2>My Stuff</h2>
<ul> 
<li><a href="/?op=edituserobjs">My Articles</a></li>
<li><a href="/?op=editcors">Corrections (<xsl:value-of select="corrections"/>)</a></li>
<li><a href="/?op=mailbox">Mailbox (<xsl:value-of select="mail"/>)</a></li>
<li><a href="/?op=notices">Notices (<xsl:value-of select="notices"/>)</a></li>
<li><a href="/?op=settings">My Account</a></li>
</ul>

<h2>Members Only</h2>
            
<ul>
<li> <a href="/?op=useractivity">User activity</a></li>
<li><a href="/?op=userlist">User list</a></li>
<li><a href="/?op=sysstats">Sys stats</a></li>
</ul>
</div>
            
<xsl:if test="editor">
<div id="editor"> <h1>Editor Tools </h1>
<ul>
<li> <a href="/?op=unpublished">Unpublished</a></li>
<li><a href="/?op=deleted">Deleted</a></li>
</ul>
</div>
</xsl:if>
</xsl:template>
</xsl:stylesheet>
