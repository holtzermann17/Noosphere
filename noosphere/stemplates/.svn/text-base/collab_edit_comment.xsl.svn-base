<xsl:template match="editcomment">

	<xsl:call-template name="paddingtable">
	<xsl:with-param name="content">
	<xsl:call-template name="makebox">
	<xsl:with-param name="title">Editing Collaboration Comment</xsl:with-param>
	<xsl:with-param name="content">

	<table width="100%" cellpadding="4"><tr><td>

		<table align="center"><tr><td>

		Comment for '<xsl:value-of select="title"/>':

		<p />

		<form method="post" action="{//globals/main_url}/">

			<textarea name="abstract" rows="5" cols="80">
				<xsl:value-of select="abstract"/>
			</textarea>

			<p />

			<input type="hidden" name="op" value="collab_edit_comment"/>
			<input type="hidden" name="id" value="{id}"/>

			<center>
				<input type="submit" name="save" value="save"/>
			</center>
		</form>

		</td></tr></table>

	</td></tr></table>
			
	</xsl:with-param>
	</xsl:call-template>
	</xsl:with-param>
	</xsl:call-template>

</xsl:template>
