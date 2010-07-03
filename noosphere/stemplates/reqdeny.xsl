<xsl:template match="reqdeny">

<table align="center" cellpadding="5">

<tr><td>
	<form method="post" action="/">

	<center>
		<b>Rejecting fulfillment of request '<xsl:value-of select="title"/>'</b>
	</center>
	
	<br />
	
	Reason for denial:<br />
	<textarea rows="6" cols="70" name="reason"><xsl:value-of select="reason"/></textarea>

	<br /><br />

	<input type="hidden" name="op">
		<xsl:attribute name="value">
			<xsl:value-of select="op"/>
		</xsl:attribute>
	</input>
	
	<input type="hidden" name="id">
		<xsl:attribute name="value">
			<xsl:value-of select="id"/>
		</xsl:attribute>
	</input>

	<center><input type="submit" name="deny" value="deny"/></center>

	</form>

</td></tr>
</table>


<table cellpadding="5">
<tr><td>
Content of request:
</td></tr>
<tr><td bgcolor="#ffffff">
	<xsl:call-template name="printcode">
		<xsl:with-param name="source">
			<xsl:value-of select="content"/>
		</xsl:with-param>
	</xsl:call-template>
</td></tr>
</table>

<br />

<xsl:if test="normalize-space(clinks)">
	Fulfillment object(s): <xsl:copy-of select="clinks"/>
</xsl:if>

<br />
<br />

</xsl:template>

