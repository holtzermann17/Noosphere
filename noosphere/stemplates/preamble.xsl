<!-- this stylesheet formats an encylopedia preamble record -->

<xsl:template match="preamble">
 
  <xsl:call-template name="paddingtable">
   <xsl:with-param name="content">
   
    <xsl:call-template name="makebox">
        <xsl:with-param name="title">
		  Viewing Preamble for 
		  <xsl:value-of select="title"/>
		</xsl:with-param>

        <xsl:with-param name="content">
		
		 <table width="100%"> 
		 <tr>
		   <td align="center">
		      <p/>
			  [ <a>
			    <xsl:attribute name="href">
				  /?op=getobj&amp;from=<xsl:value-of select="table"/>&amp;id=<xsl:value-of select="objectid"/>
				</xsl:attribute>

				back to '<xsl:value-of select="title"/>'
			  </a> 
			  ]
			  <p/>
		   </td>
		 </tr>
		 <tr>
		   <td bgcolor="#ffffff">
			 <xsl:call-template name="printcode">
			   <xsl:with-param name="source">
			    <xsl:value-of select="text"/>
			   </xsl:with-param>
			 </xsl:call-template>
		   </td>
		 </tr>
		 </table>

        </xsl:with-param> <!-- content -->

    </xsl:call-template>  <!-- makebox -->

   </xsl:with-param>
  </xsl:call-template>  <!-- paddingtable -->

</xsl:template>
