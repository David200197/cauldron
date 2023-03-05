<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="layout[@name='adventure']">
<html lang="{language}">

<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="viewport" content="width=device-width, initial-scale=0.67, maximum-scale=0.67" />
<meta name="author" content="Hugo Leisink" />
<meta name="publisher" content="Hugo Leisink" />
<meta name="copyright" content="Copyright (c) by Hugo Leisink" />
<meta name="description" content="{description}" />
<meta name="keywords" content="{keywords}" />
<meta name="generator" content="Banshee PHP framework v{/output/banshee/version} (https://www.banshee-php.org/)" />
<meta property="og:title" content="{title/@page}" />
<meta property="og:description" content="{description}" />
<meta property="og:image" content="/images/cauldron.png" />
<meta property="og:url" content="https://{/output/website_url}/images/cauldron.png" />
<meta name="twitter:card" content="summary" />
<meta name="twitter:title" content="{title/@page}" />
<meta name="twitter:description" content="{description}" />
<meta name="twitter:image" content="https://{/output/website_url}/images/cauldron.png" />
<link rel="apple-touch-icon" href="/images/cauldron.png" />
<link rel="icon" href="/images/cauldron.png" />
<link rel="shortcut icon" href="/images/cauldron.png" />
<title><xsl:if test="title/@page!='' and title/@page!=title"><xsl:value-of select="title/@page" /> - </xsl:if><xsl:value-of select="title" /></title>
<xsl:for-each select="alternates/alternate">
<link rel="alternate" title="{.}" type="{@type}" href="{@url}" />
</xsl:for-each>
<xsl:for-each select="styles/style">
<link rel="stylesheet" type="text/css" href="{.}" />
</xsl:for-each>
<xsl:if test="inline_css">
<style type="text/css">
<xsl:value-of select="inline_css" />
</style>
</xsl:if>
<xsl:for-each select="javascripts/javascript">
<script type="text/javascript" src="{.}"></script><xsl:text>
</xsl:text></xsl:for-each>
</head>

<body hostname="{/output/hostname}">
<xsl:if test="javascripts/@onload">
	<xsl:attribute name="onLoad">javascript:<xsl:value-of select="javascripts/@onload" /></xsl:attribute>
</xsl:if>
<div class="wrapper">
	<div class="content">
		<div class="container">
			<xsl:apply-templates select="/output/content" />
		</div>
	</div>

	<xsl:apply-templates select="/output/internal_errors" />
</div>
</body>

</html>
</xsl:template>

</xsl:stylesheet>
