const DICE_ROLL_NORMAL = 0;
const DICE_ROLL_ADVANTAGE = 1;
const DICE_ROLL_DISADVANTAGE = 2;

var wf_dice_roll = null;

function dice_roll(dice, addition, callback) {
	if ((localStorage.getItem('dice_type') == 'animated') && (typeof dice_roll_3d == 'function')) {
		return dice_roll_3d(dice, addition, callback);
	} else {
		return dice_roll_quick(dice, addition, callback);
	}
}

function dice_roll_quick(dice, addition, callback) {
	var result = [];

	for (i = 0; i < dice.length; i++) {
		var parts = dice[i].split('d');
		var count = parseInt(parts[0]);
		var sides = parseInt(parts[1]);
		var roll = Math.floor(Math.random() * sides) + 1;

		result.push(roll);
	}

	callback(result, addition);
}

function roll_dice(dice_input, send_to_others = true) {
	if (dice == '') {
		wf_dice_roll.open();
		return true;
	}

	if (dice_input.indexOf('d') == -1) {
		return false;
	}

	dice_str = dice_input.replace(/ /g, '');
	dice_str = dice_str.replace(/\+-/g, '-');
	dice_str = dice_str.replace(/-/g, '+-');

	var valid_dice = [2, 4, 6, 8, 10, 12, 20, 100];
	var parts = dice_str.split('+');

	if (parts.length > 7) {
		return false;
	}

	var dice = [];
	var addition = 0;

	for (i = 0; i < parts.length; i++) {
		var roll = parts[i].split('d');
		if (roll.length > 2) {
			return false;
		} else if (roll.length == 2) {
			if (roll[0] == '') {
				parts[i] = '1' + parts[i];
			} else {
				var count = parseInt(roll[0]);
				if (isNaN(count)) {
					return false;
				}
			}

			var sides = parseInt(roll[1]);
			if (isNaN(sides)) {
				return false;
			}

			if (valid_dice.includes(sides) == false) {
				return false;
			}

			if (count > 25) {
				return false;
			}

			dice.push(parts[i]);
		} else {
			var value = parseInt(roll[0]);
			if (isNaN(value)) {
				return false
			}

			addition += value;
		}
	}

	dice_roll(dice, addition, function(result, addition) {
		var message = 'Dice roll: ' + dice_input + '\n';
		var total = addition;

		result.forEach(function(roll) {
			total += roll;
		});

		message += '[' + result.join('] + [') + ']';
		if (addition > 0) {
			message += ' + ' + addition;
		}
		message += ' = ' + total;

		if (send_to_others) {
			send_message(message, character_name);
		} else {
			write_sidebar(message);
		}
	});

	return true;
}

function roll_d20(bonus, type = DICE_ROLL_NORMAL) {
	if (bonus == '') {
		bonus = 0;
	} else {
		bonus = parseInt(bonus);
		if (isNaN(bonus)) {
			write_sidebar('Invalid roll bonus.');
			return false;
		}
	}

	dice = [ '1d20' ];

	if (type != DICE_ROLL_NORMAL) {
		dice.push('1d20');
	}

	dice_roll(dice, bonus, function(result, bonus) {
		var roll = result[0];

		switch (type) {
			case DICE_ROLL_ADVANTAGE:
				var message = 'Advantage d';
				break;
			case DICE_ROLL_DISADVANTAGE:
				var message = 'Disadvantage d';
				break;
			default:
				var message = 'D';
				break;
		}

		message += 'ice roll: 1d20';
		if (bonus > 0) {
			message += ' + ' + bonus;
		} else if (bonus < 0) {
			message += bonus;
		}
		message += '\n';

		if (type != DICE_ROLL_NORMAL) {
			var extra = result[1];

			message += '[' + roll + '] [' + extra + '] > ';
			if (type == DICE_ROLL_ADVANTAGE) {
				if (extra > roll) {
					roll = extra;
				}
			} else {
				if (extra < roll) {
					roll = extra;
				}
			}
			message += '[' + roll + ']';

			if ((roll == 20) && (bonus == 0)) {
				message += ' CRIT!';
			}

			message += '\n';
		}

		if ((type == DICE_ROLL_NORMAL) || (bonus != 0)) {
			message += '[' + roll + '] ';
			if (bonus != 0) {
				message += '+ ' + bonus + ' ';
			}
			message += '= ' + (roll + bonus);

			if (roll == 20) {
				message += ' CRIT!';
			}
		}

		if (dungeon_master == false) {
			send_message(message, character_name);
		} else {
			write_sidebar(message);
		}
	});

	return true;
}

