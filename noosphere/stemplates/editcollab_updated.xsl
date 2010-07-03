<xsl:template match="editcollab_updated">

	<xsl:call-template name="paddingtable">
		<xsl:with-param name="content">
		
			<xsl:call-template name="makebox">
				<xsl:with-param name="title">Document Updated</xsl:with-param>
				<xsl:with-param name="content">

					<table width="100%" cellpadding="4"><tr><td>

					The document '<xsl:value-of select="title"/>' has been updated.

					<p />

					Quick links:

					<p />
	
					<ul>
						<li><a href="{/globals/main_url}/?op=getobj&amp;from={from}&amp;id={id}">view '<xsl:value-of select="title"/>'</a></li>
						<li><a href="{/globals/main_url}/?op=vbrowser&amp;from={from}&amp;id={id}">revision history for <xsl:value-of select="title"/></a></li>
						<li><a href="{/globals/main_url}/?op=collab">collaboration main</a></li>
					</ul>

					</td></tr></table>

				</xsl:with-param>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
