const COMBAT_MAX_ENEMIES = 5;

var _combat_window_init = null;
var _combat_window_remove = null;
var _combat_max_entries = COMBAT_MAX_ENEMIES;
var _combat_order = [];
var _combat_not_started = 'No combat has been started. Use the /combat command.';
var _combat_name = "Combat Tracker";
var _combat_sidebar_bottom = null;

function _combat_add_table_entry(name = '', bonus = 0, char_id = 0) {
	var readonly = (name == '') ? '' : 'disabled="disabled" ';

	if (char_id != 0) {
		char_id = ' char_id="' + char_id + '"';
	} else {
		char_id = '';
	}

	var cell = '<tr' + char_id + '><td><input type="text" value="' + name + '" ' + readonly + 'class="form-control input-sm" /></td>' +
			   '<td><input type="text" value="' + bonus + '" class="form-control input-sm" /></td></tr>';
	$('table.combat-tracker tbody').append(cell);

	if ($('table.combat-tracker tbody tr').length >= _combat_max_entries) {
		var button = $('table.combat-tracker + div.btn-group button:nth-child(2)');
		button.addClass('disabled');
		button.off('click');
	}
}

function _combat_window_reset() {
	$('table.combat-tracker tbody').empty();
	$('div.character').each(function() {
		var name = $(this).find('span').text();
		var bonus = parseInt($(this).attr('initiative'));
		_combat_add_table_entry(name, bonus, $(this).attr('char_id'));
	});

	_combat_add_table_entry();
	_combat_add_table_entry();
	_combat_add_table_entry();

	var next = $('div.character').length + 1;
	$('table.combat-tracker tbody tr').filter(':nth-child(' + next + ')').find('input[type=text]').first().focus();

	var button = $('table.combat-tracker + div.btn-group button:nth-child(2)');
	if (button.hasClass('disabled')) {
		button.removeClass('disabled');
		button.on('click', function() {
			_combat_add_table_entry();
		});
	}

	_combat_window_init.footer(null);
}

function _combat_send_turn() {
	if (_combat_order[0].char_id != undefined) {
		var data = {
			action: 'turn',
			char_id: _combat_order[0].char_id
		};
		websocket_send(data);
	}
}

function _combat_stop() {
	_combat_order = [];
	localStorage.removeItem('combat_order');
	localStorage.removeItem('combat_adventure_id');
}

function combat_stop() {
	if (dungeon_master) {
		_combat_stop();
		_combat_remove_buttons();

		var data = {
			action: 'done'
		};
		websocket_send(data);
	} else {
		temporary_hitpoints = 0;
	}

	message_to_sidebar('Dungeon Master', 'The combat is over.');
}

function _combat_add_buttons() {
	var buttons = $('<div class="combat-buttons"><div class="btn-group">' +
		'<button class="btn btn-primary btn-xs next" title="Next">&gt;</button>' +
		'<button class="btn btn-primary btn-xs add" title="Add">+</button>' +
		'<button class="btn btn-primary btn-xs remove" title="Remove">-</button>' +
		'<button class="btn btn-primary btn-xs stop" title="End">&times;</button>' +
		'</div></div>');

	buttons.find('button.next').on('click', function() {
		combat_next();
	});

	buttons.find('button.add').on('click', function() {
		cauldron_prompt('New monster\'s name:', '', function(name) {
			if (name != '') {
				combat_add(name);
			}
		});
	});

	buttons.find('button.remove').on('click', function() {
		var list = _combat_window_remove.find('ul');
		list.empty();
		_combat_order.forEach(function(value) {
			list.append('<li class="list-group-item">' + value.name + '</li>');
		});

		_combat_window_remove.find('li').on('click', function() {	
			combat_remove($(this).text());
			_combat_window_remove.close();
		});

		_combat_window_remove.open();
	});

	buttons.find('button.stop').on('click', function() {
		cauldron_confirm('End the combat?', function() {
			combat_stop();
		});
	});

	_combat_sidebar_bottom = $('div.sidebar').css('bottom');
	var size = parseInt(_combat_sidebar_bottom.substr(0, _combat_sidebar_bottom.length - 2));
	$('div.sidebar').css('bottom', (size + 20).toString() + 'px');

	$('div.sidebar').after(buttons);
}

function _combat_remove_buttons() {
	$('div.combat-buttons').remove();
	$('div.sidebar').css('bottom', _combat_sidebar_bottom);
}

