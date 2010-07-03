<xsl:template match="collabmain">
	
	<xsl:call-template name="paddingtable">
	<xsl:with-param name="content">
	<xsl:call-template name="clearbox">
	
		<xsl:with-param name="title">Your Collaborations</xsl:with-param>

		<xsl:with-param name="content">

			<table width="100%" cellpadding="4"><tr><td>

			<!-- no collaborations -->

			<xsl:if test="not(collab)">

				No collaborations yet.

			</xsl:if>

			<!-- show list of collaborations -->

			<p><b>Note:</b> To make a collab object into a site doc, click the <b>publish</b> control first, then contact an admin for their approval.
			</p>

			<dl>

			<xsl:for-each select="collab">

				<dt>

					<xsl:if test="sitedoc=1"> 
						<img 
							alt="This item is collaborative site documentation." 
							title="This item is collaborative site documentation." 
							src="{//globals/image_url}/site_icon.png" 
							border="0"/>
						
						<xsl:text> </xsl:text>
					</xsl:if>

					<a href="{//globals/main_url}/?op=getobj&amp;from=collab&amp;id={uid}"><xsl:value-of select="title"/></a>

					<xsl:if test="not(owner=1)">
						(owner is <xsl:value-of select="ownername"/>)
					</xsl:if>
				</dt>
				
				<dd>

					<!-- abstract/comments -->

					<xsl:choose>

						<xsl:when test="abstract">
							<xsl:value-of select="abstract"/>
						</xsl:when>

						<xsl:otherwise>
							<i>No comment given.</i>
						</xsl:otherwise>
					</xsl:choose>

					<!-- locked information -->

					<xsl:if test="lock">
						<p />

					 	<b>Document is locked</b> by 
						
						<xsl:choose>

							<!-- its possible the locking user may have
								lost their edit and needs to release the lock
								(as in a browser crash) -->

							<xsl:when test="lock/userid = ../thisuser">
								<b>You</b> <xsl:text> </xsl:text>
								<a href="{//globals/main_url}/?op=collab_release_lock&amp;id={uid}">(release lock)</a>
							</xsl:when>

							<!-- show who has the lock, for all other user -->

							<xsl:otherwise>
								<xsl:value-of select="lock/who"/>
								
								since <xsl:value-of select="lock/since"/>
							</xsl:otherwise>
							
						</xsl:choose>
						
					</xsl:if>

					<!-- last edit information -->

					<xsl:if test="lastedit">
						
						<p />

						<i>
							Last edit: <xsl:value-of select="lastedit/when"/> by <xsl:value-of select="lastedit/who"/>

						</i>

					</xsl:if>

					<!-- published information -->

					<xsl:if test="not(sitedoc=1) and published=1">

						<p />

						<b>Published URL</b>: <a href="{url}"><xsl:value-of select="url"/></a>

					</xsl:if>

				</dd>

				<p />

				<center>

					<!-- menu -->

					<xsl:for-each select="menu/item">
						<a href="{url}" title="{tooltip}"><xsl:value-of select="anchor"/></a>

						<xsl:if test="following-sibling::item"> | </xsl:if>

					</xsl:for-each>

				</center>

				<p />
				
			</xsl:for-each>
			
			</dl>

			<!-- dont show tip if there are no items -->

			<xsl:if test="collab">
				<p />

				<center>
				
					<i>Tip: To see what an option does, float your cursor over it for help.</i>
	
				</center>
			</xsl:if>

			</td></tr></table>

		</xsl:with-param>

	</xsl:call-template>

	<!-- menu for non-document specific options -->

	<xsl:call-template name="makebox">

		<xsl:with-param name="title">Menu</xsl:with-param>

		<xsl:with-param name="content">

			<center>
			
				<a href="{//globals/main_url}/?op=edit&amp;from=collab&amp;new=1">Create new collaboration</a>

			</center>

		</xsl:with-param>

	</xsl:call-template>

	</xsl:with-param>
	</xsl:call-template>


</xsl:template>
