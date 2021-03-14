<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="banshee/main.xslt" />

<!--
//
//  Overview template
//
//-->
<xsl:template match="overview">
<div class="row">
<xsl:for-each select="characters/character">
<div class="col-md-4 col-sm-6 col-xs-12">
<div class="well" onClick="javascript:document.location='/{/output/page}/{@id}'">
<img src="/files/characters/{@id}.{extension}" class="icon" />
<div class="name"><xsl:value-of select="name" /></div>
<div>Hit points: <xsl:value-of select="hitpoints" /></div>
<div>Armor class: <xsl:value-of select="armor_class" /></div>
<div>Initiative bonus: <xsl:value-of select="initiative" /></div>
<div><a href="/character/alternate/{@id}">Alternate icons</a></div>
<div class="game">Game: <span><xsl:value-of select="title" /></span></div>
</div>
</div>
</xsl:for-each>
</div>

<div class="btn-group left">
<a href="/{/output/page}/new" class="btn btn-default">New character</a>
</div>
</xsl:template>

<!--
//
//  Edit template
//
//-->
<xsl:template match="edit">
<xsl:call-template name="show_messages" />
<form action="/{/output/page}" method="post" enctype="multipart/form-data">
<xsl:if test="character/@id">
<input type="hidden" name="id" value="{character/@id}" />
<input type="hidden" name="extension" value="{character/extension}" />
<img src="/files/characters/{character/@id}.{character/extension}" class="icon" />
</xsl:if>

<label for="name">Name:</label>
<input type="text" id="name" name="name" value="{character/name}" class="form-control" />
<label for="hitpoints">Hit points:</label>
<input type="text" id="hitpoints" name="hitpoints" value="{character/hitpoints}" class="form-control" />
<label for="armor_class">Armor class:</label>
<input type="text" id="armor_class" name="armor_class" value="{character/armor_class}" class="form-control" />
<label for="initiative">Initiative bonus:</label>
<input type="text" id="initiative" name="initiative" value="{character/initiative}" class="form-control" />
<label for="icon">Icon (make sure the token is facing down):</label>
<div class="input-group">
<span class="input-group-btn"><label class="btn btn-default">
<input type="file" name="icon" style="display:none" class="form-control" onChange="$('#upload-file-info').val(this.files[0].name)" />Browse</label></span>
<input type="text" id="upload-file-info" readonly="readonly" class="form-control" />
</div>

<div class="btn-group">
<input type="submit" name="submit_button" value="Save character" class="btn btn-default" />
<a href="/{/output/page}" class="btn btn-default">Cancel</a>
<xsl:if test="character/@id">
<input type="submit" name="submit_button" value="Delete character" class="btn btn-default" onClick="javascript:return confirm('DELETE: Are you sure?')" />
</xsl:if>
</div>
</form>
</xsl:template>

<!--
//
//  Alternates template
//
//-->
<xsl:template match="alternates">
<xsl:call-template name="show_messages" />
<p>Alternate icons for <xsl:value-of select="@character" />.</p>
<div class="row alternates">
<xsl:for-each select="alternate">
<div class="col-md-2 col-sm-3 col-xs-6"><div class="alternate"><img src="/files/characters/{character_id}_{@id}.{extension}" class="icon" /><span><xsl:value-of select="name" /></span><span><xsl:value-of select="size" /></span><form action="/{/output/page}" method="post"><input type="hidden" name="icon_id" value="{@id}" /><input type="submit" name="submit_button" value="delete" class="btn btn-default btn-xs" onClick="javascript:return confirm('DELETE: Are you sure?')" /></form></div></div>
</xsl:for-each>
</div>

<form action="/{/output/page}" method="post"  enctype="multipart/form-data">
<input type="hidden" name="char_id" value="{@char_id}" />
<label for="name">Name:</label>
<input type="text" id="name" name="name" value="{character/name}" class="form-control" />
<label for="size">Size:</label>
<select name="size" class="form-control"><xsl:for-each select="sizes/size"><option value="{@value}"><xsl:value-of select="." /></option></xsl:for-each></select>
<label for="icon">Alternate icon (make sure the token is facing down):</label>
<div class="input-group">
<span class="input-group-btn"><label class="btn btn-default">
<input type="file" name="icon" style="display:none" class="form-control" onChange="$('#upload-file-info').val(this.files[0].name)" />Browse</label></span>
<input type="text" id="upload-file-info" readonly="readonly" class="form-control" />
</div>

<div class="btn-group">
<input type="submit" name="submit_button" value="Add icon" class="btn btn-default" />
<a href="/character" class="btn btn-default">Back</a>
</div>
</form>
</xsl:template>

<!--
//
//  Content template
//
//-->
<xsl:template match="content">
<h1>Characters</h1>
<xsl:apply-templates select="overview" />
<xsl:apply-templates select="edit" />
<xsl:apply-templates select="alternates" />
<xsl:apply-templates select="result" />
</xsl:template>

</xsl:stylesheet>
