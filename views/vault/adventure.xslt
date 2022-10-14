<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="../banshee/main.xslt" />
<xsl:import href="../banshee/pagination.xslt" />

<!--
//
//  Overview template
//
//-->
<xsl:template match="overview">
<table class="table table-condensed table-striped table-hover">
<thead>
<tr><th>ID</th><th>Title</th><th>Maps</th><th>Players</th><th>Access</th></tr>
</thead>
<tbody>
<xsl:for-each select="adventures/adventure">
<tr class="click" onClick="javascript:document.location='/{/output/page}/{@id}'">
<td><xsl:value-of select="@id" /></td>
<td><xsl:value-of select="title" /></td>
<td><xsl:value-of select="maps" /></td>
<td><xsl:value-of select="players" /></td>
<td><xsl:value-of select="access" /></td>
</tr>
</xsl:for-each>
</tbody>
</table>

<div class="btn-group left">
<a href="/{/output/page}/new" class="btn btn-default">New adventure</a>
<a href="/vault" class="btn btn-default">Back</a>
</div>

<div id="help">
<p>All your adventures are listed here.</p>
<p>After creating a new adventure, you will automatically be forwarded to the Maps section, where you can add one or more maps to your adventure.</p>
</div>
</xsl:template>

<!--
//
//  Edit template
//
//-->
<xsl:template match="edit">
<xsl:call-template name="show_messages" />
<form action="/{/output/page}" method="post">
<xsl:if test="adventure/@id">
<input type="hidden" name="id" value="{adventure/@id}" />
</xsl:if>

<label for="title">Title:</label>
<input type="text" id="title" name="title" value="{adventure/title}" placeholder="The title of your adventure / campaign." class="form-control" />
<label for="image">Title background image URL (optional):</label>
<div class="input-group">
<input type="text" id="image" name="image" value="{adventure/image}" placeholder="The image to show in the Adventures page." class="form-control" />
<span class="input-group-btn"><input type="button" value="Browse resources" class="btn btn-default browser" /></span>
</div>
<label for="story">Introduction story (optional):</label>
<textarea id="story" name="story" class="form-control" placeholder="A story to introduce your adventure to your players."><xsl:value-of select="adventure/story" /></textarea>
<label for="story">Access rights:</label>
<select id="access" name="access" class="form-control">
<xsl:for-each select="access/level">
<option value="{@value}"><xsl:if test="@value=../../adventure/access"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if><xsl:value-of select="." /></option>
</xsl:for-each>
</select>

<div class="btn-group">
<input type="submit" name="submit_button" value="Save adventure" class="btn btn-default" />
<a href="/{/output/page}" class="btn btn-default">Cancel</a>
<xsl:if test="adventure/@id">
<input type="submit" name="submit_button" value="Delete adventure" class="btn btn-default" onClick="javascript:return confirm('DELETE: Are you sure?')" />
</xsl:if>
</div>
</form>

<div id="help">
<p>When no background image is specified, a <a href="/files/default.jpg" target="_blank">default image</a> will be used. You can store your custom images in, for example, the root of your <a href="/vault/resources">Resources section</a> and then use '/resources/&lt;file name&gt;' as the URL.</p>
</div>
</xsl:template>

<!--
//
//  Content template
//
//-->
<xsl:template match="content">
<img src="/images/icons/adventure.png" class="title_icon" />
<h1>Your adventures</h1>
<xsl:apply-templates select="overview" />
<xsl:apply-templates select="edit" />
<xsl:apply-templates select="result" />
</xsl:template>

</xsl:stylesheet>
