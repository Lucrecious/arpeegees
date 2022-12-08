class_name Mesmerized
extends Node

var _is_mesmerized := false

func is_mesmerized() -> bool:
	return _is_mesmerized

func add_mesmerize() -> void:
	if _is_mesmerized:
		return
	
	_is_mesmerized = true
	var sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
	sprite_switcher.swap_map('idle', 'mesmerized')

func remove_mesmerize() -> void:
	if not _is_mesmerized:
		return
	
	_is_mesmerized = false
	
	var _sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
	_sprite_switcher.swap_map('idle', 'mesmerized')
	queue_free()