$(document).ready(function() {
	/* Dice roll window
	 */
	var dice_window = '<div><div class="dicerolls_defined"></div><div class="diceroll">';
	[ 4, 6, 8, 10, 12, 20 ].forEach(function(dice) {
		dice = dice.toString();
		dice_window += '<div class="dice"><img src="/images/d' + dice + '.png" title="d' + dice + '" /><select sides="' + dice + '" class="form-control">';
		for (let d = 0; d <= 10; d++) {
			dice_window += '<option>' + d.toString() + '</option>';
		}
		dice_window += '</select></div>';
	});
	dice_window += '<div class="dice"><img src="/images/plus.png" /><input type="text" class="form-control" /></div>'
	dice_window += '</div>';

	dice_roll_get = function() {
		var roll = '';
		$('div.diceroll select').each(function() {
			var value = parseInt($(this).val());
			if (value != 0) {
				if (roll != '') {
					roll += ' + ';
				}
				roll += value + 'd' + $(this).attr('sides');
			}
		});

		if (roll == '') {
			cauldron_alert('Select at least one dice.');
			return false;
		}

		var plus = $('div.diceroll input').val();
		if (isNaN(parseInt(plus))) {
			cauldron_alert('Enter a number in the plus input field.');
			return false;
		}

		if (plus.substr(0, 1) == '-') {
			roll += plus;
		} else if (plus != '0') {
			roll += ' + ' + plus;
		}

		return roll;
	}

	dice_roll_init = function() {
		$('div.diceroll select').each(function() {
			$(this).val('0');
		});
		$('div.diceroll input').val('0');

		var defined = $('div.dicerolls_defined');
		defined.empty();
		var rolls = localStorage.getItem('dicerolls');
		if (rolls == undefined) {
			rolls = [];
		} else {
			rolls = JSON.parse(rolls);
		}

		for ([key, value] of Object.entries(rolls)) {
			rolls[key] = {
				roll: value,
				global: true
			};
		};

		$('div.weapons div').each(function() {
			rolls[$(this).text()] = {
				roll: $(this).attr('roll'),
				global: false
			};
		});

		rolls = Object.keys(rolls).sort().reduce((accumulator, key) => {
			accumulator[key] = rolls[key];
			return accumulator;
		}, {});

		for ([key, value] of Object.entries(rolls)) {
			var roll = value['roll'];
			var global = value['global'];

			key = key.replace('"', '&quot;');

			if (global) {
				var button = $('<div class="btn-group"><input type="button" value="' + key + '" title="' + roll + '" class="btn btn-default roll" /><input type="button" value="X" class="btn btn-default remove" /></div>');
			} else {
				var button = $('<div class="btn-group"><input type="button" value="' + key + '" title="' + roll + '" class="btn btn-primary roll" /></div>');
			}

			button.find('input.roll').on('click', function() {
				wf_dice_roll.close();

				var dice = $(this).attr('title');
				roll_dice(dice, dungeon_master == false);
			});
			button.find('input.remove').on('click', function() {
				if (confirm('Delete dice?')) {
					var key = $(this).parent().find('input.roll').attr('value');
					var rolls = localStorage.getItem('dicerolls');
					rolls = JSON.parse(rolls);
					delete rolls[key];
					localStorage.setItem('dicerolls', JSON.stringify(rolls));

					dice_roll_init();
				}
			});
			defined.append(button);
		};
	}

	wf_dice_roll = $(dice_window).windowframe({
		activator: 'button.show_dice',
		header: 'Dice roll',
		info: '<p>Use this tool to roll dice. The option \'animated\' rolls a 3D dice on the screen and shows the result in the sidebar. The option \'quick\' only shows the roll results in the sidebar.</p><p>Use the Save button to save a dice selection. They appear at the top of the dice roll window. The blue buttons represent the weapons you added to your character in the <a href="/character">Characters</a> page.</p>',
		width: 665,
		open: function() {
			dice_roll_init();
		},
		buttons: {
			'Roll': function() {
				$(this).close();

				var roll = dice_roll_get();
				if (roll === false) {
					return;
				}
				roll_dice(roll, dungeon_master == false);
			},
			'Save': function() {
				var roll = dice_roll_get();
				if (roll === false) {
					return;
				}

				var name = prompt('Name this dice roll:');
				if (name == null) {
					return;
				}

				if (name.trim() == '') {
					return;
				}

				var rolls = localStorage.getItem('dicerolls');
				if (rolls == undefined) {
					rolls = {};
				} else {
					rolls = JSON.parse(rolls);
				}

				rolls[name] = roll;

				localStorage.setItem('dicerolls', JSON.stringify(rolls));

				dice_roll_init();
			}
		}
	});

	if (localStorage.getItem('dice_type') == undefined) {
		localStorage.setItem('dice_type', 'animated');
	}

	wf_dice_roll.find('div.dice img').on('dblclick', function() {
		var dice = $(this).attr('title');
		if (dice == undefined) {
			return;
		}

		wf_dice_roll.close();

		roll_dice('1' + dice, dungeon_master == false);
	});

	if (typeof DICEBOX_INCLUDED !== 'undefined') {
		var dice_type_selector = $('<select style="float:right; width:110px; margin-top:15px" class="form-control dice-type"><option value="quick">Quick</option><option value="animated">Animated</option></select>');
		if (localStorage.getItem('dice_type') == 'animated') {
			dice_type_selector.find('option:last-child').attr('selected', 'selected');
		}
		dice_type_selector.on('change', function() {
			localStorage.setItem('dice_type', $(this).val());
		});
		wf_dice_roll.parent().find('div.btn-group').before(dice_type_selector);
	}
});
