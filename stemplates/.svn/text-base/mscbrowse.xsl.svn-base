<xsl:template match="mscset">
    <xsl:call-template name="clearbox">
        <xsl:with-param name="title">
		 	<xsl:choose>
				<xsl:when test="tdesc">
					<xsl:value-of select="tdesc"/> by subject
				</xsl:when>
				<xsl:otherwise>
					Browsing MSC
				</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
        <xsl:with-param name="content">

			<!-- search box if we are browsing categories only -->

			<xsl:if test="not(tdesc)"> 
				<table align="center" border="0"><td>
				<form method="get" action="{//globals/main_url}/">
					<input type="hidden" name="op" value="mscsearch"/>
					<input type="text" name="mscterm" value=""/>
					<input type="submit" value="search"/>
					<input type="checkbox" name="leaves" checked="1" /> leaves only
					<br />
					<font size="-2">(Case insensitive substrings, use '-' to exclude)</font>
				</form>
				</td></table>
			</xsl:if>

            <p>

			<!-- print header -->

            <font size="+1">
            <xsl:choose>
                <xsl:when test="parent">
                    <xsl:value-of select="parent/id"/> - <xsl:value-of select="parent/desc"/>
                </xsl:when>
                <xsl:otherwise>Top Level Categories</xsl:otherwise>
            </xsl:choose>
         </font>
            </p>

			<!-- browse content pane -->

            <table border="0" width="100%">

				<!-- display MSC node content -->

                <xsl:if test="mscnode">
                    <xsl:for-each select="mscnode">
                        <tr valign="top">
                            <xsl:apply-templates select="."/>
                        </tr>
                    </xsl:for-each>

                </xsl:if>

				<!-- display MSC leaf content -->

                <xsl:if test="mscleaf">
                    <tr>
                        <td>
                            <ol>
                                <xsl:for-each select="mscleaf">
                                    <li><xsl:apply-templates select="."/></li>
                                </xsl:for-each>
                            </ol>
                        </td>
                    </tr>
					
                </xsl:if>

			<!-- if we are browsing objects, give option to see empty cats -->

			<xsl:if test='tdesc'> 
				<tr><td colspan="6">

				<br />
				<form method="get" name="browseopts" action="{//globals/main_url}/">
					Show empty categories: 
					
					<xsl:if test="tdesc/@showempty = 1">
						<input type="checkbox" onchange="browseopts.submit()" name="showempty" checked="checked"/> 
					</xsl:if>
					<xsl:if test="tdesc/@showempty = 0">
						<input type="checkbox" onchange="browseopts.submit()" name="showempty"/> 
					</xsl:if>

					<xsl:text> </xsl:text>
					<input type="submit" value="reload" class="small" />

					<input type="hidden" name="op" value="mscbrowse" /> 
					<input type="hidden" name="from" value="{tdesc/@domain}" /> 
					<xsl:if test="parent">
						<input type="hidden" name="id" value="{parent/id}" /> 
					</xsl:if>
				</form>
				</td></tr>
			</xsl:if>
			

				<!-- navigation buttons -->
				
				<tr>
					<td align="center" colspan="6">
						[ 
							
							<xsl:if test="parent">
								
								<a>
									<xsl:attribute name="href"><xsl:value-of select="parent/@href"/></xsl:attribute>up</a>
										
									|
                   			</xsl:if>
									
							<a>

                				<xsl:if test="mscleaf">
									<xsl:attribute name="href">/browse/<xsl:value-of select="mscleaf[1]/domain"/>/</xsl:attribute>top</xsl:if>

                				<xsl:if test="mscnode">
									<xsl:attribute name="href">/browse/<xsl:value-of select="mscnode[1]/domain"/>/</xsl:attribute>top</xsl:if>

							</a>
								
						] 
					</td>
				</tr>

            </table>
        </xsl:with-param>
    </xsl:call-template>
</xsl:template>

<!--============== -->
<!-- node template -->
<!--============== -->

<xsl:template match="mscnode">
    <td>
        <font face="monospace" size="+1">
			<xsl:choose>
			<xsl:when test="haschild or count > 0">
            	<a>
            	    <xsl:attribute name="href">/browse/<xsl:value-of select="domain"/>/<xsl:value-of select="id"/>/</xsl:attribute>
						
                	<xsl:value-of select="id"/>
            	</a>
			</xsl:when>
			<xsl:otherwise>
				<b><xsl:value-of select="id"/></b>
			</xsl:otherwise>
			</xsl:choose>
			
        </font>
    </td>
    <td>-</td>
    <td>
		<xsl:if test="count = 0">
        	<i><xsl:value-of select="comment"/></i>
		</xsl:if>
		<xsl:if test="not(count) or count &gt; 0">
        	<xsl:value-of select="comment"/>
		</xsl:if>
    </td>
	<xsl:if test="count">
   		<td>-</td>
    	<td align="right">
			<xsl:if test="count = 0">
				<i><xsl:value-of select="count"/></i>
			</xsl:if>
			<xsl:if test="count &gt; 0">
				<xsl:value-of select="count"/>
			</xsl:if>
   	 	</td>

    	<td>

			<xsl:if test="count &gt; 0">
       		 	item<xsl:if test="count &gt; 1">s</xsl:if>
			</xsl:if>
			<xsl:if test="count = 0">
       		 	<i>items</i>
			</xsl:if>
   		</td>
	</xsl:if>
</xsl:template>

<!--============== -->
<!-- leaf template -->
<!--============== -->

<xsl:template match="mscleaf">
    <a>
        <xsl:attribute name="href">
            /?op=getobj&amp;from=<xsl:value-of select="domain"/>&amp;id=<xsl:value-of select="id"/>
        </xsl:attribute>
		<xsl:apply-templates select="title/mathytitle"/>
    </a>
    <font size="-1"> owned by
    <a>
        <xsl:attribute name="href"><xsl:value-of select="owner/@href"/></xsl:attribute>
        <xsl:value-of select="owner"/>
    </a>
    </font>
</xsl:template>

