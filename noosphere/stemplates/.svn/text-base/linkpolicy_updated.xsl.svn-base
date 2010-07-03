<xsl:template match="linkpolicy_updated">

	<xsl:call-template name="paddingtable">
		<xsl:with-param name="content">
		
			<xsl:call-template name="makebox">
				<xsl:with-param name="title">Linking Policy for '<xsl:value-of select="@title"/>' Updated</xsl:with-param>
				<xsl:with-param name="content">

					<table width="100%" cellpadding="4"><tr><td>

					The linking policy for '<xsl:value-of select="@title"/>' has been updated.

					<p />

					Quick links:

					<p />
	
					<ul>
						<li><a href="{/globals/main_url}/?op=getobj&amp;from=objects&amp;id={id}">view '<xsl:value-of select="@title"/>'</a></li>
						<li><a href="{/globals/main_url}/?op=linkpolicy&amp;id={id}">edit the linking policy again</a></li>
						<li><a href="{/globals/main_url}/?op=edituserobjs">edit your objects</a></li>
					</ul>

					</td></tr></table>

				</xsl:with-param>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
