<!-- FIXME: This template does NOT draw a separator between the unfilled and filled requests! -->

<xsl:template match="requests">

  <xsl:call-template name="paddingtable">
   <xsl:with-param name="content">
	
    <xsl:call-template name="clearbox">
        <xsl:with-param name="title">Encyclopedia Request List</xsl:with-param>
        <xsl:with-param name="content">
				<font size="+1">
			   <i><b>The requests list is for requested additions to the <xsl:value-of select="//globals/subject_domain"/> encyclopedia only</b>.  For general queries, please see the "Forums" section.  If you have comments about any of these requests, please post messages to them rather than adding your comment as a new request.</i>
			   </font>
			<p>
           	<xsl:for-each select="request[not(filler)]">
           		<xsl:apply-templates select="."/>
           	</xsl:for-each>
			</p>
			<p>
            <xsl:for-each select="request[filler]">
                <xsl:apply-templates select="."/>
            </xsl:for-each>
			<xsl:if test="not(request)">
				No unfulfilled requests.
			</xsl:if>
			</p>
        </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="makebox">
        <xsl:with-param name="title">Interact</xsl:with-param>
        <xsl:with-param name="content">
            <center>
                <a href="{//globals/main_url}/?op=addreq">add</a> |
                <a href="{//globals/main_url}/?op=updatereq">update</a> |
                <a href="{//globals/main_url}/?op=oldreqs">old requests</a>
            </center>
        </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="$admin">
        <xsl:call-template name="adminbox">
            <xsl:with-param name="title">Admin</xsl:with-param>
            <xsl:with-param name="content">
                <center><a href="{//globals/main_url}/?op=confirmallreq">confirm all</a></center>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:if>

   </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="request">
    <xsl:if test="@fillhref">
        [ <a><xsl:attribute name="href"><xsl:value-of select="@fillhref"/></xsl:attribute><b>fill</b></a>
        | <a><xsl:attribute name="href"><xsl:value-of select="@updatehref"/></xsl:attribute>update</a>
        ]<xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="date"/><xsl:text> </xsl:text>
    <a>
        <xsl:attribute name="href"><xsl:value-of select="title/@href"/></xsl:attribute><xsl:value-of select="title"/>
    </a>
    <font size="-1"> requested by </font>
    <a>
        <xsl:attribute name="href"><xsl:value-of select="requester/@href"/></xsl:attribute><xsl:value-of select="requester"/>
    </a>
    <xsl:if test="filler">
        <xsl:text> </xsl:text><font size="-1"><b>filled</b> by </font>
        <a>
            <xsl:attribute name="href"><xsl:value-of select="filler/@href"/></xsl:attribute><xsl:value-of select="filler"/>
        </a>
    </xsl:if>
    <xsl:apply-templates select="messages"/>
    <br/>
</xsl:template>

<xsl:template match="messages">
    <xsl:if test="@total &gt; 0">
        (<xsl:value-of select="@total"/><xsl:if test="@unseen">, <b><xsl:value-of select="@unseen"/></b></xsl:if>)
    </xsl:if>
</xsl:template>

