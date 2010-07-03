<xsl:template match="dispmail">

	<xsl:call-template name="paddingtable">
	<xsl:with-param name="content">
		
	<xsl:call-template name="makebox">
	<xsl:with-param name="title">Viewing Mail Message</xsl:with-param>
	<xsl:with-param name="content">

		From: <xsl:value-of select="fromname"/> <br/>
		To: <xsl:value-of select="toname"/> <br/>
		Date: <xsl:value-of select="sent"/> 
		
		<br/><br/>

		Subject: <xsl:value-of select="subject"/> 
		
		<br/><br/>

		Message: <br/>

		<!-- print message body -->

		<table width="100%" cellpadding="5">
			<tr>
				<td bgcolor="#ffffff">
					<xsl:copy-of select="body_formatted"/>
				</td>
			</tr>
		</table>

		<br/>

		<!-- context menu -->

		<center>
			[ 
				
				<!-- return to mailbox -->

				<a href="{//globals/main_url}/?op=mailbox">mailbox</a> 
			
				<!-- reply to this message -->

				<xsl:if test="reply=1">

					|

					<a href="{//globals/main_url}/?op=replymail&amp;id={uid}&amp;rsubject={rsubject}">reply</a>

				</xsl:if>

				<!-- unsend this message -->

				<xsl:if test="unsend=1">
					|
					
					<a href="{//globals/main_url}/?op=unsend&amp;id={uid}">unsend</a>
				</xsl:if>
			]
		</center>

		<br/>

	</xsl:with-param>
	</xsl:call-template>

	</xsl:with-param>
	</xsl:call-template>

</xsl:template>

