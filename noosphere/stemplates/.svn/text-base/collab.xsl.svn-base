<xsl:template match="collab">

	<xsl:call-template name="mathbox">
	<xsl:with-param name="width">100%</xsl:with-param>
	<xsl:with-param name="title"><xsl:value-of select="title"/></xsl:with-param>

	<xsl:with-param name="content">

		<!-- content display section -->

		<xsl:copy-of select="content"/>

	</xsl:with-param>
	</xsl:call-template>

	<!-- metadata display section -->

	<p/>


	<!-- misc controls -->

	<table width="100%">
		<tr>
			<td align="left">
			
				<!-- view style/render method changing widget -->

				<xsl:copy-of select="viewstyle"/>
			</td>

			<td align="center">
				
				<!-- watch widget -->

				<xsl:copy-of select="watchwidget"/>
			</td>
		</tr>
	</table>

	<p/>

	<font size="-1">
	
		The owner of this object is <a href="{//globals/main_url}/?op=getuser&amp;id={userid}"><xsl:value-of select="ownername"/></a>.  
		
		See also the <a href="{//globals/main_url}/?op=authorlist&amp;from=collab&amp;id={uid}">author list</a> (<xsl:value-of select="author_count"/>) 
		
		<xsl:if test="owner_count > 0">
			and 
		
			<a href="{//globals/main_url}/?op=ownerhistory&amp;from=collab&amp;id={uid}">owner history</a> (<xsl:value-of select="owner_count"/>)
		</xsl:if>

		.
		
		<p/>
		
		This is 
			<a href="{//globals/main_url}/?op=vbrowser&amp;from=collab&amp;id={uid}">version <xsl:value-of select="version"/></a> 
		of 
			"<xsl:value-of select="title"/>".
	
		<br />

		Created on <xsl:value-of select="created"/>

		<xsl:if test="version > 1">
			, last modified on <xsl:value-of select="modified"/>
		</xsl:if>
		.

		<br />

		Accessed <xsl:value-of select="hits"/> times total.
	
	</font>

	<p/>
	
</xsl:template>
