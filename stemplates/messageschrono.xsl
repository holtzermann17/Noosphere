<xsl:template match="messages">

	<xsl:call-template name="paddingtable">
		<xsl:with-param name="content">

	<xsl:call-template name="clearbox">

		<xsl:with-param name="title">All Messages, Ordered by Date</xsl:with-param>

		<xsl:with-param name="content">
		
			<xsl:for-each select="message">

				<xsl:value-of select="date"/> - 

				<a href="{ohref}" title="go to the parent object or forum of this message"><img alt="parent" src="{//globals/image_url}/object.png" border="0"/></a>
				<xsl:text> </xsl:text>

				<xsl:if test="href != thref">
					<a href="{thref}" title="go to the top of the thread containing this message"><img alt="thread top" src="{//globals/image_url}/uparrow.png" border="0"/></a>
					<xsl:text> </xsl:text>
				</xsl:if>

				<a href="{href}"><xsl:value-of select="title"/></a> 
				by 
				<a href="{uhref}"><xsl:value-of select="username"/></a> 
				
				<br/>

			</xsl:for-each>
		
		</xsl:with-param>

	</xsl:call-template>  <!-- clearbox -->
	
	</xsl:with-param>
	</xsl:call-template>  <!-- paddingtable -->

</xsl:template>
