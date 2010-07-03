<!DOCTYPE xsl:stylesheet [
	<!ENTITY nbsp "&#160;">
	<!ENTITY % iso-lat1 PUBLIC "ISO 8879:1986//ENTITIES Added Latin 1//EN//XML"
	                    "file:///var/www/noosphere/data/entities/iso-lat1.ent">
	%iso-lat1;
	<!ENTITY % xhtml-special PUBLIC "-//W3C//ENTITIES Special for XHTML//EN"
	                    "file:///var/www/noosphere/data/entities/xhtml-special.ent">
	%xhtml-special;
	<!ENTITY % xhtml-symbol PUBLIC "-//W3C//ENTITIES Symbols for XHTML//EN"
	                    "file:///var/www/noosphere/data/entities/xhtml-symbol.ent">
	%xhtml-symbol;
]>
<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>
<xsl:output method="html" version="4.01" encoding="UTF-8" indent="yes"/>

<!-- Noosphere root stylesheet template (pass-through) -->

<xsl:template match="NSXSLT">
	
	<xsl:apply-templates />
	
</xsl:template>

<!-- consume globals -->

<xsl:template match="globals">
 
	<!-- do nothing -->

</xsl:template>

<!-- pager widget -->

<xsl:template match="pager">
    <br/><center>
    <xsl:choose>
        <xsl:when test="@pages &lt; 2">
            displaying all <xsl:value-of select="@total"/> items.
        </xsl:when>
        <xsl:otherwise>
            jump to page:
            <xsl:if test="@prevhref">
                <a><xsl:attribute name="href"><xsl:value-of select="@prevhref"/></xsl:attribute>&lt;&lt;</a>
            </xsl:if>
            <xsl:for-each select="page">
                <xsl:text> </xsl:text><xsl:choose>
                    <xsl:when test="@selected"><xsl:value-of select="@number"/></xsl:when>
                    <xsl:otherwise><a><xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute><xsl:value-of select="@number"/></a></xsl:otherwise>
                </xsl:choose>
            </xsl:for-each> <xsl:if test="@nexthref">
                <xsl:text> </xsl:text><a><xsl:attribute name="href"><xsl:value-of select="@nexthref"/></xsl:attribute>&gt;&gt;</a>
            </xsl:if>
            (<xsl:value-of select="@total"/> items)
        </xsl:otherwise>
    </xsl:choose>
    </center>
</xsl:template>

<!-- standard box widget -->

<xsl:template name="makebox">
    <xsl:param name="title"/>
    <xsl:param name="content"/>
    <table width="100%">
        <tr><td>
            <table width="100%" border="0" cellpadding="1" cellspacing="0">
                <tr><td width="100%" bgcolor="#003399">
                    <font face="sans-serif" color="#FFFFFF"><xsl:value-of select="$title"/></font>
                </td></tr>
                <tr><td width="100%" bgcolor="#DDDDDD">
                    <font face="sans-serif" color="#000000"><xsl:copy-of select="$content"/></font>
                </td></tr>
            </table>
        </td></tr>
    </table>
</xsl:template>

<!-- math box widget -->

<xsl:template name="mathbox">
    <xsl:param name="title"/>
    <xsl:param name="content"/>
	<xsl:param name="width">100%</xsl:param>

    <table width="{$width}">
        <tr><td>
            <table width="100%" border="0" cellpadding="1" cellspacing="0">
                <tr><td bgcolor="#003399">
                    <font face="sans-serif" color="#FFFFFF"><xsl:value-of select="$title"/></font>
                </td></tr>
                <tr><td bgcolor="#FFFFFF">
                    <font face="sans-serif" color="#000000"><xsl:copy-of select="$content"/></font>
                </td></tr>
            </table>
        </td></tr>
    </table>
</xsl:template>


<!-- clear box widget -->

