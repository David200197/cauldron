import DiceBox from '/dice-box/dice-box.es.min.js';

var hostname = $('body').attr('hostname');

var Box = new DiceBox('#dice-box', {
    assetPath: 'assets/',
    origin: 'https://' + hostname + '/dice-box/',
    theme: 'smooth',
    themeColor: '#ff2020',
    offscreen: false,
    scale: 4,
    gravity: 5
});

var dicebox_addition;
var dicebox_busy = false;
var dicebox_timeout = undefined;
var dicebox_callback = undefined;

Box.onRollComplete = function(rollResult) {
	var results = [];
	rollResult.forEach(function(dice) {
		dice.rolls.forEach(function(roll) {
			if ((roll.sides == 'd10') && (roll.value == 0)) {
				results.push(10);
			} else {
				results.push(roll.value);
			}
		});
	});

	dicebox_callback(results, dicebox_addition);
	dicebox_callback = undefined;

	dicebox_timeout = window.setTimeout(function() {
		dicebox_timeout = undefined;
		dicebox_hide();
	}, 5000);

	dicebox_busy = false;
};

function dice_roll_3d(dice, addition, callback) {
	if (dicebox_busy) {
		return false;
	}

	dicebox_addition = addition;
	dicebox_callback = callback;
	dicebox_busy = true;

	$('body').append($('div#dice-box'));
	$('div#dice-box').css('z-index', 1);

	dicebox_clear_timer();

	Box.roll(dice);

	var audio = new Audio('/dice-box/diceroll.mp3');
	audio.play();

	return true;
}

function dicebox_clear_timer() {
	if (dicebox_timeout != undefined) {
		window.clearTimeout(dicebox_timeout);
		dicebox_timeout = undefined;
	}
}

function dicebox_hide() {
	$('body').prepend($('div#dice-box'));
	$('div#dice-box').css('z-index', '');
}

Box.init();

$('div#dice-box').on('click', function() {
	if (dicebox_busy) {
		return;
	}

	dicebox_clear_timer();
	dicebox_hide();
});

$('div#dice-box').on('contextmenu', function() {
	if (dicebox_busy) {
		return;
	}

	dicebox_clear_timer();
	dicebox_hide();
});

$(document).ready(function() {
	dicebox_hide();
});

window.dice_roll_3d = dice_roll_3d;

export { dice_roll_3d };
