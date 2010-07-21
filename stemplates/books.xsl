<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml"  
  	omit-xml-declaration = "yes"/>
<xsl:template match="/object">
<div class="box_padding">
        <div id="article_box">
	<div id="article_menu">
	<ul>
	    <xsl:copy-of select="extraops/node()"/>
	    <li>
		<a>
    		<xsl:attribute name="href">/?op=correct;from=<xsl:value-of select="table"/>;id=<xsl:value-of select="id"/>
	    </xsl:attribute>
	Suggest Correction</a> | </li>
            <li><a>
		<xsl:attribute name="href">/?op=postmsg;from=<xsl:value-of select="table"/>;id=<xsl:value-of select="id"/>
		</xsl:attribute>Comment</a> | </li>
        </ul>
	</div>
	<div id="metamessages">
	<xsl:copy-of select="metamessages/node()"/>
	</div>
	<h1><xsl:copy-of select="title/node()"/></h1>
	Authors: <xsl:copy-of select="authors/node()"/><br/>	
	Record added by: <xsl:copy-of select="owners/node()"/><br/>
	Comments: <xsl:copy-of select="comments/node()"/><br/>
        Description: <br/> <xsl:copy-of select="data/node()" /> <br/>
	Rights: <br/> <xsl:copy-of select="rights/node()"/> <br/>
	Links: <br/> <xsl:copy-of select="urls/node()"/> <br/>
        </div> <!-- end article_box -->

        <br />
        <div class="box_padding">
                <div class="messages">
                <h1>Classification</h1>
		<div id="classification">
                <xsl:copy-of select="classification/node()"/>
		</div>
                </div>
         </div>
        <br />
        <br />
        <div class="box_padding">
                <div class="messages">
         		<h1>Discussion</h1>
 	                <div id="discussion">
			<xsl:copy-of select="messages/node()"/>
	                </div>
                </div>
        </div>
<xsl:copy-of select="jslinks/node()"/>
</div>
</xsl:template>
</xsl:stylesheet>
