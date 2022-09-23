extends Control

const BattleScreen := preload('res://src/game/battle.tscn')

onready var _title_screen := $'%Title' as TitleScreen
onready var _battle_screen := $'%Battle' as BattleScreen
onready var _intro_panel := $'%IntroPanel' as Control

func _enter_tree():
	randomize()

func _ready() -> void:
	_title_screen.connect('battle_screen_requested', self, '_on_battle_screen_requested')

func _on_battle_screen_requested(pin_amount: int) -> void:
	_title_screen.get_parent().remove_child(_title_screen)
	
	var pins := ArpeegeePins.pick_random(3)
	
	_battle_screen.start(pins)

var _intro_faded := false
func _input(event: InputEvent) -> void:
	if _intro_faded:
		return
	
	if event is InputEventMouseButton:
		var is_mouse_button := bool(event.button_index == BUTTON_LEFT\
				or event.button_index == BUTTON_RIGHT\
				or event.button_index == BUTTON_MIDDLE)
		
		if event.pressed and is_mouse_button:
			_intro_faded = true
			_title_screen.start()
			var fade_away := _intro_panel.create_tween()
			fade_away.tween_property(_intro_panel, 'modulate:a', 0.0, 1.0)\
					.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			fade_away.tween_callback(_intro_panel, 'queue_free')
