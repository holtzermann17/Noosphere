<xsl:template match="ownerhistory">

	<xsl:call-template name="paddingtable">
	<xsl:with-param name="content">

	<xsl:call-template name="clearbox">
	<xsl:with-param name="title">Viewing Owner History for '<xsl:value-of select="@title"/>'</xsl:with-param>
	<xsl:with-param name="content">

		<center>
	
			[ <a href="{/globals/main_url}/?op=getobj&amp;from={@table}&amp;id={@objectid}">back to '<xsl:value-of select="@title"/>'</a> ]
		
			<p />

			<table cellpadding="4">

				<tr>
			
					<td align="center">User</td> 
					<td align="center">Why</td> 
					<td align="center">When</td>

				</tr>

				<xsl:for-each select="owner">

					<tr>

						<td>

							<a href="{/globals/main_url}/?op=getuser&amp;id={userid}"><xsl:value-of select="username"/></a>

						</td>

						<td>

							<xsl:choose>
								<xsl:when test="action='o'">Orphan</xsl:when>
								<xsl:when test="action='a'">Abandon</xsl:when>
								<xsl:when test="action='t'">Transfer</xsl:when>
							</xsl:choose>

						</td>

						<td> <xsl:value-of select="date"/> </td>

					</tr>

				</xsl:for-each>

			</table>


		</center>

		<p />

		<i>Note: the owner history is a list of past owners and the reason ownership changed from them, since July 6, 2003.  Owners earlier than this time will not appear, but they may appear in the author list.</i>

	</xsl:with-param>
	</xsl:call-template>

	</xsl:with-param>
	</xsl:call-template>

</xsl:template>

