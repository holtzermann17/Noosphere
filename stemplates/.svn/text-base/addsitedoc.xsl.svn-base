<xsl:template match="addsitedoc">
	
	<xsl:call-template name="paddingtable">
	<xsl:with-param name="content">
	<xsl:call-template name="clearbox">
	
		<xsl:with-param name="title">PlanetMath Collaboration Objects (not yet site docs)</xsl:with-param>

		<xsl:with-param name="content">
	
			<p>
			Below is a list of all collaboration objects in the system which are not yet site docs (visible in the site docs section).  You can click on the link by each item to make it into a site doc. 
			</p>

			<p>
			<b>Note:</b> Collab objects which have not been published by their owners will not show up here.  Please exhort owners who want their objects sitedoc-ified to use the publish function first.
			</p>

			<hr />

			<table width="100%" cellpadding="4"><tr><td>

			<!-- no collaborations -->

			<xsl:if test="not(docitem)">

				Nothing here yet.

			</xsl:if>

			<!-- show list of collaborations -->

			<dl>

			<xsl:for-each select="docitem">

				<dt>

					<font size="+1">
						<a href="{//globals/main_url}/?op=getobj&amp;from=collab&amp;id={uid}"><xsl:value-of select="title"/></a>
					</font>

					<xsl:choose>
						<xsl:when test="not(owner=1)">
							(owner is <xsl:value-of select="ownername"/>)
						</xsl:when>

						<xsl:otherwise>
							(owned by you)
						</xsl:otherwise>
					</xsl:choose>

				</dt>
				
				<dd>

					<!-- abstract/comments -->

					<xsl:choose>

						<xsl:when test="abstract">
							<xsl:value-of select="abstract"/>
						</xsl:when>

						<xsl:otherwise>
							<i>No description given.</i>
						</xsl:otherwise>
					</xsl:choose>

					<!-- locked information -->

					<!-- last edit information -->

					<xsl:if test="lastedit">
						
						<p />

						<i>
							Last edit: <xsl:value-of select="lastedit/when"/> by <xsl:value-of select="lastedit/who"/>

						</i>

					</xsl:if>


				</dd>

				<p />

				<xsl:if test="../loggedin">
				
					<center>

						<!-- menu -->
	
						[ <a href="{//globals/main_url}/?op=addsitedoc&amp;id={uid}" title="make this collab a site doc object.">make site doc</a> ]

					</center>
	
					<p />
				</xsl:if>
				
			</xsl:for-each>
			
			</dl>

			</td></tr></table>

		</xsl:with-param>

	</xsl:call-template>

	</xsl:with-param>
	</xsl:call-template>


</xsl:template>
