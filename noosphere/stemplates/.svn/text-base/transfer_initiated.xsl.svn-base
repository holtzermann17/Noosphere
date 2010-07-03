<xsl:template match="transfer_initiated">

	<xsl:call-template name="paddingtable">
		<xsl:with-param name="content">
		
			<xsl:call-template name="makebox">
				<xsl:with-param name="title">Transfer Initiated</xsl:with-param>
				<xsl:with-param name="content">

					<table width="100%" cellpadding="4"><tr><td>

					Ownership of '<xsl:value-of select="title"/>' has been offered to <b><xsl:value-of select="targetname"/></b>.  You will be notified of their decision.

					<p />

					Quick links:

					<p />
	
					<ul>
						<li>
							<a href="{/globals/main_url}/?op=edituserobjs">Your objects</a>
						</li> 
						
						<li>
							<a href="{/globals/main_url}/?op=editcors">Your corrections</a>
						</li>
					</ul>

					</td></tr></table>

				</xsl:with-param>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
