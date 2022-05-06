<?xml version="1.0" ?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="../../banshee/main.xslt" />
<xsl:import href="../../includes/cauldron.xslt" />

<!--
//
//  Game template
//
//-->
<xsl:template match="game">
<!-- Menu -->
<div class="menu">
<span id="infobar"></span>
<div class="btn-group">
<a href="/cms/map/{map/@id}" class="btn btn-primary btn-xs">Edit settings</a>
<button class="btn btn-default btn-xs" onClick="javascript:toggle_constructs()">Toggle constructs</button>
<xsl:if test="map/type='video'"><button onClick="javascript:$('video').get(0).play()" class="btn btn-default btn-xs">Play</button></xsl:if>
<a href="/cms/map" class="btn btn-default btn-xs">Back</a>
</div>
</div>
<div class="windows">
<!-- Script -->
<xsl:call-template name="script_editor" />
<xsl:call-template name="script_manual" />
<!-- Zone create -->
<xsl:call-template name="zone_create" />
</div>
<!-- Play area -->
<div class="playarea" game_id="{@id}" map_id="{map/@id}" resources_key="{/output/cauldron/resources_key}" show_grid="{map/show_grid}" grid_cell_size="{@grid_cell_size}">
<xsl:if test="characters/@mine"><xsl:attribute name="my_char"><xsl:value-of select="characters/@mine" /></xsl:attribute></xsl:if>
<div>
<xsl:if test="map/type='image'"><xsl:attribute name="style">background-image:url(<xsl:value-of select="map/url" />); background-size:<xsl:value-of select="map/width" />px <xsl:value-of select="map/height" />px; width:<xsl:value-of select="map/width" />px; height:<xsl:value-of select="map/height" />px;</xsl:attribute></xsl:if>
<xsl:if test="map/type='video'"><xsl:attribute name="style">width:<xsl:value-of select="map/width" />px; height:<xsl:value-of select="map/height" />px;</xsl:attribute>
<video width="{map/width}" height="{map/height}" loop="true"><source src="{map/url}" /></video></xsl:if>
<!-- Grid -->
<div class="grid"></div>
<!-- Zones -->
<div class="zones">
<xsl:for-each select="zones/zone">
<div id="zone{@id}" class="zone" altitude="{altitude}" style="position:absolute; left:{pos_x}px; top:{pos_y}px; background-color:{color}; width:{width}px; height:{height}px; opacity:{opacity};"><xsl:if test="group!=''"><xsl:attribute name="group"><xsl:value-of select="group" /></xsl:attribute></xsl:if><div class="script"><xsl:value-of select="script" /></div></div>
</xsl:for-each>
</div>
<!-- Walls -->
<div class="walls">
<xsl:for-each select="walls/wall">
<div id="wall{@id}" class="wall" pos_x="{pos_x}" pos_y="{pos_y}" length="{length}" direction="{direction}" transparent="{transparent}" />
</xsl:for-each>
</div>
<!-- Doors -->
<div class="doors">
<xsl:for-each select="doors/door">
<div id="door{@id}" class="door" pos_x="{pos_x}" pos_y="{pos_y}" length="{length}" direction="{direction}" state="{state}" />
</xsl:for-each>
</div>
<!-- Lights -->
<div class="lights">
<xsl:for-each select="lights/light">
<img id="light{@id}" src="/images/light_{state}.png" class="light" radius="{radius}" state="{state}" style="position:absolute; left:{pos_x}px; top:{pos_y}px; width:{width}px; height:{height}px" />
</xsl:for-each>
</div>
<!-- Blinders -->
<div class="blinders">
<xsl:for-each select="blinders/blinder">
<div id="blinder{@id}" class="blinder" pos1_x="{pos1_x}" pos1_y="{pos1_y}" pos2_x="{pos2_x}" pos2_y="{pos2_y}" />
</xsl:for-each>
</div>
<!-- Conditions -->
<div class="conditions">
<xsl:for-each select="conditions/condition">
<div con_id="{@id}"><xsl:value-of select="." /></div>
</xsl:for-each>
</div>
<!-- Tokens -->
<div class="tokens">
<xsl:for-each select="tokens/token">
<div id="token{instance_id}" token_id="{@id}" class="token" style="left:{pos_x}px; top:{pos_y}px; display:none;" type="{type}" is_hidden="{hidden}" rotation="{rotation}" armor_class="{armor_class}" hitpoints="{hitpoints}" damage="{damage}" name="{name}">
<img src="/resources/{/output/cauldron/resources_key}/tokens/{@id}.{extension}" style="width:{width}px; height:{height}px" />
</div>
</xsl:for-each>
</div>
<!-- Characters -->
<div class="characters">
<xsl:for-each select="characters/character">
<div id="character{instance_id}" class="character" style="left:{pos_x}px; top:{pos_y}px;" is_hidden="{hidden}" rotation="{rotation}" armor_class="{armor_class}" hitpoints="{hitpoints}" damage="{damage}">
<img src="/resources/{/output/cauldron/resources_key}/characters/{@id}.{extension}" style="width:{../../@grid_cell_size}px; height:{../../@grid_cell_size}px;" />
<span class="name"><xsl:value-of select="name" /></span>
</div>
</xsl:for-each>
<div id="start" style="position:absolute; left:{map/start_x}px; top:{map/start_y}px;"><img src="/images/player_start.png" style="width:{@grid_cell_size}px; height:{@grid_cell_size}px;" /></div>
</div>
<!-- Fog of war -->
<div class="fog_of_war"></div>
</div>
<!-- Markers -->
<div class="markers"></div>
</div>
<!-- Right bar -->
<div class="filter"><input id="filter" placeholder="Filter tokens" class="form-control" onKeyUp="javascript:filter_library()" /></div>
<div class="library">
<xsl:for-each select="library/token">
<div class="well well-sm">
<img src="/resources/{/output/cauldron/resources_key}/tokens/{@id}.{extension}" title="{name}" style="max-width:{../../@grid_cell_size}px; max-height:{../../@grid_cell_size}px;" class="icon" token_id="{@id}" obj_width="{width}" obj_height="{height}" armor_class="{armor_class}" hitpoints="{hitpoints}" />
<div class="name"><xsl:value-of select="name" /></div>
<div>Width: <xsl:value-of select="width" /></div>
<div>Height: <xsl:value-of select="height" /></div>
</div>
</xsl:for-each>
</div>
<div class="sidebar">
</div>
</xsl:template>

<!--
//
//  Content template
//
//-->
<xsl:template match="content">
<h1><xsl:value-of select="/output/layout/title/@page" /> - <xsl:value-of select="game/map/title" /></h1>
<xsl:apply-templates select="game" />
<xsl:apply-templates select="result" />
</xsl:template>

</xsl:stylesheet>
