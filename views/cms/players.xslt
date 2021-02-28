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
<table class="table table-condensed table-striped">
<thead>
<tr><th>Title</th><th>Players</th></tr>
</thead>
<tbody>
<xsl:for-each select="games/game">
<tr>
<xsl:if test="players=0">
<xsl:attribute name="class">click</xsl:attribute>
<xsl:attribute name="onClick">javascript:document.location='/<xsl:value-of select="/output/page" />/<xsl:value-of select="@id" />'</xsl:attribute>
</xsl:if>
<td><xsl:value-of select="title" /></td>
<td><xsl:value-of select="players" /></td>
</tr>
</xsl:for-each>
</tbody>
</table>

<div class="btn-group left">
<a href="/cms" class="btn btn-default">Back</a>
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
<input type="hidden" name="game_id" value="{game/@id}" />

<p>Make sure this invite contains all required characters, as it can only be done once per game!</p>

<label for="title">Characters:</label>
<div class="row">
<xsl:for-each select="characters/user">
<div class="col-xs-12 col-sm-6 col-md-4">
<div class="panel panel-default">
<div class="panel-heading"><xsl:value-of select="@name" /></div>
<div class="panel-body">
<xsl:for-each select="character">
<div><input type="checkbox" name="characters[]" value="{@id}"><xsl:if test="@checked='yes'"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input><xsl:value-of select="." /></div>
</xsl:for-each>
</div>
</div>
</div>
</xsl:for-each>
</div>

<div class="btn-group">
<input type="submit" name="submit_button" value="Invite players" class="btn btn-default" />
<a href="/{/output/page}" class="btn btn-default">Cancel</a>
<xsl:if test="game/@id">
</xsl:if>
</div>
</form>
</xsl:template>

<!--
//
//  Content template
//
//-->
<xsl:template match="content">
<img src="/images/icons/players.png" class="title_icon" />
<h1>Invite players</h1>
<xsl:apply-templates select="overview" />
<xsl:apply-templates select="edit" />
<xsl:apply-templates select="result" />
</xsl:template>

</xsl:stylesheet>
