<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="../banshee/main.xslt" />
<xsl:import href="../banshee/pagination.xslt" />
<xsl:import href="../includes/adventures_pulldown.xslt" />

<!--
//
//  Overview template
//
//-->
<xsl:template match="overview">
<xsl:apply-templates select="adventures_pulldown" />

<div class="story">
<h1 class="print"><xsl:value-of select="adventures_pulldown/adventure[@selected='yes']" /></h1>
<div class="global"><xsl:value-of select="story" disable-output-escaping="yes" /></div>

<h2 class="players">Player characters</h2>
<div class="row players">
<xsl:for-each select="characters/character">
<div class="col-xs-12 col-md-4 col-lg-3">
<div class="well">
<xsl:if test="sheet_url!=''"><a href="{sheet_url}" target="_blank" title="{fullname}"><xsl:value-of select="name" /></a></xsl:if>
<xsl:if test="sheet_url=''"><span title="{fullname}"><xsl:value-of select="name" /></span></xsl:if>
</div>
</div>
</xsl:for-each>
</div>

<h2>Non-Player Characters</h2>
<xsl:for-each select="npcs/npc">
<div class="row">
<div class="item">
<a href="/{/output/page}/npc/{@id}">
<div class="col-xs-9 col-md-5 header title npc_name"><xsl:value-of select="name" /></div>
<div class="col-xs-3  col-md-2 header cr"><xsl:value-of select="cr" /></div>
<div class="col-xs-12 col-md-5 header type"><xsl:value-of select="type" /></div>
</a>
<div class="col-xs-12 body"><xsl:value-of select="description" disable-output-escaping="yes" /></div>
</div>
</div>
</xsl:for-each>
<div class="row add">
<div class="col-xs-12"><a href="/{/output/page}/npc/new" class="btn btn-default">+</a></div>
</div>
</div>

<div class="story">
<h2>Objects and locations</h2>
<div class="sortable" type="objects">
<xsl:for-each select="objects/object">
<div class="row">
<div class="item" item_id="{@id}">
<a href="/{/output/page}/object/{@id}">
<div class="col-xs-8 header title name"><xsl:value-of select="name" /></div>
<div class="col-xs-3 header located"><xsl:value-of select="located" /></div>
<div class="col-xs-1 header handle"><span class="fa fa-arrows-v"></span></div>
</a>
<div class="col-xs-12 body"><xsl:value-of select="description" disable-output-escaping="yes" /></div>
</div>
</div>
</xsl:for-each>
</div>
<div class="row add">
<div class="col-xs-12"><a href="/{/output/page}/object/new" class="btn btn-default">+</a></div>
</div>
</div>

<div class="story">
<h2>Events</h2>
<div class="sortable" type="events">
<xsl:for-each select="events/event">
<div class="row">
<div class="item" item_id="{@id}">
<a href="/{/output/page}/event/{@id}">
<div class="col-xs-9 header title name"><xsl:value-of select="title" /></div>
<div class="col-xs-2 header nr"><xsl:value-of select="total_xp" /></div>
<div class="col-xs-1 header handle"><span class="fa fa-arrows-v"></span></div>
</a>
<div class="col-xs-12 body"><xsl:value-of select="description" disable-output-escaping="yes" /></div>
</div>
</div>
</xsl:for-each>
</div>
<div class="row add">
<div class="col-xs-12"><a href="/{/output/page}/event/new" class="btn btn-default">+</a></div>
</div>
</div>

<div class="story">
<h2>Encounters</h2>
<xsl:for-each select="encounters/encounter">
<div class="row">
<div class="item">
<a href="/{/output/page}/encounter/{@id}">
<div class="col-xs-9 header title"><xsl:value-of select="title" /></div>
<div class="col-xs-3 header xp"><xsl:value-of select="total_xp" /> XP</div>
</a>
<xsl:for-each select="monsters/item">
<div class="col-xs-2  col-md-1 count"><xsl:value-of select="count" /> &#xd7;</div>
<div class="col-xs-10 col-md-6 monster"><xsl:value-of select="monster" /></div>
<div class="col-xs-3  col-md-2 source"><xsl:value-of select="source" /></div>
<div class="col-xs-3  col-md-1 cr">CR <xsl:value-of select="cr" /></div>
<div class="col-xs-3  col-md-1 xp"><xsl:value-of select="xp" /> XP</div>
<div class="col-xs-3  col-md-1 xp"><xsl:value-of select="total_xp" /> XP</div>
</xsl:for-each>
</div>
</div>
</xsl:for-each>
<div class="row add">
<div class="col-xs-12"><a href="/{/output/page}/encounter/new" class="btn btn-default">+</a></div>
</div>
</div>

