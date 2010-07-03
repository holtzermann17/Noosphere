<xsl:template match="entries">

	<xsl:call-template name="paddingtable">
		<xsl:with-param name="content">

	<xsl:call-template name="clearbox">

		<xsl:with-param name="title">
			<xsl:if test="not(filters/@current)">
				All 
			</xsl:if>
			Encyclopedia Entries, Ordered by  <b>
			<xsl:if test="@mode = 'hits'">Popularity (Hits)</xsl:if>
			<xsl:if test="@mode = 'inlinks'">Number of In-Links</xsl:if>
			<xsl:if test="@mode = 'created'">Creation Date</xsl:if>
			<xsl:if test="@mode = 'modified'">Last Revision Date</xsl:if>
			</b>

			<xsl:if test="filters/@current">
				, filtered by <b><xsl:value-of select="filters/@current_readable"/></b>
			</xsl:if>
		</xsl:with-param>

		<xsl:with-param name="content">
		
			<!-- sort control -->
			
			<p align="center">

			<i>re-sort by: </i>

			<xsl:choose>
				<xsl:when test="@mode = 'hits'">
					popularity
				</xsl:when>
				<xsl:otherwise>
					<a>
						<xsl:if test="filters/@current">
							<xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=enlist&amp;mode=hits&amp;<xsl:value-of select="filters/@current"/></xsl:attribute>
						</xsl:if>
						<xsl:if test="not(filters/@current)">
							<xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=enlist&amp;mode=hits</xsl:attribute>
						</xsl:if>
					popularity</a>	
				</xsl:otherwise>
			</xsl:choose>
			|
			<xsl:choose>
				<xsl:when test="@mode = 'inlinks'">
					in-links	
				</xsl:when>
				<xsl:otherwise>
					<a>
						<xsl:if test="filters/@current">
							<xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=enlist&amp;mode=inlinks&amp;<xsl:value-of select="filters/@current"/></xsl:attribute>
						</xsl:if>
						<xsl:if test="not(filters/@current)">
							<xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=enlist&amp;mode=inlinks</xsl:attribute>
						</xsl:if>
					in-links</a>	
				</xsl:otherwise>
			</xsl:choose>
			|
			<xsl:choose>
				<xsl:when test="@mode = 'modified'">
					last revision date	
				</xsl:when>
				<xsl:otherwise>
					<a>
						<xsl:if test="filters/@current">
							<xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=enlist&amp;mode=modified&amp;<xsl:value-of select="filters/@current"/></xsl:attribute>
						</xsl:if>
						<xsl:if test="not(filters/@current)">
							<xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=enlist&amp;mode=modified</xsl:attribute>
						</xsl:if>
					
					last revision date</a>	
				</xsl:otherwise>
			</xsl:choose>
			|
			<xsl:choose>
				<xsl:when test="@mode = 'created'">
					creation date
				</xsl:when>
				<xsl:otherwise>
					<a>
						<xsl:if test="filters/@current">
							<xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=enlist&amp;mode=created&amp;<xsl:value-of select="filters/@current"/></xsl:attribute>
						</xsl:if>
						<xsl:if test="not(filters/@current)">
							<xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=enlist&amp;mode=created</xsl:attribute>
						</xsl:if>
					
					creation date</a>	
				</xsl:otherwise>
			</xsl:choose>

			</p>

			<!-- if filters are defined, allow user to narrow based on them. -->

			<xsl:if test="filters">
				<table align="center" cellpadding="0" cellspacing="4">
				<tr>
					<td valign="top">
						<i>filter by: </i> 

						<xsl:text> </xsl:text>
					</td>

					<td valign="top">
				
						<form method="get" action="{//globals/main_url}">  
							<xsl:for-each select="filters/filter">
								<xsl:value-of select="@attribute"/>
									
								<xsl:text> </xsl:text>

								<select name="filters.{@attribute}" class="small">
									<option value="null">
										<xsl:if test="not(@selected)">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										[none selected]
									</option>

									<xsl:for-each select="option">

										<option value="{@code}">
											<xsl:if test="@selected">
												<xsl:attribute name="selected">selected</xsl:attribute>
											</xsl:if>

											<xsl:value-of select="@name"/>
										</option>
									</xsl:for-each>
								</select>
							</xsl:for-each>

							<xsl:text> </xsl:text>

							<input type="submit" value="go" class="small"/>
							<input type="hidden" name="op" value="enlist"/>
							<input type="hidden" name="mode" value="{@mode}"/>
						</form>
					</td>
				</tr>
				</table>
			</xsl:if>

			<!-- list of entries -->

			<xsl:for-each select="entry">

				<xsl:if test="../@mode = 'created'"><xsl:value-of select="cdate"/></xsl:if>
				<xsl:if test="../@mode = 'modified'"><xsl:value-of select="mdate"/></xsl:if> 
				<xsl:if test="../@mode = 'hits'"><xsl:value-of select="hits"/></xsl:if> 
				<xsl:if test="../@mode = 'inlinks'"><xsl:value-of select="inlinks"/></xsl:if> 
				
				- 

				<a href="{href}"><xsl:apply-templates select="title/mathytitle"/></a>
				
				<font size="-1">
					owned by 
					<a href="{uhref}"><xsl:value-of select="username"/></a> 
				</font>
				
				<br/>

			</xsl:for-each>
		
		</xsl:with-param>

	</xsl:call-template>  <!-- clearbox -->
	
	</xsl:with-param>
	</xsl:call-template>  <!-- paddingtable -->

</xsl:template>
