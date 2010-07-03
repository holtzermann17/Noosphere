<xsl:template match="aboutratings">

	<xsl:call-template name="paddingtable">
	<xsl:with-param name="content">

	<xsl:call-template name="clearbox">
	<xsl:with-param name="title">What Are PlanetMath "Ratings"?</xsl:with-param>
	<xsl:with-param name="content">

			<h2>Introduction</h2>

			<p>Ratings on PlanetMath consist of two parts: user (object owner) reputation estimates, and direct object ratings (scores).   The former is estimated from a variety of activity on PlanetMath (corrections, history of ownership, correction behavior, etc.), and the latter comes from ratings of objects along various quality dimensions by other users.</p>

			<h2>Reputations Method Overview</h2>

			<p>Reputations are estimated using a method based on the HITS algorithm.   A network model is built which represents object owners/editors (past owners), objects, and corrections, and their interconnections.   This data is used to infer which users are contributing more value to the content base.   The output is a set of user confidence scores that are converted to ranks and mapped to a 1-5 scale, displayed as a "meter" on PlanetMath.   One should remember that these ratings are only an estimate, as it is difficult to capture and impossible to "objectively" measure "value"!  They should be used only as a rough guideline of quality and reptuation.
			</p>

			<h2>Ratings Method Overview</h2>

			<p>When you have rated an object, your rating will show on the radio buttons below the main object text whenever you view the object.  You can change these ratings at any time (which you should do, since the object will change over time and its quality might change)!   If the object has changed since you last rated it, your ratings will <b>not</b> show next time, meaning you should re-rate it.   Your old rating is still stored and used, however, <b>it will gradually lose influence over time</b>.</p>

			<p>The influence of ratings is based on a linear falloff, and old ratings are ignored after after 20 edits to the object.</p>

			<h2>The Code</h2>

			<p>Code for this system can be acquired from <a href="http://code.google.com/p/google-summer-of-code-2007-planetmath/downloads/list">the Google PlanetMath 2007 SoC code repository</a>.  It is also checked into the <a href="http://aux.planetmath.org/noosphere/">Noosphere subVersion repository</a>.
			</p>

			<h2>Further Reading</h2>

			<ul>
				<li><a href="http://www.mathcs.emory.edu/~pjurczy/pp224-jurczyk.pdf">HITS on Question Answer Portals: an Exploration of Link Analysis for Author Ranking</a> (poster),<br/>
					Pawel Jurczyk and Eugene Agichtein,<br/>
					ACM SIGIR International Conference on Research and Development in Information Retrieval (SIGIR), 2007
				</li>
			<li><a href="http://www.mathcs.emory.edu/~pjurczy/cikm542s-jurczyk.pdf">Discovering Authorities in Question Answer Communities by Using Link Analysis</a> (poster)<br/>
					Pawel Jurczyk and Eugene Agichtein<br/>
					to appear in Conference on Information and Knowledge Management (CIKM), 2007
				</li>
			</ul>

			<h2>Credits</h2>

			<p>This system was implemented under the Google Summer of Code program for 2007 by Pawel Jurczyk, under the direction of Aaron Krowne.  It was based on prior research by Pawel Jurczyk and Eugene Agichtein.</p>
			
	</xsl:with-param>
	</xsl:call-template>
	</xsl:with-param>
	</xsl:call-template>

</xsl:template>