<div class="btn-group">
<a href="/{/output/page}/edit" class="btn btn-default">Edit main story</a>
<button class="btn btn-default" onClick="javascript:window.print()">Print</button>
<a href="/vault" class="btn btn-default">Back</a>
</div>

<div id="help">
<p>This page allows you to structure the important elements of your home brew campaign. Print this page (to PDF) to get a nice formated overview.</p>
<h3>Non-Player Characters</h3>
<p>It's good to list all the relevant non-player characters, such as the bad guys, the ones that send the players in the right direction or commoners they can meet along the way. You can group them by using a keyword surrounded by brackets in front of the NPC's name, like "[Red Wizards] Szass Tam".</p>
<h3>Objects and locations</h3>
<p>List all the important locations and objects that can be found there.</p>
<h3>Events</h3>
<p>Describe all the possible events that can happen during the adventure, like parts of the main quest, side quests, decision making points or objectives to reach.</p>
<h3>Encounters</h3>
<p>This section allows you to create possible encounters. It calculates the total XP of the encouter for you.</p>
</div>
</xsl:template>

<!--
//
//  Edit story
//
//-->
<xsl:template match="edit_story">
<xsl:call-template name="show_messages" />
<form action="/{/output/page}" method="post">
<input type="hidden" name="id" value="{adventure/@id}" />
<input type="hidden" name="title" value="{adventure/title}" />

<label for="story">Global description of the adventure:</label>
<textarea id="story" name="story" class="form-control"><xsl:value-of select="adventure/story" /></textarea>

<div class="btn-group">
<input type="submit" name="submit_button" value="Save story" class="btn btn-default" />
<a href="/{/output/page}" class="btn btn-default">Cancel</a>
</div>
</form>
</xsl:template>

<!--
//
//  Edit NPC
//
//-->
<xsl:template match="edit_npc">
<xsl:call-template name="show_messages" />
<form action="/{/output/page}" method="post">
<xsl:if test="npc/@id">
<input type="hidden" name="id" value="{npc/@id}" />
</xsl:if>

<label for="name">Name:</label>
<input type="text" id="name" name="name" value="{npc/name}" class="form-control" />
<label for="cr">Challenge Rating:</label>
<input type="text" id="cr" name="cr" value="{npc/cr}" class="form-control cr" />
<label for="type">Race, sex and/or class:</label>
<input type="text" id="type" name="type" value="{npc/type}" class="form-control" />
<label for="description">Background, intentions, plans and/or role in the adventure:</label>
<textarea id="description" name="description" class="form-control"><xsl:value-of select="npc/description" /></textarea>

<div class="btn-group">
<input type="submit" name="submit_button" value="Save NPC" class="btn btn-default" />
<a href="/{/output/page}" class="btn btn-default">Cancel</a>
<xsl:if test="npc/@id">
<input type="submit" name="submit_button" value="Delete NPC" class="btn btn-default" onClick="javascript:return confirm('DELETE: Are you sure?')" />
</xsl:if>
</div>
</form>
</xsl:template>

<!--
//
//  Edit object
//
//-->
<xsl:template match="edit_object">
<xsl:call-template name="show_messages" />
<form action="/{/output/page}" method="post">
<xsl:if test="object/@id">
<input type="hidden" name="id" value="{object/@id}" />
</xsl:if>

<label for="name">Name:</label>
<input type="text" id="name" name="name" value="{object/name}" class="form-control" />
<label for="located">Located in:</label>
<input type="text" id="located" name="located" value="{object/located}" class="form-control" />
<label for="description">Description:</label>
<p>If this is an object, what does it look like and what is it for? If this is a location, what does it look like, what's happening here and what can be found here?</p>
<textarea id="description" name="description" class="form-control"><xsl:value-of select="object/description" /></textarea>

