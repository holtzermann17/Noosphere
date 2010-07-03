<xsl:template match="adminclassify">

	<xsl:call-template name="paddingtable">
	<xsl:with-param name="content">

	<xsl:call-template name="makebox">
	<xsl:with-param name="title">
		Classifying object: <xsl:value-of select="title"/>
	</xsl:with-param>

	<xsl:with-param name="content">
	
	<center>

	<table border="0"><td>
	<form method="post" action="/">
  
	<br />
  
	  Enter a classification string (See <a target="planetmath.popup" href="{//globals/main_url}/?op=mscbrowse">MSC</a>):
	<br />
	
	<input type="text" name="class" size="75">
		<xsl:attribute name="value">
			<xsl:value-of select="class"/>
		</xsl:attribute>
	</input>
	
	<br />

	<font size="-2">
    (examples: "msc:11F02", "msc:11F02, msc:11F03, msc:05R16". "msc:" can be ommitted, assumed by default.)
	</font>

	<br />
	<br />

	<xsl:if test="hascache">
		<input type="checkbox" name="invalidate"/>Invalidate cache (do this if links will be affected)
		<br /><br />
	</xsl:if>

  
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

	<input type="hidden" name="from">
		<xsl:attribute name="value">
			<xsl:value-of select="from"/>
		</xsl:attribute>
	</input>
  
	<center>
		<input type="submit" name="submit" value="submit"/>
	</center>

	</form>
	
	</td></table>

	</center>

	</xsl:with-param>    <!-- makebox -->
	</xsl:call-template>

	</xsl:with-param>    <!-- padding table -->
	</xsl:call-template>

</xsl:template>
