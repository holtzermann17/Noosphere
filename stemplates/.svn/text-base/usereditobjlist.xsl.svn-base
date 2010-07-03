<!-- this template handles the user object editor listing page -->

<xsl:template match="usereditobjs">
	
	<p />

	<center>

		<xsl:choose>

			<xsl:when test="@qtype = 'coauthor'">
				<a href="{/globals/main_url}/?op=edituserobjs&amp;qtype=own">objects you own</a> |
				<b>objects you coauthor</b> | 
				<a href="{/globals/main_url}/?op=edituserobjs&amp;qtype=world">world-editable objects</a>
			</xsl:when>

			<xsl:when test="@qtype = 'world'">
				<a href="{/globals/main_url}/?op=edituserobjs&amp;qtype=own">objects you own</a> |
				<a href="{/globals/main_url}/?op=edituserobjs&amp;qtype=coauthor">objects you coauthor</a> | 
				<b>world-editable objects</b>
			</xsl:when>

			<xsl:otherwise>
				<b>objects you own</b> |
				<a href="{/globals/main_url}/?op=edituserobjs&amp;qtype=coauthor">objects you coauthor</a> | 
				<a href="{/globals/main_url}/?op=edituserobjs&amp;qtype=world">world-editable objects</a>
			</xsl:otherwise>

		</xsl:choose>

	</center>


	<xsl:if test="object">
	
		<xsl:apply-templates select="//pager"/>
		<br />
	
		<table cellspacing="0" cellpadding="2" width="100%">
			<xsl:for-each select="object">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</table>

		<xsl:apply-templates select="//pager"/>
	</xsl:if>

	<xsl:if test="not(object)">
			  
		<p>Nothing to show.</p>

	</xsl:if>

</xsl:template>

<xsl:template match="object">

	<tr>
		<xsl:if test="@ord mod 2 = 1">
			<xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
		</xsl:if>

		<!-- title -->

		<td align="left" colspan="2">
	
		<a>
			<xsl:attribute name="href">
				<xsl:value-of select="@href"/>
			</xsl:attribute>
    
			<xsl:value-of select="@title"/>
		</a>

		</td>

		<!-- status indicators -->

		<td><font face="monospace, courier" size="-1">

        <xsl:if test="@unclassified or @hascorrections or @hasmessages">
	   		[ <b> 
			
			<xsl:if test="@unclassified"> 
				<a class="indicator" href="{//globals/main_url}/?op=help;key=indicator_u" target="pmhelp" onclick="window.open('/?op=help;key=indicator_u', 'pmhelp', 'width=300,height=120'); return false">u</a> 
			</xsl:if> 
			
			<xsl:if test="@hascorrections"> 
				<a class="indicator" href="{//globals/main_url}/?op=help;key=indicator_c" target="pmhelp" onclick="window.open('/?op=help;key=indicator_c', 'pmhelp', 'width=300,height=120'); return false">c</a> 
			</xsl:if> 
			
			<xsl:if test="@hasmessages"> 
				<a class="indicator" href="{//globals/main_url}/?op=help;key=indicator_m" target="pmhelp" onclick="window.open('/?op=help;key=indicator_m', 'pmhelp', 'width=300,height=120'); return false">m</a> 
			</xsl:if> 
			
			</b> ] 
		
		</xsl:if> 
		
		</font></td> 
		
		<!-- date -->

		<td valign="top" align="right">
	
			<xsl:value-of select="@date"/> 

		</td>
	</tr>

	<!-- the editing controls -->

	<tr>
		<xsl:if test="@ord mod 2 = 1">
			<xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
		</xsl:if>
	
		<td valign="top" align="left">
			<font size="-1">
			&#160;
			<xsl:choose>
				<xsl:when test="@table = 'lec'">
					<!-- (in&#160;<a href="{//globals/main_url}/?op=browse&amp;from=lec">Expositions</a>)-->
					(in&#160;Expositions)
				</xsl:when>
			  	<xsl:when test="@table = 'papers'">
					<!--(in&#160;<a href="{//globals/main_url}/?op=browse&amp;from=papers">Papers</a>)-->
					(in&#160;Papers)
				</xsl:when>
			  	<xsl:when test="@table = 'books'">
					<!--(in&#160;<a href="{//globals/main_url}/?op=browse&amp;from=books">Books</a>)-->
					(in&#160;Books)
				</xsl:when>
			  	<xsl:when test="@table = 'objects'">
					<!--(in&#160;<a href="/encyclopedia">Encyclopedia</a>)-->
					(in&#160;Encyclopedia)
				</xsl:when>
			  </xsl:choose>
			  </font>
		</td>

		<!-- editing controls -->

		<td align="right" colspan="3">

			<font size="-1">

			<a href="{@edithref}">edit</a>

			<!-- owner-specific item (note: this is flawed; really we should 
			be testing for the ACL "_acl" permission bit! -->

			<xsl:if test="@isowner = 1">
			
			| <a href="{@aclhref}">change access</a>

			</xsl:if>
			
			<!-- encyclopedia objects stuff -->

			<xsl:if test="@table = 'objects'">
				| <a href="{@linkhref}">linking policy</a>
				| <a href="{@historyhref}">history</a>
			</xsl:if>

			<!-- owner-exclusive stuff -->

			<xsl:if test="@isowner = 1">
			
				| <a href="{/globals/main_url}/?op=transfer&amp;from={@table}&amp;id={@id}">transfer</a>
				| <a href="{/globals/main_url}/?op=abandon&amp;from={@table}&amp;id={@id}&amp;ask=yes">abandon</a>
				| <a href="{/globals/main_url}/?op=delobj&amp;from={@table}&amp;id={@id}&amp;ask=yes">delete</a>
			</xsl:if>

			</font>
		</td>

	</tr>

	<!-- row to force 3 cells across -->
	<tr>
		<td></td>
		<td></td>
		<td></td>
	</tr>
	
</xsl:template>

