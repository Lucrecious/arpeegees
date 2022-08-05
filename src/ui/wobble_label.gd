class_name WobbleLabel
extends Label

export(DynamicFontData) var _alternative_font_data: DynamicFontData = null
export(float) var _change_sec := .4

var _alternative_font: DynamicFont
var _theme_font: DynamicFont

var _wobble_timer: Timer

func enable_wobble() -> void:
	_wobble_timer.start()

func disable_wobble() -> void:
	_wobble_timer.stop()

func _ready() -> void:
	_theme_font = get_font('font')
	_alternative_font = _theme_font.duplicate() as DynamicFont
	_alternative_font.font_data = _alternative_font_data
	add_font_override('font', _theme_font)
	_is_on_theme_font = true
	
	var autostart := true
	_wobble_timer = TimEr.repeated(.4, self, '_on_timeout', autostart)
	add_child(_wobble_timer)

var _is_on_theme_font := true
func _on_timeout() -> void:
	if _is_on_theme_font:
		add_font_override('font', _alternative_font)
	else:
		add_font_override('font', _theme_font)
	
	_is_on_theme_font = not _is_on_theme_font
	
	
