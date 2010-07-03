<!-- for the encyclopedia entry version browser  -->

<xsl:template match="versionbrowser">
 
  <xsl:call-template name="paddingtable">
   <xsl:with-param name="content">
   
    <xsl:call-template name="clearbox">
        <xsl:with-param name="title">
		  Revision Browser : <xsl:value-of select="@title"/>

		</xsl:with-param>
        <xsl:with-param name="content">
		 
			<center>
			  [ <a>
			    <xsl:attribute name="href">
				  <xsl:value-of select="@href"/>
				</xsl:attribute>

				return to viewing '<xsl:value-of select="@title"/>'
			  </a> ]

			</center>

			<p/>
			
			<xsl:choose>
			 <xsl:when test="item">
			
              <xsl:for-each select="item">
				<table width="100%" cellpadding="4">
  
					<xsl:attribute name="bgcolor">
						<xsl:choose>
							<xsl:when test="series/@ord mod 2 = 1">
								#ffffff
							</xsl:when>
							<xsl:otherwise>
								#eeeeee
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

					<xsl:if test="//versionbrowser/@owner = 1">
						<td style="border-style: none solid none none; border-width: thin; border-color: #000000">
						<font size="-1">
						<a href="{rollback/@href}" title="Unapply changes since this reversion.  Doing this will make version {version/@name} the current version.">rollback</a>
						</font>
						</td>
					</xsl:if>

					<td style="border-style: none solid none none; border-width: thin; border-color: #000000">

					<!-- show diff, but only if there's a next version -->
					<xsl:choose>
						<xsl:when test="viewdiff or not(preceding-sibling::item)">
							<a href="{viewdiff/@href}" title="View the changes made in this revision.">diff</a>
						</xsl:when>
					</xsl:choose>

					</td>
   
					<td width="100%">

					<xsl:choose>
						<xsl:when test="string-length(timestamp) > 0">
							<xsl:value-of select="timestamp"/> 
						</xsl:when>
						<xsl:otherwise>(date unknown)</xsl:otherwise>
					</xsl:choose>
	
					- revision [
	
					<a href="{version/@href}">Version <xsl:value-of select="version/@name"/></a>
						<b> --&gt;  </b>
						
						<xsl:choose>
							<xsl:when test="preceding-sibling::item">
								<xsl:choose>
									<xsl:when test="nextver">
										<xsl:choose>
											<xsl:when test="nextver = 'current'">
												(current)
											</xsl:when>
											<xsl:otherwise>
												<a href="{nextver/@href}">Version <xsl:value-of select="nextver"/></a>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										(missing)
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								(current)
							</xsl:otherwise>
						</xsl:choose>
					
					]

					by 	

					<a href="{modifier/@href}">
						<xsl:value-of select="modifier/@name"/>
					</a>

					<br/>

					<xsl:if test="comment and normalize-space(comment) != ''">
	  
						<table align="right" cellpadding="0" cellspacing="0" width="95%">
							<td align="left">
				 				<xsl:call-template name="printcode">
									<xsl:with-param name="source">
										<xsl:value-of select="comment"/> 
									</xsl:with-param> 
								</xsl:call-template>
							</td>
						</table>
						<br/>
					</xsl:if>

					</td>
					</table>
				</xsl:for-each>

			 </xsl:when>

			 <xsl:otherwise>

               <center>
			   No history yet! Make some changes first.
			   </center>
			 </xsl:otherwise>
			</xsl:choose>
			
        </xsl:with-param>
    </xsl:call-template>  <!-- clearbox -->

   </xsl:with-param>
  </xsl:call-template>  <!-- paddingtable -->

</xsl:template>

