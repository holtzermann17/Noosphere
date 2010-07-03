<xsl:template match="newpoll">

    <xsl:call-template name="paddingtable">
	<xsl:with-param name="content"> 
	
	<xsl:call-template name="makebox">
	<xsl:with-param name="title">Create Poll</xsl:with-param> 
	<xsl:with-param name="content">

	<table width="100%" cellpadding="4">

		<tr>
			<td>
				<form method="post" action="{//globals/main_url}/">
					<xsl:if test="normalize-space(error)">
						<font color="#ff0000" size="+1"><xsl:copy-of select="error"/></font>

						<br />
					</xsl:if>
		
					Question: <input type="text" name="question" value="{question}" size="30"/>
					
					<br /><br />
					
					Response options (comma-separated list) : <br />
					
					<textarea name="response" rows="4" cols="40"><xsl:value-of select="response"/></textarea>
					
					<br /><br />
					
					Time to live (days):

					<input type="text" name="ttl" value="{ttl}" size="10"/>
		
					<br /><br />
	
					<input type="hidden" name="op" value="newpoll"/>
					
					<center>
					
						<input type="submit" name="submit" value="create"/>
					
					</center>
				</form>

			</td>

		</tr>
	</table>

	</xsl:with-param> 
	</xsl:call-template> 
	</xsl:with-param> 
	</xsl:call-template>
										
</xsl:template>
