<xsl:template match="entry">

	Notes and caveats for adding encyclopedia entries:

	<p />

	<ul>
	  <li><b>Please search for your topic before you attempt to add!</b>.  You <b>can</b> write alternate entries, however, <a href="http://planetmath.org/?op=getobj&amp;from=collab&amp;id=36#alternate">if justified</a>. </li>
	  <li>Check the requests list (or the pulldown below). Your entry may fulfill a request.</li>
	  <li>You can use TeX-style international trigraphs (i.e., <b>\&quot;o</b> to make <b>&#x00F6;</b>) in your entry <b>and</b> its <a href="http://planetmath.org/?op=getobj&amp;from=collab&amp;id=36#metadata">metadata</a>.</li>
	  <li>Please see an <a href="http://planetmath.org/?op=getobj&amp;from=collab&amp;id=36#mathworld">important notice</a> about using MathWorld.</li>
	</ul>
	
	<b>A final note</b>: Abuse of this system (such as spamming or obscenity) will be taken <b>very seriously</b>.   We will not hesitate to take disciplinary, legal, and financial actions against perpetrators.  We <i>will</i> track down those who are malicious.  Have a nice day!

	<hr />


    <p />

	<form method="post" action="{//globals/main_url}/" enctype="multipart/form-data" accept-charset="UTF-8">

		<font color="#ff0000" size="+1"><xsl:copy-of select="error"/></font>
		
		Type: <xsl:copy-of select="tbox"/>

		Title: <xsl:element name="input">
					<xsl:attribute name="type">text</xsl:attribute>
					<xsl:attribute name="name">title</xsl:attribute>
					<xsl:attribute name="value"><xsl:value-of select="title"/></xsl:attribute>
					<xsl:attribute name="size">50</xsl:attribute>
				</xsl:element>

		<br />
		<font size="-2">(Try to write titles as they would occur naturally in text.  Commas are for index terms, to pass them verbatim write ",,")</font>
		
		<br /> <br />

		Attached to (if applicable): 
				<xsl:element name="input">
					<xsl:attribute name="type">text</xsl:attribute>
					<xsl:attribute name="name">parent</xsl:attribute>
					<xsl:attribute name="value"><xsl:value-of select="parent"/></xsl:attribute>
					<xsl:attribute name="size">30</xsl:attribute>
				</xsl:element>
		
		<br />

		<font size="-2">(Proofs, examples, corollaries, derivations, and results <b>must</b> be attached to a parent.)</font>

		<br />

		<br />
		
		Contains own proof (for theorems):
				<xsl:element name="input">
					<xsl:attribute name="type">checkbox</xsl:attribute>
					<xsl:attribute name="name">self</xsl:attribute>
					
					<xsl:if test="self='on'">
						<xsl:attribute name="checked">checked</xsl:attribute>
					</xsl:if>
				</xsl:element>
		<br />

		<br />

		Fill a request with this entry: <xsl:copy-of select="fillreq" />

		<xsl:if test="//globals/classification_supported = 1">
			<br /> <br />

			Classification (See <a target="planetmath.popup" href="{//globals/main_url}/?op=mscbrowse">MSC</a>):

			<br />
		
				<xsl:element name="input">
					<xsl:attribute name="type">text</xsl:attribute>
					<xsl:attribute name="name">class</xsl:attribute>
					<xsl:attribute name="value"><xsl:value-of select="class"/></xsl:attribute>
					<xsl:attribute name="size">75</xsl:attribute>
				</xsl:element>
		
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
				<xsl:element name="input">
					<xsl:attribute name="type">text</xsl:attribute>
					<xsl:attribute name="name">synonyms</xsl:attribute>
					<xsl:attribute name="value"><xsl:value-of select="synonyms"/></xsl:attribute>
					<xsl:attribute name="size">40</xsl:attribute>
				</xsl:element>
			</td>
		</tr>

		<tr>
			<td>Defines:</td>
			
			<td> 
				<xsl:element name="input">
					<xsl:attribute name="type">text</xsl:attribute>
					<xsl:attribute name="name">defines</xsl:attribute>
					<xsl:attribute name="value"><xsl:value-of select="defines"/></xsl:attribute>
					<xsl:attribute name="size">40</xsl:attribute>
				</xsl:element>
			</td>
		</tr>
		<tr>
			<td>Related*:</td>
			
			<td> 
				<xsl:element name="input">
					<xsl:attribute name="type">text</xsl:attribute>
					<xsl:attribute name="name">related</xsl:attribute>
					<xsl:attribute name="value"><xsl:value-of select="related"/></xsl:attribute>
					<xsl:attribute name="size">40</xsl:attribute>
				</xsl:element>
			</td>
		</tr>
		<tr>
			<td>Keywords:</td>
			
			<td> 
				<xsl:element name="input">
					<xsl:attribute name="type">text</xsl:attribute>
					<xsl:attribute name="name">keywords</xsl:attribute>
					<xsl:attribute name="value"><xsl:value-of select="keywords"/></xsl:attribute>
					<xsl:attribute name="size">40</xsl:attribute>
				</xsl:element>
			</td>
		</tr>
		<tr>
		  <td colspan="2" align="right">
		    * <font size="-2">Canonical names only! (I.e. "PascalsRule" instead of "Pascal's Rule")</font>.
		  </td>
		</tr>

		</font> </table>
		
		<br />

		Pronunciation (<a>
			<xsl:attribute name="href"><xsl:value-of select="//globals/doc_url"/>/pronunciation.html</xsl:attribute>guide</a>): 
			<xsl:element name="input">
				<xsl:attribute name="type">text</xsl:attribute>
				<xsl:attribute name="name">pronounce</xsl:attribute>
				<xsl:attribute name="value"><xsl:value-of select="pronounce"/></xsl:attribute>
				<xsl:attribute name="size">40</xsl:attribute>
			</xsl:element>

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

		Content (edit your LaTeX here. See <a href="{//globals/main_url}/?op=getobj&amp;from=collab&amp;id=28">PlanetMath Content and Style Guide</a>
			, or <a href="http://planetmath.org/?op=getobj&amp;from=collab&amp;id=35#r_tex" target="syntax_win">Syntax Help</a>
		):

		<br />

		<textarea name="data" cols="120" rows="30"><xsl:value-of select="data"/></textarea>

		<input type="hidden" name="id" value="{id}"/>
		<input type="hidden" name="op" value="{op}"/>
		<input type="hidden" name="version" value="0"/>
		<input type="hidden" name="table" value="objects"/>
		<input type="hidden" name="from" value="objects"/>

		<center>
			<br />
			<input TYPE="submit" name="preview" VALUE="preview" /> 
			<xsl:if test="preview">
				<input TYPE="submit" name="post" VALUE="save changes" />
			</xsl:if>
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