$(document).ready(function() {
	if (dungeon_master == false) {
		return;
	}

	_combat_max_entries += $('div.character').length;

	var form = '<table class="table table-condensed combat-tracker">' +
			   '<thead><tr><th>Character / group name</th><th>Initiative bonus</th></tr></thead>' +
			   '<tbody></tbody></tbody></table>';

	_combat_window_init = $(form).windowframe({
		header: 'Start a new combat',
		info: '<p>If you remove a character\'s initiative bonus, that character will not be included in the combat.</p>' +
		      '<p>If you want a character or enemy to go first, give it a very high initiative bonus. If you want it to ' +
		      'go last, give it a very high negative initiative bonus.</p>' +
			  '<p>Canceling the combat resets the form. Close the window to keep the data.</p>',
		top: 75,
		buttons: {
			'Start combat': function() {
				_combat_order = [];
				var error = null;
				$('table.combat-tracker tbody tr').each(function() {
					var name = $(this).find('td:first-child input').val();
					var bonus = $(this).find('td:last-child input').val();
					if ((name == '') || (bonus == '')) {
						return true;
					}

					var present = false;
					_combat_order.forEach(function(value, key) {
						if (value.name == name) {
							present = true;
						}
					});
					if (present) {
						error = name + ' is mentioned more than once.';
						return false;
					}

					bonus = parseInt(bonus);
					if (isNaN(bonus)) {
						error = 'Invalid initiative bonus value.';
						return false;
					}

					var roll = Math.floor(Math.random() * 20) + 1 + bonus;
					roll = roll.toString();
					while (roll.length < 2) {
						roll = '0' + roll;
					}

					var char_id = $(this).attr('char_id');

					var item = {
						key: roll + '-enemy',
						name: name,
						char_id: char_id
					}
					_combat_order.push(item);
				});

				if (_combat_order.length == 0) {
					error = 'Combat list is empty.';
				}

				if (error !== null) {
					error = '<font color="red">' + error + '</font>';
					_combat_window_init.footer(error);
					_combat_order = [];
					return;
				}

				_combat_order.sort((a, b) => b.key.localeCompare(a.key));

				combat_show_order(true);

				_combat_send_turn();
				_combat_add_buttons();
				_combat_window_reset();

				localStorage.setItem('combat_order', JSON.stringify(_combat_order));
				localStorage.setItem('combat_adventure_id', adventure_id);

				$(this).close();
			},
			'Add entry': function() {
				_combat_add_table_entry();
			},
			'Cancel': function() {
				$(this).close();
				_combat_window_reset();
			}
		}
	});

	_combat_window_reset();

	var remove = $('<div class="combat-remove"><ul class="list-group"></div></div>');
	_combat_window_remove = $(remove).windowframe({
		'header': 'Remove from Combat Tracker',
		width: 300
	});
});

/* Combat interface
 */
function combat_check_running() {
	var bo = localStorage.getItem('combat_order');
	if (bo == undefined) {
		return;
	}

	var bg = localStorage.getItem('combat_adventure_id');
	if (bg == undefined) {
		_combat_stop();
		return;
	} else if (bg != adventure_id) {
		_combat_stop();
		return;
	}

	_combat_order = JSON.parse(bo);
	combat_show_order(false, false);

	_combat_add_buttons();
}

function combat_start() {
	if ($('div.character').length == 0) {
		write_sidebar('This map has no characters.');
		return;
	}

	if (_combat_order.length > 0) {
		write_sidebar('A combat has already been started. Type /next to go to the next round or /done to finish the current combat.');
		combat_show_order(false, false);
		return;
	}

	_combat_window_init.open();
}

function combat_show_order(first_round = false, send = true) {
	if (first_round) {
		send_message('Prepare for combat!', 'Dungeon Master', false);
	}

	var message = '';
	var bullet = '&Rightarrow;';
	_combat_order.forEach(function(value, key) {
		message += bullet + ' ' + value.name + '\n';
		bullet = '&boxh;';
	});

	if (send) {
		send_message(message, _combat_name);
	} else {
		message_to_sidebar(_combat_name, message);
	}
}

function combat_add(being) {
	if (_combat_order.length == 0) {
		write_sidebar(_combat_not_started);
		return;
	}

	var present = false;
	_combat_order.forEach(function(value, key) {
		if (value.name == being) {
			present = true;
		}
	});
	if (present) {
		write_sidebar(being + ' is already in the combat order list.');
		return false;
	}

	var item = _combat_order.shift();
	_combat_order.push(item);

	item = {
		key: 0,
		name: being,
		char_id: null
	};
	_combat_order.unshift(item);

	combat_show_order();

	localStorage.setItem('combat_order', JSON.stringify(_combat_order));
}

function combat_remove(being) {
	if (_combat_order.length == 0) {
		write_sidebar(_combat_not_started);
		return;
	}

	var remove = null;
	var found = false;
	_combat_order.forEach(function(value, key) {
		if (found == false) {
			if (value.name == being) {
				remove = key;
				found = true;
			} else if (value.name.substring(0, being.length) == being) {
				if (remove == null) {
					remove = key;
				}
			}
		}
	});

	if (remove == null) {
		write_sidebar(being + ' not in combat order.');
		$('div.input input').val(input);
		return;
	}

	send_message(_combat_order[remove].name + ' removed from combat.', _combat_name);
	_combat_order.splice(remove, 1);

	if (_combat_order.length == 0) {
		combat_stop();
	} else {
		combat_show_order(false, false);

		localStorage.setItem('combat_order', JSON.stringify(_combat_order));
	}
}

function combat_next(being = '') {
	if (_combat_order.length == 0) {
		write_sidebar(_combat_not_started);
		return;
	}

	var turn = null;
	if (being != '') {
		_combat_order.forEach(function(value, key) {
			if (value.name.substring(0, being.length) == being) {
				turn = key;
			}
		});

		if (turn == null) {
			write_sidebar(being + ' not in combat order list.');
			$('div.input input').val(input);
			return;
		}

		if (turn == 0) {
			write_sidebar('Already its turn.');
			return;
		}

		turn -= 1;
	}

	var item = _combat_order.shift();
	_combat_order.push(item);

	if (turn != null) {
		var item = _combat_order[turn];
		_combat_order.splice(turn, 1);
		_combat_order.unshift(item);
	}

	combat_show_order();

	_combat_send_turn();

	localStorage.setItem('combat_order', JSON.stringify(_combat_order));
}
