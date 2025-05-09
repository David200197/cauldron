<?xml version="1.0" ?>
<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--
//
//  Script editor template
//
//-->
<xsl:template name="script_editor">
<div class="script_editor" style="display:none">
<input id="zone_id" type="hidden" value="" />
<textarea class="form-control"></textarea>
<div class="row">
<div class="col-xs-6">
Zone group: <input id="zone_group" type="text" maxlength="10" onKeyUp="javascript:zone_group_change()" />
</div>
<div class="col-xs-6">
<div class="copy_script">Copy script to entire group: <input type="checkbox" id="copy_script" name="copy_script" /></div>
</div>
</div>
</div>
</xsl:template>

<!--
//
//  Script manual template
//
//-->
<xsl:template name="script_manual">
<div class="script_manual" style="display:none">
<p>A script consists of one or more lines, each containing a single command. A script can only be triggered by a character when it enters, moves inside, leaves the zone or is inside the zone on its combat turn. An object's ID can be obtained by selecting 'Get information' after a right click on that object. The following commands are available:</p>
<ul>
<li><b>audio &lt;file&gt;:</b> Play the audio file '/resources/audio/&lt;file&gt;'. Upload audio files via the Resources page in the Dungeon Master's Vault.</li>
<li><b>condition &lt;condition&gt;:</b> Character gains one of the following conditions:<div class="script_manual_conditions"><xsl:for-each select="conditions/condition"><span><xsl:value-of select="." /></span></xsl:for-each>.</div></li>
<li><b>damage &lt;points&gt;:</b> Damage the triggering character.</li>
<li><b>disable:</b> Don't run this script again for a next event.</li>
<li><b>event enter|move|turn|leave:</b> Only execute the next lines in the script under the specified condition: 'enter' when a character enteres the zone, 'move' when a character moves inside the zone, 'turn' when it's a character's turn during a battle while inside the zone or 'leave' when a character leaves the zone.</li>
<li><b>heal &lt;points&gt;:</b> Heal the triggering character.</li>
<li><b>move [+/-]&lt;x&gt;,[+/-]&lt;y&gt; [slide]:</b> Move the triggering character the x,y grid position. If there is a plus or minus sign in front of the x or y, the movement will be relative to the current position of the character. Adding 'slide' animates the movement, otherwise it's instant.</li>
<li><b>name &lt;name&gt;:</b> Use this name when sending messages via 'write' and 'write_all'.</li>
<li><b>token &lt;name&gt; show|hide:</b> Show or hide a token.</li>
<li><b>write &lt;message&gt;:</b> Write a message to the user of the triggering character. The Dungeon Master receives a copy of this message.</li>
<li><b>write_all &lt;message&gt;:</b> Write a message to everybody. In this message, the word 'character' will be replaced with the name of the triggering character.</li>
<li><b>write_dm &lt;message&gt;:</b> Write a message to the Dungeon Master. In this message, the word 'character' will be replaced with the name of the triggering character.</li>
<li><b>zone &lt;group&gt; show|hide:</b> Show or hide a zone group for the triggering character.</li>
</ul>
<p>You can add comments to your script. A comment line starts with a hash (#).</p>
<p>The zone group is an identifier that defines to what group a zone belongs. If a character leaves a zone and at the same time enters another zone that belongs to the same group, the leave and enter events are replaced with a single move event for the zone that the chararacter enters.</p>
</div>
</xsl:template>

<!--
//
//  Zone create template
//
//-->
<xsl:template name="zone_create">
<div class="zone_create" style="display:none">
<label for="width">Width:</label>
<input type="text" id="width" value="3" class="form-control" />
<label for="height">Height:</label>
<input type="text" id="height" value="3" class="form-control" />
<label for="color">Color:</label>
<input type="text" id="color" value="#ff0000" maxlength="7" class="form-control" />
<label for="opacity">Opacity:</label>
<input type="text" id="opacity" value="0.2" class="form-control" />
<label for="altitude">Altitude:</label>
<input type="text" id="altitude" value="0" class="form-control" />
<label for="group">Group:</label>
<input type="text" id="group" maxlength="10" class="form-control" />
</div>
</xsl:template>

</xsl:stylesheet>
