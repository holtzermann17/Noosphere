<xsl:template match="authorlist">

	<xsl:call-template name="paddingtable">
	<xsl:with-param name="content">

	<xsl:call-template name="clearbox">
	<xsl:with-param name="title">Viewing Author List for '<xsl:value-of select="@title"/>'</xsl:with-param>
	<xsl:with-param name="content">

		<center>
	
			[ <a href="{/globals/main_url}/?op=getobj&amp;from={@table}&amp;id={@objectid}">back to '<xsl:value-of select="@title"/>'</a> ]
		
			<p />

			<table cellpadding="4">

				<tr>
			
					<td align="center">User</td> 
					<td align="center">Last Edit</td> 

				</tr>

				<xsl:for-each select="author">

					<tr>

						<td>

							<a href="{/globals/main_url}/?op=getuser&amp;id={userid}"><xsl:value-of select="username"/></a>

						</td>

						<td> <xsl:value-of select="date"/> </td>

					</tr>

				</xsl:for-each>

			</table>


		</center>

		<p />

		<i>Note: the author history shows any user who has made an edit to the object, along with (and sorted by) last edit timestamp.  However, non-creator editors from before May 5, 2002, may not appear.</i>

	</xsl:with-param>
	</xsl:call-template>

	</xsl:with-param>
	</xsl:call-template>

</xsl:template>

