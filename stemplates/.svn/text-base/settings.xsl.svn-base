<xsl:template match="settings">

	<xsl:call-template name="paddingtable">
		<xsl:with-param name="content">
		
			<xsl:call-template name="makebox">
				<xsl:with-param name="title">Your Settings</xsl:with-param>
				<xsl:with-param name="content">

					<table width="100%" cellpadding="4">

					<tr><td>

						Here you can configure, tweak, and toggle your preferences and personal information:

						<p />
						
						<ul>
							<li><a href="{//globals/main_url}/?op=edituser">Your Info</a> <xsl:text> </xsl:text> <font size="-1">(<a href="{//globals/main_url}/?op=getuser&amp;id={id}">view</a>)</font> - Information about you.  Includes bio and default preamble.</li>
							
							<li><a href="{//globals/main_url}/?op=editprefs">Preferences</a> - Your <xsl:value-of select="//globals/site_name"/> configuration options.</li>
							
							<li><a href="{//globals/main_url}/?op=acledit&amp;from=acl_default">Default Permissions</a> - Configure the default access rules for your encyclopedia objects (includes setting free-form access, a-la Wiki).</li>
							
							<li><a href="{//globals/main_url}/?op=groupedit">Your Groups</a> - Make groups for your trusted associates, so you can grant them access more conveniently.</li>
							
							<li><a href="{//globals/main_url}/?op=watches">Your Watches</a> - Manage in one place all the watches you have on <xsl:value-of select="//globals/site_name"/> objects.</li>
						</ul>

					</td></tr>

					</table>

					<p />
					
				</xsl:with-param>
			</xsl:call-template>
		</xsl:with-param>
	</xsl:call-template>
</xsl:template>
