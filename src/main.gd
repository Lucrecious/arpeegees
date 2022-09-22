extends Control

const BattleScreen := preload('res://src/game/battle.tscn')

onready var _title_screen := $'%Title' as TitleScreen
onready var _battle_screen := $'%Battle' as BattleScreen

func _enter_tree():
	randomize()

func _ready() -> void:
	_title_screen.connect('battle_screen_requested', self, '_on_battle_screen_requested')

func _on_battle_screen_requested(pin_amount: int) -> void:
	_title_screen.get_parent().remove_child(_title_screen)
	
	var pins := ArpeegeePins.pick_random(3)
	
	_battle_screen.start(pins)
