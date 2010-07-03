
<xsl:template match="linkpolicy">

	<xsl:call-template name="paddingtable">
		<xsl:with-param name="content">
			
		<xsl:call-template name="makebox">
				<xsl:with-param name="title">Editing Linking Policy For '<xsl:value-of select="@title"/>'</xsl:with-param>
		
				<xsl:with-param name="content">

				<table width="100%" cellpadding="5">

				<tr><td>

					<form action="{//globals/main_url}/" method="POST">
		
						<p>
						Enter in a linking policy below:
						</p>


						<p>
						<textarea name="policy" rows="6" cols="80"><xsl:value-of select="policy"/></textarea>
						</p>

						<center>
							<input type="submit" name="submit" value="update"/>
						</center>

						<p> 
							Linking policy is used to help resolve automatic links in ambiguous situations.  The policy is composed of directives, which should be entered one per line. </p>

						<p>
							Currently-supported linking directives:
						</p>
							
						<p>
						
							<ul>
							
								<li><font class="code">priority &lt;N&gt; [LABEL]</font>
								
								<p>
								where &lt;N&gt; is a number and [LABEL] is an optional concept label defined by the entry.  The default priority is 100, and integer values from 0 to 32767 are accepted.  Smaller numbers mean <i>higher</i> priority.  Examples: </p>
								
								<p>
								<font class="code">
									priority 10 normal<br />
									priority 200 "mapping function"
								</font>
								</p>

								<p>
								This directive is used as a <b>tie-breaker</b> when classification directives and category-based link steering fail to find a unique destination.  Setting the priority higher than normal (closer to zero) results in an entry (or concept) being linked to "by default".  Setting it lower (above 100) would result in the entry or concept being linked to automatically only when the categorization of the other entry overlaps.
								</p>
								
								</li>
								
								<li>
								<font class="code">permit &lt;CATEGORY_MASK&gt; [LABEL]</font>
								
								<p>
   								Where CATEGORY_MASK is an MSC category or root of category, e.g., 03F15, 03F, 03.  LABEL 
   								is an optional concept label defined by the entry.  If LABEL is
   								absent, "Permit" is applied to <i>all</i> of the concept labels of the
   								entry.
								</p>

								<p>
   								This directive allows linking for the given LABELs to <i>only</i> the
  								 categories indicated by CATEGORY_MASK.  This has the semantics of a
   								linking "whitelist".
   								</p>

								<p>
								To do a permit for more than one CATEGORY_MASK, list multiple directives on separate lines.
								</p>
								</li>
								
								<li>
								<font class="code">forbid &lt;CATEGORY_MASK&gt; [LABEL]</font>

								<p>								
  								 This directive has the opposite semantics as the above; it will allow
   									linking of the given LABELs to all categories <i>except</i> ones which match
 								  CATEGORY_MASK.  Thus, this is a akin to a linking "blacklist".
								</p>								

								<p>
								NOTE: If Both "permit" and "forbid" directives are present, the permit will take precedence.
								</p>
								</li>



							</ul>

						</p>

						<input type="hidden" name="op" value="linkpolicy"/>
						<input type="hidden" name="id" value="{id}"/>

					</form>


				</td></tr>

				</table>

				</xsl:with-param>

		</xsl:call-template>

		</xsl:with-param>
		
	</xsl:call-template>

	
</xsl:template>
