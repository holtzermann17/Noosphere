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
        <xsl:copy-of select="content/node()" />
	<div id="owners">
		<xsl:copy-of select="owners/node()"/>
	</div>
        </div> <!-- end article_box -->
	<div class="box_padding">
        <xsl:copy-of select="viewstyle/node()"/>
	</div>

        <div class="box_padding">
                <div class="messages">
                <h1>How to Cite This Entry</h1>
		<xsl:copy-of select="citation/node()"/>
        </div>
        </div>
        <br />
        <div class="box_padding">
                <div class="messages">
                <h1>Classification</h1>
		<div id="classification">
                <xsl:copy-of select="classification/node()"/>
		</div>
                </div>
         </div>

    <div class="box_padding">
                <div class="messages">
                <h1>Tags</h1>
		<div id="tags">
		  <xsl:copy-of select="tags/node()"/>
		</div>
                </div>
         </div>
        
        <br />
        <div class="box_padding">
                <div class="messages">
                <h1>Pending Errata and Addenda</h1>
        </div>
        </div>
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
