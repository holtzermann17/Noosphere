<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml"  
  	omit-xml-declaration = "yes"/>
<xsl:template match="/object">
<div id="citation">
	<xsl:copy-of select="authors/node()"/>.
	"<xsl:copy-of select="title/node()"/>"
	(version <xsl:copy-of select="version/node()"/>).
	<i>PlanetMath.org</i>.  Freely available at http://planetmath.org/?op=getobj;from=objects;id=<xsl:value-of select="id"/>
</div>
</xsl:template>
</xsl:stylesheet>