<xsl:template name="clearbox">
    <xsl:param name="title"/>
    <xsl:param name="content"/>
    <table width="100%" cellpadding="0" cellspacing="0">
        <tr><td>
            <table width="100%">
                <tr><td>
                    <table WIDTH="100%" BORDER="0" CELLPADDING="1" CELLSPACING="0">
                        <tr><td WIDTH="100%" BGCOLOR="#003399">
                            <font face="sans-serif" COLOR="#FFFFFF"><xsl:copy-of select="$title"/></font>
                        </td></tr>
                    </table>
                </td></tr>
            </table>
        </td></tr>
        <tr><td>
            <table width="100%" cellpadding="0" cellspacing="2">
                <tr><td>
                    <font face="sans-serif" COLOR="#000000"><xsl:copy-of select="$content"/></font>
                </td></tr>
            </table>
        </td></tr>
    </table>
</xsl:template>

<!-- admin-style "box" -->

<xsl:template name="adminbox">
    <xsl:param name="title"/>
    <xsl:param name="content"/>
    <table width="100%">
        <tr><td>
            <table WIDTH="100%" BORDER="0" CELLPADDING="1" CELLSPACING="0">
                <tr><td WIDTH="100%" BGCOLOR="#990000">
                    <font face="sans-serif" COLOR="#FFFFFF"><xsl:value-of select="$title"/></font>
                </td></tr>
                <tr><td WIDTH="100%" BGCOLOR="dddddd">
                    <font face="sans-serif" COLOR="#000000"><xsl:copy-of select="$content"/></font>
                </td></tr>
            </table>
        </td></tr>
    </table>
</xsl:template>

<!-- this is a stupid thing needed to make table cell edges line up right -->

<xsl:template name="paddingtable">

  <xsl:param name="content"/>

  <table width="100%" cellpadding="0" cellspacing="2">
    <td>
	  <xsl:copy-of select="$content"/>
	</td>
  </table>
  
</xsl:template>

<!-- print code nicely: monospaced and with \n replaced with <br> -->

<xsl:template name="printcode">

  <xsl:param name="source"/>

  <font face="monospace">

  <xsl:call-template name="print_with_replace">
    <xsl:with-param name="source">
      <xsl:value-of select="$source"/>
    </xsl:with-param>

    <xsl:with-param name="find"><xsl:text>&#10;</xsl:text></xsl:with-param>
    <xsl:with-param name="replace"><br /><xsl:text>&#10;</xsl:text></xsl:with-param>
  </xsl:call-template>

  </font>
</xsl:template>

<!-- a generic printing template which substitutes for XSL's lack of -->
<!-- a search-and-replace function -->

<xsl:template name="print_with_replace">

  <xsl:param name="source"/>
  <xsl:param name="find"/>
  <xsl:param name="replace"/>

  <xsl:if test="$source and $source != ''">

   <xsl:choose>
   <xsl:when test="substring-before($source, $find) != '' or $source = concat($find, substring-after($source, $find))">

    <!-- output chunk before first match -->
    <xsl:value-of select="substring-before($source, $find)"/>

    <!-- output replace for the match substring -->
    <xsl:copy-of select="$replace"/>

    <!-- recursive call -->
    <xsl:call-template name="print_with_replace">

      <!-- pass params but with string after substring match for content -->
      <xsl:with-param name="source">
        <xsl:value-of select="substring-after($source, $find)"/>
      </xsl:with-param>
      <xsl:with-param name="find">
        <xsl:value-of select="$find"/>
      </xsl:with-param>
      <xsl:with-param name="replace">
        <xsl:copy-of select="$replace"/>
      </xsl:with-param>
    </xsl:call-template>

   </xsl:when>

   <xsl:otherwise>

    <xsl:value-of select="$source"/>

   </xsl:otherwise>

   </xsl:choose>

  </xsl:if>

</xsl:template>

<!-- "main" body of output content -->

<NS:template content raw/>

<!-- mathytitle printing template -->

<xsl:template match="mathytitle">
	
	<xsl:for-each select="chunk">
		<!-- output math chunk -->
		<xsl:if test="@type = 'math'"> 
			<xsl:choose>
				<xsl:when test="imageurl"> 
					<img alt="{content}"  title="{content}" src="{imageurl}" align="{align}" border="0"/>
				</xsl:when>
				<xsl:otherwise>
					<img alt="{content}"  title="{content}" border="0"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<!-- output text chunk -->
		<xsl:if test="@type = 'text'"> 
			<xsl:value-of select="content"/>
		</xsl:if>
	</xsl:for-each>

</xsl:template>

</xsl:stylesheet>

