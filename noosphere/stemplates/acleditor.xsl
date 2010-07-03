<xsl:template match="acleditor">

	<table width="100%" cellpadding="2">
	<td>

	<xsl:if test="default">
		<i>The default ACL list allows you to set the access rules which will
		be applied to each new object you create.  This should include a 
		default-flagged rule for the "general public", and any special rules
		you want applied to certain groups for all of your objects. If you want "wiki-like" universal editing permissions for all of
		your objects, this is the place to do it.
		</i>
		<hr />
	</xsl:if>

	<form name="newaclform" method="post" action="">
  
	<font size="+1" color="#ff0000"><xsl:copy-of select="error"/></font>

	<b>Add a new rule:</b> 
  
	<br /><br />

	<table width="90%" align="center"> 

	<tr><td align="center" bgcolor="#eeeeee">Select a subject</td></tr>

	<tr><td>
		<i>by group quick-select:</i>

		<br /><br />

		<center>
	
		Your groups: <xsl:copy-of select="gselect"/>

		<br />
	
		</center>
  
	</td></tr>
    
	<tr><td>
		
		<i>or manually</i>:

		<br /><br />

		<center>
	
		subject (user or group) id or name: 
		<input type="text" name="subjectid_new" size="16">
			<xsl:attribute name="value">
				<xsl:value-of select="subjectid_new"/>
			</xsl:attribute>
		</input>

		<br /><br />
  
		subject is a: 
  
		<input type="radio" name="uog_new" value="u" checked="checked"/> user 
		<input type="radio" name="uog_new" value="g"/> group 

		<br /><br />

		</center>

	</td></tr>

	<tr><td align="center" bgcolor="#eeeeee">Set Permissions</td></tr>

	<tr><td align="center">
  
		<br />

		Read: <input type="checkbox" name="read_new" checked="checked"/> 
		Write: <input type="checkbox" name="write_new" checked="checked"/>  
		ACL: <input type="checkbox" name="acl_new"/> 

		<br /><br />

	</td></tr>

	<xsl:if test="hasdef=0">
		<tr><td align="center" bgcolor="#eeeeee">Set Default Status</td></tr>

		<tr><td>

		<br />

		<center>
		This is the default rule: <input type="checkbox" name="default_new" checked="checked"/>
		</center>

		<br />
		<i>Setting this will cause any subject selection above to be ignored, as the default rule applies to any user.</i>

		<br /><br />

		</td></tr>
	</xsl:if>
   
	</table>
  
	<center>
	<input type="submit" name="addrule" value="add rule"/>
	</center>
  
	<hr />
  
	<b>Change existing rules:</b> 
	
	<br /><br />

	<xsl:copy-of select="acllist"/>

	<input type="hidden" name="id">
		<xsl:attribute name="value">
			<xsl:value-of select="id"/>
		</xsl:attribute>
	</input>
	<input type="hidden" name="from">
		<xsl:attribute name="value">
			<xsl:value-of select="from"/>
		</xsl:attribute>
	</input>
	<input type="hidden" name="op" value="acledit"/>    

	<xsl:if test="default">

		<hr />
		<b>Retroactively apply rules:</b>

		<br /><br />

		<table align="center"><tr><td>
		
			Combine with existing rules: <input type="submit" name="combineall" value="combine"/>

			<br /><br />
	
			Replace existing rules: <input type="submit" name="replaceall" value="replace"/>
			<br /><br />
		</td></tr></table>

		<i>Warning: This is a <b>global</b> change, i.e. it will effect <b>all</b> of your objects!  If you have made rules for particular groups or users for some objects, "combine" will preserve these rules (though conflicting rules will be overwritten). "Replace" will result in them being deleted, and each object will have a completely new access control list.</i>

	</xsl:if>

	</form>

	<br />

	<xsl:if test="not(default)">
		<center>
		<a>
			<xsl:attribute name="href">
			/?op=getobj&amp;from=<xsl:value-of select="from"/>&amp;id=<xsl:value-of select="id"/>
			</xsl:attribute>
			back to the object
		</a>
	
		</center>
	</xsl:if>

	</td></table>

</xsl:template>
