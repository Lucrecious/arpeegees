class_name MainNode
extends Control

signal battle_screen_changed()

const BattleScreen := preload('res://src/game/battle.tscn')

onready var _title_screen := $'%Title' as TitleScreen
onready var _battle_screen_position_reference := $'%BattleScreenPositionReference' as Control
onready var _battle_screen: BattleScreen
onready var _intro_panel := $'%IntroPanel' as Control

func _enter_tree():
	randomize()

func _ready() -> void:
	_title_screen.connect('battle_screen_requested', self, '_on_battle_screen_requested')
	restart_battle()

func get_battle_screen() -> BattleScreen:
	return _battle_screen

func restart_battle() -> void:
	Music.stop_theme()
	if _battle_screen:
		_battle_screen.queue_free()
	
	_battle_screen = BattleScreen.instance()
	var parent := _battle_screen_position_reference
	_battle_screen.auto_start = false
	parent.add_child(_battle_screen)
	_battle_screen.rect_size = _battle_screen_position_reference.rect_size
	_battle_screen.rect_position = Vector2.ZERO
	
	if not _title_screen.is_inside_tree():
		_battle_screen_position_reference.get_parent()\
				.add_child_below_node(_battle_screen_position_reference, _title_screen)
		_title_screen.reset()
	
	_battle_screen.restart_button.connect('pressed', self, 'restart_battle', [], CONNECT_DEFERRED)
	
	emit_signal('battle_screen_changed')
	var size_x := get_viewport().get_size_override().x
	get_tree().call_group('size_adapter', 'adapt', size_x)
	

func _on_battle_screen_requested(pin_amount: int) -> void:
	
	var pins := ArpeegeePins.pick_random(3)
	if Debug.allow_pick_pins:
		var new_pins := Debug.get_picked_pins()
		if not new_pins.empty():
			pins = new_pins
	
	_battle_screen.load_pins(pins)
	
	yield(_title_screen, 'bag_open_finished')
	
	_title_screen.get_parent().remove_child(_title_screen)
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
			var fade_away := _intro_panel.create_tween()
			fade_away.tween_property(_intro_panel, 'modulate:a', 0.0, 1.0)\
					.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			fade_away.tween_callback(_intro_panel, 'queue_free')
