<!-- display message for no user -->
<xsl:template match="nouser">

	<xsl:call-template name="paddingtable">
		<xsl:with-param name="content">
			<xsl:call-template name="clearbox">
				<xsl:with-param name="title">
					User Info
				</xsl:with-param>
				<xsl:with-param name="content">
					User not found!
				</xsl:with-param>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>

</xsl:template>

<!-- display a user's vital stats-->

<xsl:template match="user">

 <xsl:call-template name="paddingtable">
  <xsl:with-param name="content">

    <xsl:call-template name="clearbox">
        <xsl:with-param name="title">User Info for <b><xsl:value-of select="username"/></b></xsl:with-param>
        <xsl:with-param name="content">
			
			<!-- deactivated message -->

			<xsl:if test="@active = 0">
			
				<center>

					<font color="#ff0000" size="+1">(This account has been deactivated)</font>

				</center>

			</xsl:if>

			<!-- table of basic info -->
			
			<table cellpadding="2">
			  <tr>
                <td bgcolor="#dddddd">User ID:</td>
			    <td><xsl:value-of select="uid"/></td>
			  </tr>
			  <xsl:if test="normalize-space(forename) or normalize-space(surname)">
			  <tr>
                <td bgcolor="#dddddd">Name:</td>
			    <td>
				  <xsl:value-of select="forename"/>
				  <!-- this is idiotic but i dont see any other way to get
				       a single space -->
				  <xsl:text> </xsl:text>
				  <xsl:value-of select="middlename"/>
				  <xsl:text> </xsl:text>
				  <xsl:value-of select="surname"/>
				</td>
			  </tr>
			  </xsl:if>
			<xsl:if test="@loggedin = 1">
			  <tr>
                <td bgcolor="#dddddd">E-mail Address:</td>
			    <td>
					<xsl:value-of select="email"/>
				</td>
			  </tr>
			</xsl:if>
			  <tr>
                <td bgcolor="#dddddd">Institution:</td>
			    <td><xsl:value-of select="institution"/></td>
			  </tr>
			  <tr>
                <td bgcolor="#dddddd">Institutional Role:</td>
			    <td><xsl:value-of select="institutionalrole"/></td>
			  </tr>
			  <xsl:if test="normalize-space(state) or normalize-space(city) or normalize-space(country)">
			  <tr>
                <td bgcolor="#dddddd">From:</td>
			    <td>
				  <xsl:choose>
				    <xsl:when test="normalize-space(state)">
				      <xsl:value-of select="city"/>,
				      <xsl:value-of select="state"/>,
				      <xsl:value-of select="country"/>
					</xsl:when>
					<xsl:otherwise>
				      <xsl:value-of select="city"/>,
				      <xsl:value-of select="country"/>
					</xsl:otherwise>
				  </xsl:choose>
				</td>
			  </tr>
			  </xsl:if>
			  <xsl:if test="normalize-space(homepage)">
			    <tr>
                  <td bgcolor="#dddddd">Homepage:</td>
			      <td>
				    <a>
					  <xsl:attribute name="href">
					    <xsl:value-of select="homepage"/>
					  </xsl:attribute>
					  <xsl:value-of select="homepage"/>
					</a>
				  </td>
			    </tr>
			  </xsl:if>
			    <tr>
                  <td bgcolor="#dddddd">Professional Page:</td>
			      <td>
				    <a>
					  <xsl:attribute name="href">
					    <xsl:value-of select="professionalpage"/>
					  </xsl:attribute>
					  <xsl:value-of select="professionalpage"/>
					</a>
				  </td>
			    </tr>
			  <tr>
                <td bgcolor="#dddddd">Joined On:</td>
			    <td><xsl:value-of select="joined"/></td>
			  </tr>
			  <tr>
                <td bgcolor="#dddddd">Last Logged in:</td>
			    <td><xsl:value-of select="last"/></td>
			  </tr>
			  <xsl:if test="@adminview = 1">
			    <tr>
                  <td bgcolor="#dddddd">Host info:</td>
			    	<td><xsl:value-of select="lastip"/> 
					 (<xsl:value-of select="hostname"/>)
				  </td>
			    </tr>
			  </xsl:if>
			  <tr>
                <td bgcolor="#dddddd">Access Level:</td>
			    <td><xsl:value-of select="access"/></td>
			  </tr>
			  <tr>
                <td bgcolor="#dddddd">Score:</td>
			    <td><xsl:value-of select="score"/>
				
					<xsl:if test="@adminview = 1">
						<xsl:text> </xsl:text>
						<font size="-1">
						<a href="{//globals/main_url}/?op=editscore&amp;user={uid}">(admin edit)</a>
						</font>
					</xsl:if>
				</td>
			  </tr>
			</table>

			
			<!-- list of counts of objects related to this user -->
			
			<p></p>

			<xsl:value-of select="username"/>'s

			<ul>
			
            <xsl:for-each select="counts/item">
			   <li>
			     <a>
			       <xsl:attribute name="href">
				     <xsl:value-of select="@href"/>
				   </xsl:attribute>
				   <xsl:value-of select="@label"/>
			     </a>
			     <font size="-1">
			       (<xsl:value-of select="@count"/>)
			     </font>
			   </li>
            </xsl:for-each>

			</ul>

			<!-- the bio -->

			<xsl:if test="normalize-space(bio)">

			<hr />

               <center> <font size="+1">Bio:</font> </center>

			   <p>
                 <xsl:copy-of select="bio"/>
			   </p>
			   
			</xsl:if>

			<hr />

			<br/>

			<!-- control for easily sending local mail to the user -->
			
			Send <xsl:value-of select="//globals/site_name"/>
			<xsl:text> </xsl:text><a href="{mailurl}">mail to <xsl:value-of select="username"/></a>.

			
			<br />

			<!-- admin controls -->

			<xsl:if test="@adminview = 1">

				<br />

				<xsl:call-template name="adminbox">

					<xsl:with-param name="title">Admin</xsl:with-param>

					<xsl:with-param name="content">
						<center>

						<xsl:if test="@active = 0">
							<a><xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=reactivate;id=<xsl:value-of select="uid"/>;ask=yes</xsl:attribute>reactivate account</a>
						</xsl:if>
						<xsl:if test="@active = 1">
							<a><xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=deactivate;id=<xsl:value-of select="uid"/>;ask=yes</xsl:attribute>deactivate account</a>
						</xsl:if>

						|

						<a><xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=deluser;id=<xsl:value-of select="uid"/>;ask=yes</xsl:attribute>delete user</a>
						
						</center>
					</xsl:with-param>
				</xsl:call-template>

			</xsl:if>

			<xsl:if test="@editorview = 1">

				<br />

				<xsl:call-template name="adminbox">

					<xsl:with-param name="title">Editor</xsl:with-param>

					<xsl:with-param name="content">
						<center>
						<a><xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=edituserroles;id=<xsl:value-of select="uid"/></xsl:attribute>edit user roles</a>

						<xsl:if test="@active = 0">

						|

							<a><xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=reactivate;id=<xsl:value-of select="uid"/>;ask=yes</xsl:attribute>reactivate account</a>
						</xsl:if>
						<xsl:if test="@active = 1">
						
						|

							<a><xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=deactivate;id=<xsl:value-of select="uid"/>;ask=yes</xsl:attribute>deactivate account</a>
						</xsl:if>

						|

						<a><xsl:attribute name="href"><xsl:value-of select="//globals/main_url"/>/?op=deluser;id=<xsl:value-of select="uid"/>;ask=yes</xsl:attribute>delete user</a>
						
						</center>
					</xsl:with-param>
				</xsl:call-template>

			</xsl:if>
		
        </xsl:with-param>
    </xsl:call-template>

  </xsl:with-param>
 </xsl:call-template>

</xsl:template>

