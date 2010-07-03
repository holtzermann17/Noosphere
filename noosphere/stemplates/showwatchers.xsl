<!-- this template basically turns a list of user names and hrefs into a page -->

<xsl:template match="watchlist">

  <xsl:call-template name="paddingtable">
   <xsl:with-param name="content">
	
    <xsl:call-template name="clearbox">
        <xsl:with-param name="title">Users Watching 
		  ``<xsl:value-of select="@objtitle"/>''
		</xsl:with-param>
		
        <xsl:with-param name="content">
		    <xsl:choose>
				<xsl:when test="watcher">
            		<xsl:for-each select="watcher">
                		<xsl:apply-templates select="."/>
            		</xsl:for-each>
				</xsl:when>

				<xsl:otherwise>

					There is nobody watching this object.
				</xsl:otherwise>
			</xsl:choose>
        </xsl:with-param>
    </xsl:call-template>

   </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="watcher">

	<xsl:value-of select="@ord"/>.
	
	<a>
	  <xsl:attribute name="href">

	    <xsl:value-of select="@href"/>
	  </xsl:attribute>

	  <xsl:value-of select="@name"/>
	</a>

    <br/>

</xsl:template>

