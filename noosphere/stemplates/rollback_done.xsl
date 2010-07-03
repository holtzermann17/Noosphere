<xsl:template match="rollback_done">

	<xsl:call-template name="paddingtable">
		<xsl:with-param name="content">
		
			<xsl:call-template name="makebox">
				<xsl:with-param name="title">Roll Back Complete</xsl:with-param>
				<xsl:with-param name="content">

					<table width="100%" cellpadding="4"><tr><td>

					Rolled back to to version <xsl:value-of select="ver"/> of object "<xsl:value-of select="title"/>".
					
					<p />

					Quick links:

					<p />
	
					<ul>
						<li><a href="{/globals/main_url}/?op=getobj&amp;from={from}&amp;id={id}">view <xsl:value-of select="title"/></a></li>
						<li><a href="{/globals/main_url}/?op=vbrowser&amp;from={from}&amp;id={id}">revision history for <xsl:value-of select="title"/></a></li>
						<li><a href="{/globals/main_url}/?op=edituserobjs">edit your other objects</a></li>
					</ul>

					</td></tr></table>

				</xsl:with-param>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
