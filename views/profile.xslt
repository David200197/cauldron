<?xml version="1.0" ?>
<!--
//
//  Copyright (c) by Hugo Leisink <hugo@leisink.net>
//  This file is part of the Banshee PHP framework
//  https://www.banshee-php.org/
//
//  Licensed under The MIT License
//
//-->
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="banshee/main.xslt" />

<!--
//
//  Edit template
//
//-->
<xsl:template match="edit">
<xsl:call-template name="show_messages" />
<form action="/{/output/page}" method="post">
<label for="fullname">Name:</label>
<input type="text" id="fullname" name="fullname" value="{fullname}" class="form-control" />
<label for="email">E-mail address:</label>
<input type="text" id="email" name="email" value="{email}" class="form-control" />
<label>Organisation:</label>
<input type="text" disabled="disabled" value="{organisation}" class="form-control" />
<label for="keyboard">Keyboard layout:</label>
<select id="keyboard" name="keyboard" class="form-control">
<xsl:for-each select="keyboards/keyboard">
<option value="{@value}"><xsl:if test="@value=../../keyboard"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:value-of select="." /></option>
</xsl:for-each>
</select>
<label for="current">Current password:</label>
<input type="password" id="current" name="current" class="form-control" />
<label for="password">New password:</label> <span class="blank" style="font-size:10px">(will not be changed when left blank)</span>
<input type="password" id="password" name="password" class="form-control" />
<label for="repeat">Repeat password:</label>
<input type="password" id="repeat" name="repeat" class="form-control" />
<xsl:if test="@authenticator='yes'">
<label for="secret">Authenticator secret:</label> [<span class="info" onClick="javascript:$('#as_dialog').dialog()">?</span>]
<div class="input-group">
	<input type="text" id="secret" name="authenticator_secret" value="{authenticator_secret}" class="form-control" style="text-transform:uppercase" />
	<span class="input-group-btn"><input type="button" value="Generate" class="btn btn-default" onClick="javascript:set_authenticator_code()" /></span>
</div>
</xsl:if>

<div class="btn-group">
<input type="submit" name="submit_button" value="Update profile" class="btn btn-default" />
</div>
<xsl:if test="/output/user/@admin='no'">
<div class="btn-group">
<input type="submit" name="submit_button" value="Delete profile" class="btn btn-danger" onClick="javascript:return prompt('This account and all of its data will be deleted. Type \'DELETE\' if you are sure.') == 'DELETE';" />
</div>
</xsl:if>
</form>

<h2>Recent account activity</h2>
<table class="table table-striped table-xs">
<thead>
<tr>
<th>IP address</th>
<th>Timestamp</th>
<th>Activity</th>
</tr>
</thead>
<tbody>
<xsl:for-each select="actionlog/log">
<tr>
<td><xsl:value-of select="ip" /></td>
<td><xsl:value-of select="timestamp" /></td>
<td><xsl:value-of select="message" /></td>
</tr>
</xsl:for-each>
</tbody>
</table>

<div id="as_dialog" title="Authenticator app">
<p>This option requires the use of an authenticator app (RFC 6238) on your mobile phone.</p>
<p>The app must use BASE32 characters, SHA1 and a 30 second time interval to generate a 6 digit code.</p>
</div>
</xsl:template>

<!--
//
//  Content template
//
//-->
<xsl:template match="content">
<h1><xsl:value-of select="/output/layout/title/@page" /></h1>
<xsl:apply-templates select="edit" />
<xsl:apply-templates select="result" />
</xsl:template>

</xsl:stylesheet>
