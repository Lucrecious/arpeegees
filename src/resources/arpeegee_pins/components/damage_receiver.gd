class_name DamageReceiver
extends Node2D

export(String) var sprite_name := ''

onready var _health := NodE.get_sibling(self, Health) as Health
onready var _sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher

func damage(amount: int) -> void:
	_health.damage(amount)
	_hurt()

func _hurt() -> void:
	_sprite_switcher.change(sprite_name)
	var tween := create_tween()
	tween.tween_interval(.5)
	tween.tween_callback(_sprite_switcher, 'change', ['idle'])
