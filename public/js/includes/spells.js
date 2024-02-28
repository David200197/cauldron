const spell_schools = {
	A: 'Abjuration',
	C: 'Conjuration',
	D: 'Divination',
	E: 'Enchantment',
	I: 'Illusion',
	N: 'Necromancy',
	T: 'Transmutation',
	V: 'Evocation'
};
const spell_sources = {
	BMT: 'Book of Many Things',
	FTD: 'Fizban\'s Treasury of Dragons',
	PHB: 'Player\s Handbook',
	SCC: 'Strixhaven: A Curriculum of Chaos',
	TCE: 'Tasha\'s Cauldron of Everything',
	XGE: 'Xanathar\'s Guide to Everything'
};

var _spells_window = null;
var _spells_list = {};

function spell_roll_dice(dice) {
	_spells_window.close();

	roll_dice(dice, dungeon_master == false);
}

function spell_change(spell) {
	$('div.spells select option').each(function() {
		if (spell.toLowerCase() == $(this).text().toLowerCase()) {
			$('div.spells select').val($(this).text());
			$('div.spells select').trigger('change');
			$('div.spells').parent().scrollTop(0);
		}
	});
}

function _spell_rewrite_entry(entry) {
	var pos, end;

	if (typeof entry == 'object') {
		if (entry.type == 'list') {
			var result = '<ul>';
			entry.items.forEach(function(item) {
				result += '<li>' + _spell_rewrite_entry(item) + '</li>';
			});
			result += '</ul>';

			return result;
		}
		return;
	}

	while ((pos = entry.lastIndexOf('{@')) != -1) {
		if ((end = entry.indexOf('}', pos)) == -1) {
			break;
		}
		end++;

		var item = entry.substr(pos + 1, end - pos - 2);
		var parts = item.split(' ');
		var type = parts.shift();
		item = parts.join(' ');

		switch (type) {
			case '@book':
			case '@chance':
			case '@classFeature':
			case '@creature':
			case '@filter':
			case '@item':
			case '@quickref':
			case '@scaledice':
				parts = item.split('|');
				item = parts.shift();
				break;
			case '@d20':
				item = '+' + item;
				break;
			case '@damage':
				item = '<a href="javascript:spell_roll_dice(\'' + item + '\')">' + item + '</a>';
				break;
			case '@scaledamage':
			case '@status':
				parts = item.split('|');
				item = parts.pop();
				break;
			case '@spell':
				item = '<a href="javascript:spell_change(\'' + item + '\')">' + item + '</a>';
				break;
		}

		entry = entry.substr(0, pos) + item + entry.substr(end);

		pos = pos + item.length;
	}

	return entry;
}

function _spell_show_details(name) {
	var spell = _spells_list[name];

	var details = $('<div></div>');

	details.append('<h2>' + name + '</h2>');

	/* Level and school
	 */
	var type = spell_schools[spell.school];
	if (spell.level == 0) {
		type += ' cantrip';
	} else {
		if (spell.level == 1) {
			var nr = 'st';
		} else if (spell.level == 2) {	
			var nr = 'nd';
		} else {
			var nr = 'th';
		}
		type = spell.level + nr + '-level ' + type.toLowerCase();
	}
	details.append('<div>' + type + '</div>');

	/* Casting time
	 */
	details.append('<div><b>Casting time:</b> ' + spell.time[0]["number"] + ' ' + spell.time[0]["unit"] + '</div>');

	/* Range
	 */
	if (spell.range.type == 'special') {
		var range = 'Special';
	} else {
		var range = spell.range["distance"]["type"];
		if (spell.range["distance"]["amount"] != undefined) {
			range = spell.range["distance"]["amount"] + ' ' + range;
		}
	}
	details.append('<div><b>Range:</b> ' + range + '</div>');

	/* Components
	 */
	var components = [];
	if (spell.components.v) {
		components.push('V');
	}
	if (spell.components.s) {
		components.push('S');
	}
	if (spell.components.m === true) {
		components.push('M');
	} else if (typeof spell.components.m == 'string') {
		components.push('M (' + spell.components.m + ')');
	} else if (typeof spell.components.m == 'object') {
		components.push('M ' + spell.components.m.text);
	}
	details.append('<div><b>Components:</b> ' + components.join(', ') + '</div>');

	/* Duration
	 */
	var spell_duration = [];
	spell.duration.forEach(function(duration) {
		switch (duration.type) {
			case 'instant':
				spell_duration.push('Instantaneous');
				break;
			case 'special':
				spell_duration.push('Special');
				break;
			case 'timed':
				var timed = '';
				if (duration.concentration) {
					timed += 'Concentration, up to ';
				}
				timed += duration.duration.amount + ' ' + duration.duration.type;
				if (duration.duration.amount > 1) {
					timed += 's';
				}
				spell_duration.push(timed);
				break;
		}
	});
	details.append('<div><b>Duration:</b> ' + spell_duration.join(' or ') + '</div>');

	details.append('<hr />');

	/* Description
	 */
	spell.entries.forEach(function(entry) {
		switch (typeof entry) {
			case 'string':
				details.append('<p>' + _spell_rewrite_entry(entry) + '</p>');
				break;
			case 'object':
				if (entry.type == 'entries') {
					details.append('<p><b>' + entry.name + '</b></p>');
					entry.entries.forEach(function(line) {
						details.append('<p>' + _spell_rewrite_entry(line) + '</p>');
					});
				} else if (entry.type == 'list') {
					details.append('<ul></ul>');
					var ul = details.find('ul').last();
					entry.items.forEach(function(item) {
						ul.append('<li>' + _spell_rewrite_entry(item) + '</li>');
					});
				}
				break;
		}
	});

	/* At higher levels
	 */
	if (typeof spell.entriesHigherLevel != 'undefined') {
		var higher = '<p><b>' + spell.entriesHigherLevel[0].name + '</b>. ';
		spell.entriesHigherLevel[0].entries.forEach(function(entry) {
			higher += _spell_rewrite_entry(entry);
		});
		higher += '</p>';
		details.append(higher);
	}

	details.append('<hr />');

	/* Source
	 */
	details.append('<p><b>Source:</b> ' + spell_sources[spell.source] + ', page ' + spell.page + '</p>');

	var container = $('div.spells div.details');
	container.empty();
	container.append(details);
}

$(window).ready(function() {
	$.get('/data/spells', function(data) {
		var spells = JSON.parse($(data).text().replaceAll('&amp;', '&'));

		var content = $('<div class="spells"><input type="text" class="form-control" placeholder="Filter" /><div class="select"></div><div class="details"></div></div>');
		var list = content.find('div.select');

		spells.forEach(function(spell) {
			_spells_list[spell.name] = spell;

			var item = '<div>' + spell.name + '</div>';
			list.append(item);
		});

		list.find('div').on('click', function() {
			$('div.spells div.select div').removeClass('selected');
			$(this).addClass('selected');

			_spell_show_details($(this).text());
		});

		_spells_window = $(content).windowframe({	
			activator: 'button.show_spells',
			header: 'Dungeons & Dragons 5e spells',
			style: 'warning',
			width: 800
		});

		$('div.spells input').on('keyup', function() {
			$('div.spells div.select div').show();

			var filter = $(this).val().toLowerCase();
			$('div.spells div.select div').each(function() {
				if ($(this).text().toLowerCase().includes(filter) == false) {
					$(this).hide();
				}
			});
		});

		list.find('div').first().trigger('click');
	});
});

/* Fog of War interface
 */
function show_spells() {
	_spells_window.open();
}
