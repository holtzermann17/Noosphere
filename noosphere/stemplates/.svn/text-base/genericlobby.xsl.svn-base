<!-- this is the "lobby" (entry point) for the generic object browsing
     methods -->

<!-- template that handles the "entire" screen for viewing a generic list -->

<xsl:template match="genericlobby">
	
		<table width="100%" cellpadding="0" cellspacing="2">

		<tr>
			<td>
				<xsl:call-template name="clearbox">
					<xsl:with-param name="title">
						<xsl:value-of select="@name"/>
					</xsl:with-param>
	
					<xsl:with-param name="content">

						<!-- get introduction blurb -->	
						<xsl:choose>
							<xsl:when test="@name='Papers'">
							Papers are research-calibre (though not necessarily published) expositions of some topic. You can browse papers
							</xsl:when>
							<xsl:when test="@name='Expositions'">
							 Expositions are lectures, lecture notes, or written lessons which have as their focus education rather than research. You can browse expositions
							</xsl:when>
							<xsl:when test="@name='Books'">
							 This section is for books which are available for free in electronic form. You can browse books
							</xsl:when>
						</xsl:choose>
						
						<!-- list of browse methods -->

						<ul>
							<li>
								<a>
									<xsl:attribute name="href">
										/?op=listobj&amp;from=<xsl:value-of select="@table"/>
									</xsl:attribute>

									Chronologically
								</a>
							</li>
							<xsl:if test="//globals/classification_supported = 1">
							<li>
								<a>
									<xsl:attribute name="href">
										/?op=mscbrowse&amp;from=<xsl:value-of select="@table"/>
									</xsl:attribute>

									by Math Subject Classification
								</a>
							</li>
							</xsl:if>
						</ul>
					</xsl:with-param>
				</xsl:call-template>
			</td>
		</tr>

		<tr>
			<td>
				<xsl:apply-templates select="genericinteract"/>
			</td>
		</tr>

		</table>
		
</xsl:template>

<!-- template that handles just the "interact" portion -->

<xsl:template match="genericinteract">

	<xsl:call-template name="makebox">

		<xsl:with-param name="title">Interact</xsl:with-param>

		<xsl:with-param name="content">
			<center>
				<a>
					<xsl:attribute name="href">
						/?op=addobj&amp;to=<xsl:value-of select="table"/>
					</xsl:attribute>
					Add to <xsl:value-of select="name"/>
				</a>
			</center>
		</xsl:with-param>

	</xsl:call-template>

</xsl:template>

