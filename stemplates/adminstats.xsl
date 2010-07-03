<xsl:template match="/">
<center>
<table cellpadding="1">
<tr>
<td bgcolor="#000000">
<table cellspacing="2" cellpadding="0">
<tr>
<td bgcolor="#eeeeee">
<table>
<xsl:apply-templates/>
</table>
</td>
</tr>
</table>
</td>
</tr>
</table>
</center>
</xsl:template>

<xsl:template match="stat">
    <tr>
        <td bgcolor="#eeeeee"><b><font color="#990000"><xsl:value-of select="@name"/></font></b></td>
        <td bgcolor="#ffffff"><xsl:value-of select="."/></td>
    </tr>
</xsl:template>

