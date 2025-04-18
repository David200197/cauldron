function filter_level() {
	var level = $('div.filter select').val();

	$('div.market div.adventure').show();

	if (level != '') {
		$('div.market div.adventure[level!="' + level + '"]').hide();
	}

	$('span#count').text($('div.market > div:visible').length);
}

function filter_category() {
	var category = $('div.filter select').val();

	$('div.market div.map').show();

	if (category != '') {
		$('div.market div.map[category!="' + category + '"]').hide();
	}

	$('span#count').text($('div.market > div:visible').length);
}

$(document).ready(function() {
	if ($('div.adventures').length > 0) {
		filter_level();
	}

	if ($('div.market div.map').length == 0) {
		return;
	}

	filter_category();

	var preview_window = $('<div class="preview"><img src="" /></div>').windowframe({
		top: 50,
		width: 1000
	});

	$('div.market div.map img').on('click', function() {
		var title = $(this).parent().parent().find('div.panel-heading').text();
		preview_window.parent().parent().find('div.panel-heading span.title').text(title + ' map preview');

		if ($(this).attr('src') != $(this).attr('full')) {
			preview_window.find('img').attr('src', '');
			preview_window.find('img').attr('src', $(this).attr('full'));
		}

		preview_window.open();
	});
});
