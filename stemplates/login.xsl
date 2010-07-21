<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output omit-xml-declaration="yes"/>
<xsl:template match="/login">
<div id="login">
<h1>Login</h1>
<form METHOD="post">
<xsl:attribute name="action"><xsl:value-of select="main_url"/></xsl:attribute>
<table>
<tr>
<td> 
<label>Username:</label>
</td>
<td>
<input name="user" type="text" />
</td>
</tr>
<tr>
<td>
<label>Password:</label>
</td>
<td>
<input name="passwd" type="password" />
</td>
</tr>
<tr>
<td></td>
<td>
<input name="Login" class="button" type="submit" value="Login" />
</td>
</tr>
<tr>
<td colspan="2">
<a><xsl:attribute name="href"><xsl:value-of select="main_url"/>?op=newuser</xsl:attribute>Register</a>
</td>
</tr>
<tr>
<td colspan="2">
<a><xsl:attribute name="href"><xsl:value-of select="main_url"/>?op=pwchangereq</xsl:attribute>I've forgotten my login details</a>
</td>
</tr>
</table>
<input type="hidden" value="" name="url"/><input type="hidden" value="login" name="op"/>
</form>
<xsl:copy-of select="error/node()"/>
</div>
</xsl:template>
</xsl:stylesheet>
