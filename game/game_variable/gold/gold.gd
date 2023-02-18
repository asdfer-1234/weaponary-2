extends GameGlobalVariable

var gold:
	get:
		return value
	set(set_value):
		value = set_value


func price_tooltip(value):
	if value == 0:
		return RichTextBuilder.color_text(tr("FREE"), Palette.green)
	var color = Palette.green
	if value > gold:
		color = Palette.red
	return RichTextBuilder.property_text(tr("PRICE"), minimal_value_tooltip(value, color))
