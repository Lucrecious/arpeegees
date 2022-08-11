class_name SpriteSwitcher
extends Node2D

const IDLE_SPRITE_NAME := 'idle'

var _name_to_sprite := {}

onready var _sprites := NodE.get_sibling_by_name(self, 'Sprites') as Node2D

func _ready() -> void:
	for s in _sprites.get_children():
		_name_to_sprite[s.name.to_lower()] = s
	
	assert(IDLE_SPRITE_NAME in _name_to_sprite)

func sprite(name: String) -> Node2D:
	name = name.to_lower()
	var sprite := _name_to_sprite.get(name, _name_to_sprite[IDLE_SPRITE_NAME]) as Node2D
	return sprite

func has_sprite(name: String) -> bool:
	var sprite := _name_to_sprite.get(name, null) as Node2D
	return sprite != null

func change(name: String) -> void:
	var sprite := sprite(name)
	for n in _name_to_sprite.values():
		n.visible = false
	sprite.visible = true
