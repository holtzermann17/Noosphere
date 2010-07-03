<!-- this stylesheet turns a collaboration snapshot record into  -->
<!-- presentable HTML output for auditing purposes. -->

<xsl:template match="record">
 
  <xsl:call-template name="paddingtable">
   <xsl:with-param name="content">
   
    <xsl:call-template name="makebox">
        <xsl:with-param name="title">
		  Viewing Version 
		  <xsl:value-of select="@version"/>
		  of 
		  <xsl:value-of select="title"/>
		</xsl:with-param>

        <xsl:with-param name="content">
		
		 <table width="100%"> <td>
		 
			<center>
			  [ <a href="{//globals/main_url}/?op=getobj&amp;from=collab&amp;id={@id}">view '<xsl:value-of select="title"/>'</a>
  
              |
			  
              <a href="{//globals/main_url}/?op=vbrowser&amp;from=collab&amp;id={@id}">back to history</a>
			   
			  ]

			</center>

			<p/>

			<!-- basic information table -->
			
			<table cellpadding="2" cellspacing="0">
			 <tr>
			  <td>Title of document:</td>
			  <td><xsl:value-of select="title"/></td>
			 </tr>

			</table> <!-- END basic information table -->

			<p/>
		
		    <!-- date information table -->
			<table cellpadding="2" cellspacing="0">
			 <tr>
			
			  <td>Created on: </td>
			  <td><xsl:value-of select="created"/></td>
			 </tr>
			 <tr>
			  <td>Modified on:</td>
			  <td><xsl:value-of select="modified"/> </td>
			 </tr>
			</table> <!-- END date information table -->
			 
			<p/>
			
			<!-- user information table -->
			
			<table cellpadding="2" cellspacing="0">
			 <tr>
			  <td>  Creator:  </td>
			  <td>
			    <a>
			      <xsl:attribute name="href">
			       /?op=getuser&amp;id=<xsl:value-of select="creator/@id"/>
			      </xsl:attribute>	
			     <xsl:value-of select="creator/@name"/>
			    </a> 
			  </td>
			 </tr>
			 
			 <tr>
			  <td> Modifier: </td>
			  <td>
			    <a>
			     <xsl:attribute name="href">
			       /?op=getuser&amp;id=<xsl:value-of select="modifier/@id"/>
			     </xsl:attribute>	
			     <xsl:value-of select="modifier/@name"/>
			    </a> 
			  </td>
			 </tr>
			  
			 <xsl:for-each select="author">
			 <tr>
			   <td>Author:</td>
			   <td>
				<a>
			     <xsl:attribute name="href">
			       /?op=getuser&amp;id=<xsl:value-of select="@id"/>
			     </xsl:attribute>	
			     <xsl:value-of select="@name"/>
			    </a> 
			  </td>
			 </tr>
		     </xsl:for-each>
			
			</table>  <!-- END user information table -->
			
			<p/>

			<xsl:if test="comment and normalize-space(comment) != ''">
		    Revision comment (for changes between this and next version):  <p/>
			 <table width="100%" bgcolor="#ffffff"><td>
			 <xsl:call-template name="printcode">
			   <xsl:with-param name="source">
			    <xsl:value-of select="comment"/>
			   </xsl:with-param>
			 </xsl:call-template>
			 </td></table>
			</xsl:if>

			<p/>

			Content: <p/>

			 <table width="100%" bgcolor="#ffffff"><td>
			 <xsl:call-template name="printcode">
			   <xsl:with-param name="source">
			    <xsl:value-of select="content"/>
			   </xsl:with-param>
			 </xsl:call-template>
			 </td></table>
		
		</td></table>

        </xsl:with-param>

    </xsl:call-template>  <!-- makebox -->

   </xsl:with-param>
  </xsl:call-template>  <!-- paddingtable -->

</xsl:template>
