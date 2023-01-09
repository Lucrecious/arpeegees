class_name RaiseDropRocks
extends Node2D

var _holding_rocks := false
var _rocks_lit := false

var _sprites_rocks := ['idle', 'throw', 'hurt', 'win']

onready var _sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher

func _ready() -> void:
	hold_rocks()

func rocks_lit() -> bool:
	return _rocks_lit

func has_rocks() -> bool:
	return _holding_rocks

func light_rocks() -> void:
	if not _holding_rocks:
		assert(false)
		return
	
	_rocks_lit = true
	_sprite_switcher.swap_map('idle', 'idlefire')
	_sprite_switcher.change('scaredfire')
	get_tree().call_group('geomancer_rock_throw', 'light_rock_on_fire')

func hold_rocks() -> void:
	if _holding_rocks:
		return
	_holding_rocks = true
	
	for rocks in _sprites_rocks:
		_sprite_switcher.swap_map(rocks, '%sRocks' % rocks)

func drop_rocks() -> void:
	if not _holding_rocks:
		return
	_holding_rocks = false
	
	for rocks in _sprites_rocks:
		_sprite_switcher.swap_map(rocks, '%sRocks' % rocks)
