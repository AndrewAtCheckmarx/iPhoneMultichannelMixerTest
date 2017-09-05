<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/TR/xhtml1/strict">

	<xsl:output method="text" /> 
	<xsl:template match="/">
		<xsl:variable name="highResults" select="count(CxXMLResults/Query/Result[@state!=1 and @Severity='High'])" />
		<xsl:variable name="medResults" select="count(CxXMLResults/Query/Result[@state!=1 and @Severity='Medium'])" />
		<xsl:if test="$highResults > 0">[ERROR] <xsl:value-of select="$highResults" /> High vulnerabilities detected in this project</xsl:if>
		<xsl:text>&#xa;</xsl:text>
		<xsl:if test="$medResults > 0">[WARNING] <xsl:value-of select="$medResults" /> Medium vulnerabilities detected in this project</xsl:if>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
