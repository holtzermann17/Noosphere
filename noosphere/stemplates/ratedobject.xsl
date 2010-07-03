<xsl:template match="ratedobject">

	<xsl:call-template name="paddingtable">
	<xsl:with-param name="content">

	<xsl:call-template name="makebox">
	<xsl:with-param name="title">Ratings Detail: <xsl:value-of select="title"/></xsl:with-param>
	<xsl:with-param name="content">

	<xsl:if test="karmainfo=1">
	<table>
		<tr>
			<td><font size="-1">Rated categories:  </font></td><td><font size="-1"><xsl:value-of select="rated"/></font></td>
		</tr>
		<tr>
			<td><font size="-1">Karma remaining: </font></td><td><font size="-1"><xsl:value-of select="karma"/></font></td>
		</tr>
	</table>
	</xsl:if>

	
		<table>
			<tr>
			<td colspan="2">
					Summary of current ratings for the object:
				</td>
			</tr>
			<tr>
				<td style="font-weight: bold;"><font size="-1">Clarity:</font></td>
				<td align="left"><font size="-1"><xsl:value-of select="q1_answer"/></font></td>
				<td align="left">
					<img>
						<xsl:attribute name="src">
							<xsl:value-of select="q1_image"/>
						</xsl:attribute>									
					</img>
				</td>
			 </tr><tr>
				<td style="font-weight: bold;"><font size="-1">Correctness:</font></td>
				<td align="left"><font size="-1"><xsl:value-of select="q2_answer"/></font></td>
				<td align="left">
					<img>
						<xsl:attribute name="src">
							<xsl:value-of select="q2_image"/>
						</xsl:attribute>									
					</img>
				</td>
			 </tr><tr>
				<td style="font-weight: bold;"><font size="-1">Pedagogy:</font></td>
				<td align="left"><font size="-1"><xsl:value-of select="q3_answer"/></font></td>
				<td align="left">
					<img>
						<xsl:attribute name="src">
							<xsl:value-of select="q3_image"/>
						</xsl:attribute>									
					</img>
				</td>
			 </tr><tr>
				<td style="font-weight: bold;"><font size="-1">Language:</font></td>
				<td align="left"><font size="-1"><xsl:value-of select="q4_answer"/></font></td>
				<td align="left">
					<img>
						<xsl:attribute name="src">
							<xsl:value-of select="q4_image"/>
						</xsl:attribute>									
					</img>
				</td>
			 </tr><tr>
				<td style="font-weight: bold;"><font size="-1">Average:</font></td>
				<td align="left"><font size="-1"><xsl:value-of select="avg"/></font></td>
				<td align="left">
					<img>
						<xsl:attribute name="src">
							<xsl:value-of select="avg_image"/>
						</xsl:attribute>									
					</img>
				</td>
			 </tr>
			 </table>
			 <table>
			 <tr>
				<td style="font-weight: bold;"><font size="-1">Number of votes counted (recent votes):</font></td>
				<td align="left"><font size="-1"><xsl:value-of select="recent"/></font></td>
			 </tr>
			 <tr>
			 	<td style="font-weight: bold;"><font size="-1">Number of votes counted (active votes):</font></td>
				<td align="left"><font size="-1"><xsl:value-of select="active"/></font></td>
			</tr>
			 <tr>
				<td style="font-weight: bold;"><font size="-1">All historical votes:</font></td>
				<td align="left"><font size="-1"><xsl:value-of select="all"/></font></td>			 
			</tr>
		</table>

		<a href="{//globals/main_url}/?op=getobj&amp;from=objects&amp;id={objectid}">Back to the object</a>
	
		<br/><br/>
		
		Detailed list of ratings:
		
		<table style="border-collapse: collapse; border-style: none;">
			<tr>
				<th style="font-weight: bold; border: 1px solid black; padding: 0 4 0 4;"><font size="-1">User</font></th>
				<th style="font-weight: bold; border: 1px solid black; padding: 0 4 0 4;"><font size="-1">Date</font></th>
				<th style="font-weight: bold; border: 1px solid black; padding: 0 4 0 4;"><font size="-1">Clarity</font></th>
				<th style="font-weight: bold; border: 1px solid black; padding: 0 4 0 4;"><font size="-1">Correctness</font></th>
				<th style="font-weight: bold; border: 1px solid black; padding: 0 4 0 4;"><font size="-1">Pedagogy</font></th>
				<th style="font-weight: bold; border: 1px solid black; padding: 0 4 0 4;"><font size="-1">Language</font></th>
				<th style="font-weight: bold; border: 1px solid black; padding: 0 4 0 4;"><font size="-1">Comment</font></th>
			</tr>
			<xsl:for-each select="details/rate">
				<tr>
					<td style="border: 1px solid black; padding: 0 4 0 4;"><font size="-1"><xsl:value-of select="user"/></font></td>
					<td style="border: 1px solid black; padding: 0 4 0 4;"><font size="-1"><xsl:value-of select="date"/></font></td>
					<td style="border: 1px solid black; padding: 0 4 0 4;" align="center"><font size="-1"><xsl:value-of select="a1"/></font></td>
					<td style="border: 1px solid black; padding: 0 4 0 4;" align="center"><font size="-1"><xsl:value-of select="a2"/></font></td>
					<td style="border: 1px solid black; padding: 0 4 0 4;" align="center"><font size="-1"><xsl:value-of select="a3"/></font></td>
					<td style="border: 1px solid black; padding: 0 4 0 4;" align="center"><font size="-1"><xsl:value-of select="a4"/></font></td>
					<td style="border: 1px solid black; padding: 0 4 0 4;"><font size="-1"><xsl:value-of select="comment"/></font></td>
				</tr>
			</xsl:for-each>
		</table>
	
		
		<a href="{//globals/main_url}/?op=getobj&amp;from=objects&amp;id={objectid}">Back to the object</a>
		
	</xsl:with-param>
	</xsl:call-template>
	</xsl:with-param>
	</xsl:call-template>

</xsl:template>
