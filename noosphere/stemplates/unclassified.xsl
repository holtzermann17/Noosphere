<xsl:template match="unclassifiedlist">

 <xsl:call-template name="paddingtable">
  <xsl:with-param name="content">
   
  <xsl:call-template name="clearbox">
    <xsl:with-param name="title">Unclassified Objects</xsl:with-param>
	<xsl:with-param name="content">

      <xsl:for-each select="item">
	    <xsl:apply-templates select="."/>
      </xsl:for-each>

    </xsl:with-param>

  </xsl:call-template>

  </xsl:with-param>
  
 </xsl:call-template>

</xsl:template>

<xsl:template match="item">

  <xsl:value-of select="series/@ord"/>.
  
  <a>
    <xsl:attribute name="href"> 
	 <xsl:value-of select="object/@href"/>
	</xsl:attribute>

	 <!--<xsl:value-of select="object/@title"/>-->
     <xsl:apply-templates select="title/mathytitle"/>
  </a>	
  
	contributed by 
	
  <a>
    <xsl:attribute name="href">  
	 <xsl:value-of select="user/@href"/>
	</xsl:attribute>

	<xsl:value-of select="user/@name"/>
  </a>
  
  <br/>

</xsl:template>