<div class="btn-group">
<input type="submit" name="submit_button" value="Save object" class="btn btn-default" />
<a href="/{/output/page}" class="btn btn-default">Cancel</a>
<xsl:if test="object/@id">
<input type="submit" name="submit_button" value="Delete object" class="btn btn-default" onClick="javascript:return confirm('DELETE: Are you sure?')" />
</xsl:if>
</div>
</form>
</xsl:template>

<!--
//
//  Edit event
//
//-->
<xsl:template match="edit_event">
<xsl:call-template name="show_messages" />
<form action="/{/output/page}" method="post">
<xsl:if test="event/@id">
<input type="hidden" name="id" value="{event/@id}" />
</xsl:if>

<label for="title">Title:</label>
<input type="text" id="title" name="title" value="{event/title}" class="form-control" />
<label for="description">Event:</label>
<textarea id="description" name="description" class="form-control"><xsl:value-of select="event/description" /></textarea>

<div class="btn-group">
<input type="submit" name="submit_button" value="Save event" class="btn btn-default" />
<a href="/{/output/page}" class="btn btn-default">Cancel</a>
<xsl:if test="event/@id">
<input type="submit" name="submit_button" value="Delete event" class="btn btn-default" onClick="javascript:return confirm('DELETE: Are you sure?')" />
</xsl:if>
</div>
</form>
</xsl:template>

<!--
//
//  Edit encounter
//
//-->
<xsl:template match="edit_encounter">
<xsl:call-template name="show_messages" />
<form action="/{/output/page}" method="post">
<xsl:if test="encounter/@id">
<input type="hidden" name="id" value="{encounter/@id}" />
</xsl:if>

<label for="title">Title:</label>
<input type="text" id="title" name="title" value="{encounter/title}" class="form-control" />

<div class="monsters">
<xsl:for-each select="encounter/monsters/item">
<div class="panel panel-primary"><div class="panel-body">
<label>Monster:</label>
<input type="text" name="monsters[{position()}][monster]" value="{monster}" class="form-control" />
<label>Number of monsters:</label>
<input type="text" name="monsters[{position()}][count]" value="{count}" class="form-control" />
<label>Source:</label>
<input type="text" name="monsters[{position()}][source]" value="{source}" class="form-control" />
<label for="cr">Challenge Rating:</label>
<input type="text" name="monsters[{position()}][cr]" value="{cr}" class="form-control cr" />
</div></div>
</xsl:for-each>
</div>

<div class="row add">
<div class="col-xs-12"><input type="button" value="+" class="btn btn-default" onClick="javascript:add_monster(); return false;" /></div>
</div>

<div class="btn-group">
<input type="submit" name="submit_button" value="Save encounter" class="btn btn-default" />
<a href="/{/output/page}" class="btn btn-default">Cancel</a>
<xsl:if test="encounter/@id">
<input type="submit" name="submit_button" value="Delete encounter" class="btn btn-default" onClick="javascript:return confirm('DELETE: Are you sure?')" />
</xsl:if>
</div>
</form>
</xsl:template>

<!--
//
//  Challenge Rating template
//
//-->
<xsl:template match="challenge_rating">
<crs style="display:none">
<xsl:for-each select="cr">
<cr><xsl:value-of select="." /></cr>
</xsl:for-each>
</crs>
</xsl:template>

<!--
//
//  Content template
//
//-->
<xsl:template match="content">
<h1><xsl:value-of select="/output/layout/title/@page" /></h1>
<xsl:apply-templates select="overview" />
<xsl:apply-templates select="edit_story" />
<xsl:apply-templates select="edit_npc" />
<xsl:apply-templates select="edit_object" />
<xsl:apply-templates select="edit_event" />
<xsl:apply-templates select="edit_encounter" />
<xsl:apply-templates select="challenge_rating" />
<xsl:apply-templates select="result" />
</xsl:template>

</xsl:stylesheet>
