extends Control

const BattleScreen := preload('res://src/game/battle.tscn')

onready var _title_screen := $Title as TitleScreen

func _enter_tree():
	randomize()

func _ready() -> void:
	_title_screen.connect('battle_screen_requested', self, '_on_battle_screen_requested')

func _on_battle_screen_requested(pin_amount: int) -> void:
	remove_child(_title_screen)
	
	var battle_screen := BattleScreen.instance() as BattleScreen
	battle_screen.pin_count = pin_amount
	add_child(battle_screen)
	
