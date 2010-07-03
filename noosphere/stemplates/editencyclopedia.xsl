<xsl:template match="entry">

	<form method="post" action="{//globals/main_url}/" enctype="multipart/form-data" accept-charset="UTF-8">
	
		<font color="#ff0000" size="+1"><xsl:copy-of select="error"/></font>
		
		Type: <xsl:copy-of select="tbox"/>

		Title: <input type="text" name="title" value="{title}" size="30"/>
		
		<br /> <br />

		Attached to (if applicable): 
				<input type="text" name="parent" value="{parent}" size="30"/>
		
		<br />

		<font size="-2">(Use canonical name. Proofs, examples, corollaries, derivations, and results <b>must</b> be attached to a parent.)</font>

		<br />

		<xsl:if test="typeis='Theorem'">
		<br />
		
		Contains own proof:
				<xsl:element name="input">
					<xsl:attribute name="type">checkbox</xsl:attribute>
					<xsl:attribute name="name">self</xsl:attribute>
					
					<xsl:if test="self=1">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</xsl:element>
		<br />
		</xsl:if>

		<xsl:if test="//globals/classification_supported = 1">

			<br />

			Classification (See <a target="noosphere.popup" href="{//globals/main_url}/?op=mscbrowse">MSC</a>):

			<br />
		
				<input type="text" name="class" value="{class}" size="75"/>
		
			<br />

			<font size="-2">(examples: "msc:11F02", "msc:11F02, msc:11F03, msc:05R16". "msc:" can be ommitted, assumed by default.)</font>
		</xsl:if>

		<br /> <br />


		<!--====================-->
		<!-- ASSOCIATIONS TABLE -->
		<!--====================-->

		<table> <font face="sans-serif">

		<tr><td colspan="2" align="center">
			Associations (<a href="{//globals/main_url}/?op=assocguidelines">Guidelines</a>)
		</td></tr>		

		<tr>
			<td>Synonyms:</td>
			
			<td> 
				<input type="text" name="synonyms" value="{synonyms}" size="40"/>
			</td>
		</tr>

		<tr>
			<td>Defines:</td>
			
			<td> 
				<input type="text" name="defines" value="{defines}" size="40"/>
			</td>
		</tr>
		<tr>
			<td>Related:</td>
			
			<td> 
				<input type="text" name="related" value="{related}" size="40"/>
			</td>
		</tr>
		<tr>
			<td>Keywords:</td>
			
			<td> 
				<input type="text" name="keywords" value="{keywords}" size="40"/>
			</td>
		</tr>
		<tr>
			<td>Tags:</td>
			
			<td> 
				<input type="text" name="tags" value="{tags}" size="40"/>
			</td>
		</tr>

		</font> </table>
		
		<br />

		Pronunciation (<a href="{//globals/doc_url}/pronunciation.html">guide</a>):
			<input type="text" name="pronounce" value="{pronounce}" size="40"/>

		<br /> <br />

		<!--=========================-->
		<!-- preview (if we have one -->
		<!--=========================-->

		<xsl:if test="preview">

			Preview: 

			<xsl:copy-of select="showpreview" />

			<br /><br />

		</xsl:if>
			
		Preamble (new commands, nonstandard packages):

		<br />

		<table width="0" cellpadding="0" cellspacing="4">
		<tr> 
			<td>
				<textarea name="preamble" cols="60" rows="8"><xsl:value-of select="preamble"/></textarea>
			</td>

			<td valign="top">
				<input type="submit" name="getpre" value="get preamble" />
			</td>
		</tr>
		</table>

		<br />

		Revision comment:

		<br />

		<textarea name="revcomment" cols="60" rows="4"><xsl:value-of select="revcomment"/></textarea>

		<br /> <br />

		Content (edit your LaTeX here. See <a href="{//globals/main_url}/?op=getobj&amp;from=collab&amp;id=28">PlanetMath Content and Style Guide</a>
			, or <a href="http://aux.planetmath.org/doc/faq.html#r_tex" target="syntax_win">Syntax Help</a>
		):

		<br />

		<textarea name="data" cols="120" rows="30"><xsl:value-of select="data"/></textarea>

		<input type="hidden" name="id" value="{id}"/>
		<input type="hidden" name="op" value="{op}"/>
		<input type="hidden" name="version" value="{version}"/>
		<input type="hidden" name="table" value="objects"/>
		<input type="hidden" name="from" value="objects"/>

		<center>
			<br />
			<input TYPE="submit" name="preview" VALUE="preview" /> 
			<xsl:text> </xsl:text>
			<input TYPE="submit" name="post" VALUE="save changes" />
			<br /><br />
		</center>
		
	<!--=====================-->
	<!-- corrections manager -->
	<!--=====================-->

	<xsl:if test="corrections">
	
		<xsl:copy-of select="corrections"/>

	</xsl:if>

	<!--==============-->
	<!-- file manager -->
	<!--==============-->

	<xsl:if test="fmanager">
	
		<xsl:copy-of select="fmanager"/>

	</xsl:if>

	</form>

</xsl:template>
