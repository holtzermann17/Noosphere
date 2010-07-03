<!-- this stylesheet displays papers, expositions, and books -->

<xsl:template match="object">

	<table width="100%" border="0" cellpadding="0"><tr><td>

	<!-- handle title image and title-->
	<xsl:if test="imageurl">

		<!-- generate the clickable title image -->
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="imagebigurl"/>
			</xsl:attribute>

			<img>
				<xsl:attribute name="border">0</xsl:attribute>
				<xsl:attribute name="align">left</xsl:attribute>
				<xsl:attribute name="src">
					<xsl:value-of select="imageurl"/>
				</xsl:attribute>
			</img>
		</a>
	</xsl:if>

	<br />

	<!-- generate the title -->
	<font size="+2">
		<xsl:value-of select="title"/>
	</font>

	<br /> <br />

	<br />

	<xsl:if test="authors">
		Authors: <xsl:value-of select="authors"/>
		<br />
	</xsl:if>

	Record added by: 

	<a>
		<xsl:attribute name="href">
			/?op=getuser;id=<xsl:value-of select="userid"/>
		</xsl:attribute>

		<xsl:value-of select="username"/>
	</a>

	</td></tr></table>
	
	<dl>

		<xsl:if test="normalize-space(comments)">

			<dt>Comments:</dt>

			<dd><xsl:value-of select="comments"/></dd>
		</xsl:if>

		<dt>Description:</dt>

		<dd><xsl:value-of select="abstract"/></dd>

		<dt>Rights:</dt>

		<dd>
			<xsl:if test="normalize-space(rights)">
				<xsl:copy-of select="rights"/>
			</xsl:if>

			<xsl:if test="not(normalize-space(rights))">
				[none given] (proceed with caution!)
			</xsl:if>
		</dd>

		<!-- output the file list -->
		<xsl:if test="files">
			<dt>Download:</dt>

			<dd>
				<xsl:apply-templates select="files"/>
			</dd>
		</xsl:if>

		<!-- output the url list -->
		<xsl:if test="links">
			<dt>Links:</dt>

			<dd>
				<xsl:apply-templates select="links"/>
			</dd>
		</xsl:if>

	</dl>

	<!-- classification -->
	<xsl:if test="//globals/classification_supported = 1">
		<xsl:if test="classification">
			<xsl:copy-of select="classification"/>
		</xsl:if>
	</xsl:if>
	
	<!-- ISBN (if available) -->
	<xsl:if test="normalize-space(isbn)">
		<br />
		<font size="-1">
			ISBN #: <xsl:value-of select="isbn"/>
		</font>
	</xsl:if>

</xsl:template>

<!-- ============================= -->
<!-- format and output a file list -->
<!-- ============================= -->

<xsl:template match="files">

	<table>
	
	<xsl:for-each select="file">
		
		<tr>

			<td valign="top" align="left">
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="@url"/>
					</xsl:attribute>
					
					<xsl:value-of select="@name"/>
				</a>
			</td>

			<td>&nbsp;&nbsp;</td>

			<!-- output the description -->
			<td valign="top" align="left">
				<value-of select="."/>
			</td>
		</tr>
		
	</xsl:for-each>
	
	</table>

</xsl:template>

<!-- ============================ -->
<!-- format and output a URL list -->
<!-- ============================ -->

<xsl:template match="links">

	<table><tr><td>
	
		<xsl:for-each select="link">
			<a>
				<xsl:attribute name="href">
					<xsl:value-of select="."/>
				</xsl:attribute>

				<xsl:value-of select="."/>
			</a>

			<br />
		</xsl:for-each>

	</td></tr></table>
	
</xsl:template>

