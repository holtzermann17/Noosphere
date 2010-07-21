<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" />
<xsl:template match="/mainpage">
<html>
<head>
<xsl:copy-of select="head/node()" />
</head>
<body>
<div id="container">
<xsl:copy-of select="header/node()" />
<div id="content">
<div id="left">
<xsl:copy-of select="login/node()" />
<xsl:copy-of select="logos/node()" />
</div>
<div id="right">
<div class="box_padding">
<div id="maincontent_box">
<p>
This is the <strong>PlanetMath.org</strong> development server. This is the place where the latest Noosphere enhancements are demonstrated and functionality will break periodically.</p>
<p>All encyclopedia entries are written in 
<a href="http://www.latex-project.org/">LaTeX</a>. All of the
entries are automatically cross-referenced and the entire corpus is
kept updated in real-time.</p>
<p>Accounts are free and required to do anything other than browse,
so 
<a href="{//globals/main_url}/?op=newuser">sign up</a>! It only
takes a minute.</p>
</div>
</div>
<div id="go_to_padding">
<div id="go_to">
Browse Encyclopedia By: <a href="/browse/objects/">Subject</a> | <a href="/?op=enlist;mode=hits">Popularity</a> | <a href="/encyclopedia/">More</a>
</div>
</div>
<div id="latest_padding">
<div id="latest">
<xsl:copy-of select="latestadditions/node()" />
</div>
</div>
<div id="author_padding">
<div id="authors">
<xsl:copy-of select="topusers/node()" />
</div>
</div>
</div>
</div>
</div>
<!-- end container -->
</body>
</html>
</xsl:template>
</xsl:stylesheet>
