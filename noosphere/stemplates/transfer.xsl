<xsl:template match="transfer">

	<xsl:call-template name="paddingtable">
		<xsl:with-param name="content">
		
			<xsl:call-template name="makebox">
				<xsl:with-param name="title">Transfer Object to Whom?</xsl:with-param>
				<xsl:with-param name="content">

					<table width="100%" cellpadding="4"><tr><td>

					Who would you like to transfer '<xsl:value-of select="title"/>' to?

					<xsl:choose>
						<xsl:when test="authorlist">
							Below, you can select from a list of users who have edited the object, or simply enter in a user name or numeric ID in the box.
						</xsl:when>

						<xsl:otherwise>
							Below, please enter in the user's name or numeric ID.
						</xsl:otherwise>
					</xsl:choose>

					<p />

					<table align="center"><tr><td>
					
					<form method="post" name="touserform" action="{//globals/main_url}">	
					
						<xsl:if test="authorlist">

							Select from this entry's authors: 

							<select name="whocares" onChange="document.touserform.touser.value=this.value;">
								<xsl:for-each select="authorlist/author">
									<option value="{name}"><xsl:value-of select="name"/></option>
								</xsl:for-each>
							</select>

							<p />
						
						</xsl:if>
					
						Transfer to user: <input type="text" name="touser" size="20"/>

						<p />

						<input type="hidden" name="op" value="sendobj"/>
						<input type="hidden" name="from" value="{from}"/>
						<input type="hidden" name="id" value="{id}"/>

						<center>
						
							<input type="submit" name="transfer" value="transfer"/>
						</center>

					</form>

					</td></tr></table>

					<p />

					<center>
						<i>Note: this transfer is only a <b>request</b>, which can be refused by the recipient.</i>
					</center>
					
					</td></tr></table>

				</xsl:with-param>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
