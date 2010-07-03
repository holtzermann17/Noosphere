<xsl:template match="frontpage">

	<!-- box for news, PlanetMath "about" blurb -->

	<xsl:call-template name="clearbox">
		<xsl:with-param name="title">Welcome!</xsl:with-param>
		<xsl:with-param name="content">

			<table width="100%">
			<tr><td>
				<table width="100%" cellpadding="0" cellspacing="3">
					<tr><td valign="top"> 
					
						<!-- floating news table -->
						
						<table class="newsbox" align="right" width="30%">
							<tr><td align="center">
							
							<b><font size="-2">News</font></b>
							
							</td></tr> 
							
							<tr><td> 
							
								<font size="-2"> 
								
									<xsl:for-each select="news/item">
										<p class="newstitle">
										<xsl:choose>
											<xsl:when test="position()=1">
												<b><a href="{href}"><xsl:value-of select="title"/></a></b> on 
											</xsl:when>
											<xsl:otherwise>
												<a href="{href}"><xsl:value-of select="title"/></a> on 
											</xsl:otherwise>
										</xsl:choose>
										<xsl:value-of select="date"/>
										</p> 

									</xsl:for-each>
									
           						</font> 
								
								<font size="-2"> 
								
									<div align="right"> 
									<a href="{//globals/main_url}/?op=oldnews">more...</a>&nbsp; 
									</div> 
								</font>
							</td></tr>
						</table>

   						<!-- about pm -->

						PlanetMath is a virtual community which aims to help make mathematical knowledge more accessible.  PlanetMath's content is created collaboratively: the main feature is the <a href="/encyclopedia">mathematics encyclopedia</a> with entries written and reviewed by members.   The entries are contributed under the terms of the <a href="{//globals/main_url}/?op=license">GNU Free Documentation License</a> (FDL) in order to preserve the rights of both the authors and readers in a sensible way.

						<p>
						
						PlanetMath entries are written in <a href="http://www.latex-project.org/">LaTeX</a>, the <i>lingua franca</i> of the worldwide mathematics community.  All of the entries are automatically cross-referenced with each other, and the entire corpus is kept updated in real-time.

						</p>

						<!--
						<table width="60%" bgcolor="#ffaaaa" align="center">
						<tr>
							<td>
						[ <b>Alert!</b> - (alert message can go here)
							</td>
						</tr>
						</table>
						-->
						
		
   
						<p> 
						
						In addition to the mathematics encyclopedia, there are <a href="{//globals/main_url}/?op=browse&amp;from=books">books</a>, <a href="{//globals/main_url}/?op=browse&amp;from=lec">expositions</a>, <a href="{//globals/main_url}/?op=browse&amp;from=papers">papers</a>, and <a href="{//globals/main_url}/?op=forums">forums</a>.  You also might want to check out encyclopedia <a href="{//globals/main_url}/?op=reqlist">requests</a> if you'd like to see something we don't have.  We also have the encyclopedia available in offline-browsable <a href="{//globals/static_site}/snapshots/">snapshot form</a>, and in <a href="{//globals/static_site}/book/">book form</a>.   Also see PlanetMath-exclusive <a href="{//globals/main_url}/?filters.type=9&amp;op=enlist&amp;mode=created">feature articles</a> and <a href="{//globals/main_url}/?filters.type=0&amp;op=enlist&amp;mode=created">topics</a>.
						</p>
						
						<p align="center">
						<b>Top starting points:</b>&nbsp;

							<a href="{//globals/main_url}/encyclopedia/OverviewOfTheContentOfPlanetMath.html">PlanetMath Overview </a> -

							<a href="{//globals/main_url}/encyclopedia/HighschoolMathematics.html">High School Mathematics</a> - 
							
							<a href="{//globals/main_url}/encyclopedia/TopicsOnCalculus.html">Calculus</a> - 

							<a href="{//globals/main_url}/encyclopedia/StatisticsOnPlanetMath.html">Statistics</a> - 

							<a href="{//globals/main_url}/encyclopedia/TopicEntryOnRealNumbers.html">Real Numbers</a> -
							
							<a href="{//globals/main_url}/?filters.type=0&amp;op=enlist&amp;mode=hits">(more)</a>
						</p>

						
						<p>
						
						Accounts are free and required to do anything other than browse, so <a href="{//globals/main_url}/?op=newuser">sign up</a>! It only takes a minute.

						For more information, see the <a href="{//globals/main_url}/?op=getobj&amp;from=collab&amp;id=35">FAQ</a>, other <a href="{//globals/main_url}/?op=sitedoc">documentation</a>, <a href="http://planetx.cc.vt.edu/AsteroidMeta/PlanetMath_Mailing_Lists_and_other_Contact_Information">PlanetMath mailing lists and other public fora</a>, or <a href="http://scholar.lib.vt.edu/theses/available/etd-09022003-150851/">``the PlanetMath thesis''</a>.  
						</p>

						<p align="center"><b>Also visit:</b>&nbsp; <a href="http://planetphysics.org/">PlanetPhysics</a>, PlanetComputing<b>*</b>. 
						And please don't forget to <b><a href="{//globals/doc_url}/donate.html">Help Support PlanetMath!</a></b>
						</p>
						
						<p>
						<font size="-1">
						<b>*</b>Coming soon. Shameless plugs: PlanetMath runs <a href="http://aux.planetmath.org/noosphere">Noosphere</a>.  We recommend viewing this site with <a href="http://www.mozilla.org/products/firefox/">Mozilla Firefox</a> and derivatives.
						</font>

						</p>

		
					</td></tr>
				</table> 
				
			</td></tr>
			</table> 
		</xsl:with-param>
	</xsl:call-template>

	<!-- messages -->

	<xsl:call-template name="clearbox">

		<xsl:with-param name="title">Latest Messages</xsl:with-param>

		<xsl:with-param name="content">
		
			<xsl:for-each select="messages/message">

				<xsl:value-of select="date"/> - 

				<a href="{ohref}" title="go to the parent object or forum containing this message"><img alt="parent" src="{//globals/image_url}/object.png" border="0"/></a>
				<xsl:text> </xsl:text>

				<xsl:if test="href != thref">
					<a href="{thref}" title="go to the top of the thread containing this message"><img alt="thread top" src="{//globals/image_url}/uparrow.png" border="0"/></a>
					<xsl:text> </xsl:text>
				</xsl:if>

				<a href="{href}"><xsl:value-of select="title"/></a> 
				by 
				<a href="{uhref}"><xsl:value-of select="username"/></a> 
				
				<br/>

			</xsl:for-each>

			<p/> 

			<center>
				<a href="{//globals/main_url}/?op=messageschrono">(see more)</a>
			</center>

		</xsl:with-param>

	</xsl:call-template>

</xsl:template>
