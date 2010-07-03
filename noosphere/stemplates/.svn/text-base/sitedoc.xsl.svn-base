<xsl:template match="sitedoc">
	
	<xsl:call-template name="paddingtable">
	<xsl:with-param name="content">
	<xsl:call-template name="clearbox">
	
		<xsl:with-param name="title">PlanetMath Collaborative Documentation</xsl:with-param>

		<xsl:with-param name="content">
	
			<p>
			<font size="+1">Welcome</font> to the PlanetMath Collaborative Documentation Center!  All of the documentation items here are editable by all PlanetMath users, each supervised by an object owner.  All who consider themselves experienced and knowledgeable are encouraged to improve and expand upon the documentation here.
			</p>

			<!-- 
			<p>
			Tip: for PlanetMath project planning and other meta-level discussion, please see the PlanetMath Wiki.
			</p>
			-->

			<!--
			<p>
			The old, static documentation can still be found <a href="{//globals/doc_url}/">here</a>.
			</p>

			<p>
			<b>Note:</b> feel free to start collaborative versions of any of the remaining static PlanetMath documentation.  The procedure is to (1) click on the "create new" link below and create a collaboration on the next page, (2) paste in the current text and TeX-ify, (3) click on its "publish" link, then (4) <a href="mailto:{//globals/feedback_email}">notify us</a> that you want to make the collaboration object visible as site documentation.
			</p>

			<p>
			You can also add completely new site documentation, which has the same procedure as above, minus the copying of step 2.
			</p>
			-->

			<p>

			<i>Note: Feel free to start new site documentation.  The steps for doing this are : (1) click on the "create new" link below and fill in the metadata and data for the initial document on the next page, (2) save the object and click "publish" for it on your "collaborations" page (3) notify the administration that you'd like to make your object a site-wide documentation object using the <a href="mailto:{//globals/feedback_email}">feedback email</a>.  Pending approval, the document will then show up on this page. </i>

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
	
						[ <a href="{//globals/main_url}/?op=collab" title="edit this doc item in the collaboration center.">go to edit page</a> ]

					</center>
	
					<p />
				</xsl:if>
				
			</xsl:for-each>
			
			</dl>

			</td></tr></table>

		</xsl:with-param>

	</xsl:call-template>

	<!-- menu for non-document specific options -->

	<xsl:call-template name="makebox">

		<xsl:with-param name="title">Menu</xsl:with-param>

		<xsl:with-param name="content">

			<center>
			
				<xsl:choose>
					<xsl:when test="loggedin">
						<a href="{//globals/main_url}/?op=edit&amp;from=collab&amp;new=1">Create new doc collaboration</a>
					</xsl:when>

					<xsl:otherwise>
						<i>Create new doc collaboration</i>
					</xsl:otherwise>
		
				</xsl:choose>

			</center>

		</xsl:with-param>

	</xsl:call-template>

	</xsl:with-param>
	</xsl:call-template>


</xsl:template>
