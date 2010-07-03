<xsl:template match="addgeneric">

	<!-- instructions and junk -->
	<xsl:choose>

		<xsl:when test="@section='Papers'">
			 <b>Paper guidelines</b>:

			 <p />

			 <ul>
			 	<li>This section is chiefly for your original work. It does not have to be published, but should be research-oriented. Theses and dissertations can go here as well. <b>Do not put other people's work here unless they have granted unlimited redistribution rights</b>.</li>
				<li><b>"Rights" must explain what the terms are of third-party distribution of the work.</b>  Placement of works here which are not permitted to be distributed by third parties may result in you being banned from this site.</li>
				<li><b>Please upload the paper if you are permitted.</b> This makes it more reliably available to readers.  Use the Filebox Manager at the bottom of the page to upload.  If the license of the paper does not permit redistrbution, please give a link to it.</li>
				<li><b>You must enter in a substantial description</b>.  Excerpts from the abstract, foreword, introduction, or even table of contents often serve as a satisfactory description.  However, if you use an excerpt, please <b>put it in quotations</b> and say where it is from (e.g, "From the introduction:")!</li>
				<li>Starred (<font color="#ff0000">*</font>) fields are required. </li>
			</ul>
		</xsl:when>
		
		<xsl:when test="@section='Expositions'">
			 <b>Exposition guidelines</b>:

			 <p />

			 <ul>
			 	<li>This section is for expositions which are <b>not books</b>. They will generally be for educational purposes, but it is most important that they are not considered papers or books for them to appear here. Lecture notes for a course are a good example of what should go here.</li>
				<li><b>"Rights" are required for every item!</b> If you dont know what the rights are, please check before doing anything (including asking the author of the work if need be). </li>
				<li><b>Restating who holds the copyright is not a valid rights statement!</b> The rights statement must explain the rights of third parties to distribute and modify the work.</li>
				<li><b>A URL to the home page of the work is required</b>, even if you are also providing a copy of the file here!</li>
				<li><b>Do not upload copies of the work unless third parties are granted distribution rights!</b>  Failure to comply to license terms pertaining to distribution may result in you being banned from this site!</li>
				<li><b>You must enter in a substantial description</b>.  Excerpts from the abstract, foreword, introduction, or even table of contents often serve as a satisfactory description.  However, if you use an excerpt, please <b>put it in quotations</b> and say where it is from (e.g, "From the introduction:")!</li>
				<li>Starred (<font color="#ff0000">*</font>) fields are required. </li>
			</ul>
		</xsl:when>

		<xsl:when test="@section='Books'">

			 <b>Book guidelines</b>:

			 <p />

			 <ul>

				<li>This section is for <b>books only</b>, published or unpublished. I.e., lecture notes would not go here.</li>
				<li><b>"Rights" are required for every item!</b> If you dont know what the rights are, please check before doing anything (including asking the author of the work if need be). </li>
				<li><b>Restating who holds the copyright is not a valid rights statement!</b> The rights statement must explain the rights of third parties to distribute and modify the work.</li>
				<li><b>A URL to the home page of the resource is required</b>, even if you are also providing a copy of the file here!</li>
				<li><b>Do not upload copies of the work unless third parties are granted distribution rights!</b>  Failure to comply to license terms pertaining to distribution may result in you being banned from this site!</li>
				<li><b>To add a cover image for the book</b>, upload files "coverimage.ext" and "coverimage_big.ext" (for the zoomed-in version), where "ext" is any image format extension (e.g. "jpg", "gif", "png").</li>
				<li><b>You must enter in a substantial description</b>.  Excerpts from the abstract, foreword, introduction, or even table of contents often serve as a satisfactory description.  However, if you use an excerpt, please <b>put it in quotations</b> and say where it is from (e.g, "From the introduction:")!</li>
				<li>Starred (<font color="#ff0000">*</font>) fields are required. </li>
			</ul>

		</xsl:when>

	</xsl:choose>
	
	<hr />

    <p />

	<!-- main submission form -->

	<form method="post" action="/" enctype="multipart/form-data" accept-charset="UTF-8">

	<table align="center" cellpadding="0" cellspacing="0">

	<tr><td>

		<font face="sans-serif, arial, helvetica">

		<xsl:if test="normalize-space(error)">
			<font color="#ff0000" size="+1"><xsl:copy-of select="error"/></font>

			<br />
		</xsl:if>
		
		Title<font color="#ff0000">*</font>: 
		
		<br />

		<xsl:element name="input">

					<xsl:attribute name="type">text</xsl:attribute>
					<xsl:attribute name="name">title</xsl:attribute>
					<xsl:attribute name="value"><xsl:value-of select="title"/></xsl:attribute>
					<xsl:attribute name="size">75</xsl:attribute>
				</xsl:element>
		
		<br /> <br />

		Authors<font color="#ff0000">*</font>: 

		<br />
		
		<xsl:element name="input">
			<xsl:attribute name="type">text</xsl:attribute>
			<xsl:attribute name="name">authors</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="authors"/></xsl:attribute>
			<xsl:attribute name="size">75</xsl:attribute>
		</xsl:element>
		
		<br /> <br />

		Keywords (<a href="{//globals/main_url}/?op=assocguidelines">Guidelines</a>): 
		
		<br />
			
		<xsl:element name="input">
			<xsl:attribute name="type">text</xsl:attribute>
			<xsl:attribute name="name">keywords</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="keywords"/></xsl:attribute>
			<xsl:attribute name="size">75</xsl:attribute>
		</xsl:element>

		<xsl:if test="//globals/classification_supported = 1">
		
			<br /> <br />

			Classification (See <a target="planetmath.popup" href="{//globals/main_url}/?op=mscbrowse">MSC</a>)<font color="#ff0000">*</font>:

			<br />
		
				<xsl:element name="input">
					<xsl:attribute name="type">text</xsl:attribute>
					<xsl:attribute name="name">class</xsl:attribute>
					<xsl:attribute name="value"><xsl:value-of select="class"/></xsl:attribute>
					<xsl:attribute name="size">75</xsl:attribute>
				</xsl:element>
		
			<br />

			<font size="-2">(examples: "msc:11F02", "msc:11F02, msc:11F03, msc:05R16". "msc:" can be ommitted, assumed by default.)</font>

		</xsl:if>

		<br /> <br />

		<xsl:if test="@section='Books'">

			ISBN #:

			<xsl:element name="input">
				<xsl:attribute name="type">text</xsl:attribute>
				<xsl:attribute name="name">isbn</xsl:attribute>
				<xsl:attribute name="value"><xsl:value-of select="isbn"/></xsl:attribute>
				<xsl:attribute name="size">16</xsl:attribute>
			</xsl:element>


			<br /> <br />
			
		</xsl:if>

		Additional Comments (typically date, # of pages, chapters, etc):
		
		<br />

		<xsl:element name="input">
			<xsl:attribute name="type">text</xsl:attribute>
			<xsl:attribute name="name">comments</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="comments"/></xsl:attribute>
			<xsl:attribute name="size">75</xsl:attribute>
			<xsl:attribute name="max">128</xsl:attribute>
		</xsl:element>

		<br /> <br />
		
		Rights statement<font color="#ff0000">*</font> (URLs will become hyperlinks):

		<br />

		<textarea name="rights" cols="75" rows="4"><xsl:value-of select="rights"/></textarea>

		<br /> <br />

		Abstract<font color="#ff0000">*</font>:

		<br />

		<textarea name="data" cols="75" rows="8"><xsl:value-of select="data"/></textarea>

		<br /> <br />

		URLs for any remote content (one per line)<font color="#ff0000">*</font>:

		<br />

		<textarea name="urls" cols="75" rows="4"><xsl:value-of select="urls"/></textarea>

		<br /> <br />

		<xsl:element name="input">
			<xsl:attribute name="type">hidden</xsl:attribute>
			<xsl:attribute name="name">op</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="op"/></xsl:attribute>
		</xsl:element>
		<xsl:element name="input">
			<xsl:attribute name="type">hidden</xsl:attribute>
			<xsl:attribute name="name">to</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="to"/></xsl:attribute>
		</xsl:element>

		<center>
			<input type="submit" name="post" value="finished" />
			<br /><br />
		</center>

		</font>

		</td></tr></table>

	<!--==============-->
	<!-- file manager -->
	<!--==============-->

	<xsl:if test="fmanager">
	
		<xsl:copy-of select="fmanager"/>

	</xsl:if>

	</form>

</xsl:template>
