<xsl:template match="rollback_confirm">

	<xsl:call-template name="paddingtable">
		<xsl:with-param name="content">
		
			<xsl:call-template name="makebox">
				<xsl:with-param name="title">Roll Back Changes</xsl:with-param>
				<xsl:with-param name="content">

					<table width="100%" cellpadding="4"><tr><td>

					Are you sure you want to roll back to version <xsl:value-of select="ver"/> of object "<xsl:value-of select="title"/>"?  All changes after that version will be lost!

					<p />

					If so, enter in an optional reason (this message will be sent to all persons who have a watch on the object) and click "confirm".

					<p />

					<form method="post" action="{/globals/main_url}">

						<center>

							<table><tr><td>
						
							Reason: <br />

						
							<textarea name="comment" rows="5" cols="60"></textarea>
							</td></tr></table>

							<input type="hidden" name="op" value="{op}"/>
							<input type="hidden" name="from" value="{from}"/>
							<input type="hidden" name="id" value="{id}"/>
							<input type="hidden" name="ver" value="{ver}"/>

							<p />

							<input type="submit" name="confirm" value="confirm"/>
						</center>
					</form>

					</td></tr></table>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
