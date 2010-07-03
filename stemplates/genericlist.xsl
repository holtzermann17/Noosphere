<!-- a listing of generic objects (papers, expositions, books) -->

<!-- template that handles the "entire" screen for viewing a generic list -->

<xsl:template match="genericscreen">

	
		<table width="100%" cellpadding="0" cellspacing="2">

		<tr>
			<td>

				<xsl:call-template name="clearbox">
					<xsl:with-param name="title">
						Most Recent <xsl:value-of select="genericlist/@name"/>
					</xsl:with-param>
	
					<xsl:with-param name="content">
						<xsl:apply-templates select="genericlist"/>
					</xsl:with-param>
				</xsl:call-template>
			</td>
		</tr>

		<tr>
			<td>
				<xsl:apply-templates select="genericinteract"/>
			</td>
		</tr>

		</table>
		
</xsl:template>

<!-- template that handles just the "interact" portion -->

<xsl:template match="genericinteract">

	<xsl:call-template name="makebox">

		<xsl:with-param name="title">Interact</xsl:with-param>

		<xsl:with-param name="content">
			<center>
				<a>
					<xsl:attribute name="href">
						/?op=addobj&amp;to=<xsl:value-of select="table"/>
					</xsl:attribute>
					Add to <xsl:value-of select="name"/>
				</a>
			</center>
		</xsl:with-param>

	</xsl:call-template>

</xsl:template>

<!-- template that handles just the list portion -->

<!-- 

	expects:

	<genericlist name="Foo" table="foo">

		<object>

			<ord>1</ord>
			<title>Foo Bar</title>
			<id>1234</id>
			<username>LinusT</username>
			<userid>234</userid>
			<authors>Linus Torvalds</authors>
			<date>YYYY-MM-DD</date>
			<classification>msc:##A##</classification>

		</object>

		...

	</genericlist>

-->

<xsl:template match="genericlist">
	
	<xsl:if test="pager/@pages &gt; 1">
		<xsl:apply-templates select="pager"/>
		<br />
	</xsl:if>

	<table>

		<xsl:for-each select="object">

			<tr>

				<!-- record index -->
				<td valign="top">
					<xsl:value-of select="ord"/>.			
				</td>

				<!-- title and uploader -->
				<td>

					<a>
						<xsl:attribute name="href">
							/?op=getobj&amp;from=<xsl:value-of select="../@table"/>&amp;id=<xsl:value-of select="id"/>
						</xsl:attribute>

						<xsl:value-of select="title"/>
					</a>

					added by 

					<a>
						<xsl:attribute name="href">
							/?op=getuser&amp;id=<xsl:value-of select="userid"/>
						</xsl:attribute>

						<xsl:value-of select="username"/>
					</a>

				</td>

			</tr>

			<tr>

				<td>&nbsp;</td>

				<!-- the rest of the metadata -->

				<td> 
					
					Authors: <xsl:value-of select="authors"/>

					<br />

					Uploaded on: [<xsl:value-of select="date"/>]
					<xsl:if test="normalize-space(classification)">
					, Classification: [<xsl:copy-of select="classification"/>]
					</xsl:if>
				
				</td>

			</tr>

		</xsl:for-each>

	</table>

	<xsl:apply-templates select="pager"/>

</xsl:template>
