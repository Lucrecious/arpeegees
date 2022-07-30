class_name SpriteSwitcher
extends Node2D

const IDLE_SPRITE_NAME := 'idle'

var _name_to_sprite := {}

onready var _sprites := NodE.get_sibling_by_name(self, 'Sprites') as Node2D

func _ready() -> void:
	for s in _sprites.get_children():
		_name_to_sprite[s.name.to_lower()] = s
	
	assert(IDLE_SPRITE_NAME in _name_to_sprite)

func change(name: String) -> void:
	var sprite := _name_to_sprite.get(name, _name_to_sprite[IDLE_SPRITE_NAME]) as Node2D
	for n in _name_to_sprite.values():
		n.visible = false
	sprite.visible = true
