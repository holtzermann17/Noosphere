<xsl:template match="ver_diff">

  <xsl:call-template name="paddingtable">
   <xsl:with-param name="content">

    <xsl:call-template name="makebox">
        <xsl:with-param name="title">
		Revision difference : <xsl:value-of select="@title"/>
        </xsl:with-param>
        <xsl:with-param name="content">

		<xsl:choose>
			<xsl:when test="@changed > 0">

				<table width="100%" cellspacing="0" cellpadding="0" border="0">
				<tr>
				<th width="50%" valign="top"> Version <xsl:value-of select="@newvernum"/></th>
				<th width="50%" valign="top"> Version <xsl:value-of select="@oldvernum"/></th>
				</tr>
				<xsl:for-each select="line">
				<tr>
					<td><xsl:copy-of select="newtext/*"/></td><td><xsl:copy-of select="oldtext/*"/></td>
				</tr>
				</xsl:for-each>
				</table>

			</xsl:when>
			<xsl:otherwise>
				No changes were made to the content between versions <xsl:value-of select="@oldvernum"/> and <xsl:value-of select="@newvernum"/>. Metadata might have changed.
			</xsl:otherwise>
		</xsl:choose>

		

	</xsl:with-param>

    </xsl:call-template>  <!-- makebox -->

   </xsl:with-param>
  </xsl:call-template>  <!-- paddingtable -->

</xsl:template>
