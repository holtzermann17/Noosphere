<xsl:template match="invalidateinlinks">

	<xsl:call-template name="paddingtable">
		<xsl:with-param name="content">
		
			<xsl:call-template name="makebox">
				<xsl:with-param name="title">Entries Linking to '<xsl:value-of select="title"/>' Invalidated</xsl:with-param>
				<xsl:with-param name="content">

					<table width="100%" cellpadding="4"><tr><td>

					All entries which link to '<xsl:value-of select="title"/>' have been invalidated (<xsl:value-of select="count"/> of them).

					<p />

					Quick links:

					<p />
	
					<ul>
					
						<li><a href="{/globals/main_url}/?op=getobj&amp;from={from}&amp;id={objectid}">view '<xsl:value-of select="title"/>'</a></li>
					</ul>

					</td></tr></table>

				</xsl:with-param>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
