<xsl:template match="editcollab">

	<xsl:call-template name="paddingtable">
	<xsl:with-param name="content">
	<xsl:call-template name="makebox">
	<xsl:with-param name="title">Editing Collaboration</xsl:with-param>
	<xsl:with-param name="content">

	<table width="100%" cellpadding="4"><tr><td>

	<!-- main content -->

	<form method="post" action="{//globals/main_url}/" enctype="multipart/form-data" accept-charset="UTF-8">

	<xsl:choose>

		<!-- update mode (get revision comment) -->
			
		<xsl:when test="mode='update'">

			Here you can enter a revision comment for your changes.   We <b>strongly recommend</b> you do this, for the convenience of everyone involved.

			<p />

			<textarea name="revcomment" cols="80" rows="5"></textarea>

			<input type="hidden" name="title" value="{title}"/>
			<input type="hidden" name="data" value="{data}"/>
			<input type="hidden" name="tempdir" value="{tempdir}"/>
	
			<p />
			
			<center>
				<input type="submit" name="save" value="commit"/>
			</center>

		</xsl:when>
		
		<!-- preview mode -->

		<xsl:when test="mode='preview'">

				<center>
					<input type="submit" name="edit" value="back to editing"/>
					<xsl:text> </xsl:text>
					<input type="submit" name="filebox" value="manage file box"/>
				</center>

				<p />

				<xsl:choose>
				
					<xsl:when test="preview/content">

						<center>

						<xsl:call-template name="mathbox">
						<xsl:with-param name="title">Preview of '<xsl:value-of select="title"/>'</xsl:with-param>
						<xsl:with-param name="content">
							
							<xsl:copy-of select="preview/content"/>
		
						</xsl:with-param>
						</xsl:call-template>

						</center>
					</xsl:when>

					<xsl:otherwise>

						<font size="+1" color="#ff0000">Error rendering your LaTeX! Please return to editing and check your source.</font>

					</xsl:otherwise>

				</xsl:choose>

				<p />
				
				<xsl:if test="new=1"><input type="hidden" name="abstract" value="{abstract}"/></xsl:if>
				<input type="hidden" name="title" value="{title}"/>
				<input type="hidden" name="data" value="{data}"/>
				<input type="hidden" name="tempdir" value="{tempdir}"/>

				<center>
					<input type="submit" name="edit" value="back to editing"/>
					<xsl:text> </xsl:text>
					<input type="submit" name="filebox" value="manage file box"/>
				</center>

		</xsl:when>

		<!-- filebox mode -->

		<xsl:when test="mode='filebox'">

				<!-- show the file manager -->

				<xsl:copy-of select="fmanager"/>

				<p />
				
				<xsl:if test="new=1"><input type="hidden" name="abstract" value="{abstract}"/></xsl:if>
				<input type="hidden" name="title" value="{title}"/>
				<input type="hidden" name="data" value="{data}"/>
				<!--<input type="hidden" name="tempdir" value="{tempdir}"/>-->

				<center>
					<input type="submit" name="edit" value="back to editing"/>
					<xsl:text> </xsl:text>
					<input type="submit" name="preview" value="preview"/>
				</center>

		</xsl:when>

		<!-- edit mode -->

		<xsl:otherwise>

				<!-- show feedback -->

				<xsl:if test="feedback/item">

					<font size="+1" color="#ff0000">
						<xsl:for-each select="feedback/item">
							<xsl:value-of select="."/> <br />
						</xsl:for-each>

					</font>

					<br />

				</xsl:if>

				<!-- editing form -->

				<table align="center">

				<tr><td>

				Title: <input type="text" name="title" value="{title}" size="60"/>
				<p />

				<xsl:if test="new=1">

					Comment (abstract, etc):

					<p />

					<textarea name="abstract" rows="5" cols="80">
						<xsl:value-of select="abstract"/>	
					</textarea>

					<p />
				</xsl:if>

				Document (compilable LaTeX, entire file):

				<p />

				<textarea name="data" rows="25" cols="80">
					<xsl:value-of select="data"/>
				</textarea>

				</td></tr></table>

				<p />
				
				<input type="hidden" name="tempdir" value="{tempdir}"/>

				<center>
					<input type="submit" name="preview" value="preview"/>
					<xsl:text> </xsl:text>
					<input type="submit" name="filebox" value="manage file box"/>
					<xsl:text> </xsl:text>
					<input type="submit" name="save" value="finish and save"/>
					<xsl:text> </xsl:text>
					<input type="submit" name="abort" value="abort"/>
				</center>


		</xsl:otherwise>

	</xsl:choose>
				
	<input type="hidden" name="op" value="edit"/>
	<input type="hidden" name="from" value="collab"/>
	<input type="hidden" name="version" value="{version}"/>
	<input type="hidden" name="id" value="{id}"/>
	<input type="hidden" name="new" value="{new}"/>

	</form>

	</td></tr></table>
			
	</xsl:with-param>
	</xsl:call-template>
	</xsl:with-param>
	</xsl:call-template>

</xsl:template>
