<!-- a generic printing-out-linear-list-with-paging template -->

<xsl:template match="userobjs">

    <xsl:call-template name="clearbox">
        <xsl:with-param name="title">User Objects</xsl:with-param>
        <xsl:with-param name="content">
			
		  <xsl:choose>
		    <xsl:when test="item_userobjs">
			
			  <xsl:apply-templates select="//pager"/>
			  <br />

			  <table cellspacing="0" cellpadding="2" width="100%">
              <xsl:for-each select="item_userobjs">
                <xsl:apply-templates select="."/>
              </xsl:for-each>
			  </table>
			  
			</xsl:when>
			<xsl:otherwise>
			   <p>
			    Nothing to show.
			   </p>
			</xsl:otherwise>
		  </xsl:choose>
			
        </xsl:with-param>
    </xsl:call-template>

</xsl:template>

<xsl:template match="item_userobjs">

	<tr>
		<xsl:if test="series/@ord mod 2 = 1">
			<xsl:attribute name="bgcolor">#eeeeee</xsl:attribute>
		</xsl:if>

	<td>
	<xsl:value-of select="series/@ord"/>.

	<xsl:value-of select="object/@date"/> 

	<!-- what the hell? if we put nothing here we get no space, -->
	<!-- if we put a non-breakable space we get two spaces! -->
    &#160;

	<a>
      <xsl:attribute name="href">
	   <xsl:value-of select="object/@href"/>
	  </xsl:attribute>
    
	  <xsl:value-of select="object/@title"/>
	</a>
	</td>

	<td valign="top">
		<font size="-1">
		<xsl:choose>
			<xsl:when test="object/@table = 'lec'">
				(from&#160;<a href="{//globals/main_url}/?op=browse&amp;from=lec">Expositions</a>)
			</xsl:when>
		  	<xsl:when test="object/@table = 'papers'">
				(from&#160;<a href="{//globals/main_url}/?op=browse&amp;from=papers">Papers</a>)
			</xsl:when>
		  	<xsl:when test="object/@table = 'books'">
				(from&#160;<a href="{//globals/main_url}/?op=browse&amp;from=books">Books</a>)
			</xsl:when>
		  	<xsl:when test="object/@table = 'objects'">
				(from&#160;<a href="/encyclopedia">Encyclopedia</a>)
			</xsl:when>
		  </xsl:choose>
		  </font>
	</td>

	</tr>
	
</xsl:template>

<xsl:template match="usermsgs">

    <xsl:call-template name="clearbox">
        <xsl:with-param name="title">User Messages</xsl:with-param>
        <xsl:with-param name="content">
			
		  <xsl:choose>
		    <xsl:when test="item_usermsgs">
			  <xsl:apply-templates select="//pager"/>
			  <br />
              <xsl:for-each select="item_usermsgs">
                <xsl:apply-templates select="."/>
              </xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
			   <p>
			    Nothing to show.
			   </p>
			</xsl:otherwise>
		  </xsl:choose>
			
        </xsl:with-param>
    </xsl:call-template>

</xsl:template>

<xsl:template match="item_usermsgs">
	<xsl:value-of select="series/@ord"/>.

	<xsl:value-of select="message/@date"/>
	
	<!-- ugly hack! -->
	<font color="#ffffff">.</font>
	
    <a>
      <xsl:attribute name="href">
	   <xsl:value-of select="message/@href"/>
	  </xsl:attribute>
    
	  <xsl:value-of select="message/@title"/>
	</a>

	posted to

    <a>
      <xsl:attribute name="href">
	   <xsl:value-of select="object/@href"/>
	  </xsl:attribute>
    
	  <xsl:value-of select="object/@title"/>
	</a>

    <br/>
	
</xsl:template>

<xsl:template match="usercorsf">

    <xsl:call-template name="clearbox">
        <xsl:with-param name="title">User Corrections Filed</xsl:with-param>
        <xsl:with-param name="content">
			
		  <xsl:choose>
		    <xsl:when test="item_usercorsf">
			  <xsl:apply-templates select="//pager"/>
			  <br />
			  <xsl:for-each select="item_usercorsf">
                <xsl:apply-templates select="."/>
              </xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
			   <p>
			    Nothing to show.
			   </p>
			</xsl:otherwise>
		  </xsl:choose>
			
        </xsl:with-param>
    </xsl:call-template>

</xsl:template>

<xsl:template match="item_usercorsf">
	<xsl:value-of select="series/@ord"/>.

	<xsl:value-of select="correction/@date"/>
	
	<!-- ugly hack! -->
	<font color="#ffffff">.</font>
	
    <a>
      <xsl:attribute name="href">
	   <xsl:value-of select="correction/@href"/>
	  </xsl:attribute>
    
	  <xsl:value-of select="correction/@title"/>
	</a>

	filed for

    <a>
      <xsl:attribute name="href">
	   <xsl:value-of select="object/@href"/>
	  </xsl:attribute>
    
	  <xsl:value-of select="object/@title"/>
	</a>

    <br/>
	
</xsl:template>

<xsl:template match="usercorsr">

    <xsl:call-template name="clearbox">
        <xsl:with-param name="title">User Corrections Received</xsl:with-param>
        <xsl:with-param name="content">
			
		  <xsl:choose>
		    <xsl:when test="item_usercorsr">
			  <xsl:apply-templates select="//pager"/>
			  <br />
              <xsl:for-each select="item_usercorsr">
                <xsl:apply-templates select="."/>
              </xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
			   <p>
			    Nothing to show.
			   </p>
			</xsl:otherwise>
		  </xsl:choose>
			
        </xsl:with-param>
    </xsl:call-template>

</xsl:template>

<xsl:template match="item_usercorsr">
	<xsl:value-of select="series/@ord"/>.

	<xsl:value-of select="correction/@date"/>
	
	<!-- ugly hack! -->
	<font color="#ffffff">.</font>
	
    <a>
      <xsl:attribute name="href">
	   <xsl:value-of select="correction/@href"/>
	  </xsl:attribute>
    
	  <xsl:value-of select="correction/@title"/>
	</a>

    by 

    <a>
      <xsl:attribute name="href">
	   <xsl:value-of select="user/@href"/>
	  </xsl:attribute>
    
	  <xsl:value-of select="user/@name"/>
	</a>

	received for 

    <a>
      <xsl:attribute name="href">
	   <xsl:value-of select="object/@href"/>
	  </xsl:attribute>
    
	  <xsl:value-of select="object/@title"/>
	</a>

    <br/>
	
</xsl:template>


