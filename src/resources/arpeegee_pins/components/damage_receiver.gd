class_name DamageReceiver
extends Node2D

export(String) var sprite_name := ''

onready var _health := NodE.get_sibling(self, Health) as Health
onready var _sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher

func _ready() -> void:
	enable()

var _enabled := false
func enable() -> void:
	if _enabled:
		return
	
	_enabled = true

func disable() -> void:
	if not _enabled:
		return
	
	_enabled = false

func damage(amount: int) -> void:
	if not _enabled:
		return
	
	_health.damage(amount)
	_hurt()

func _hurt() -> void:
	_sprite_switcher.change(sprite_name)
	var tween := create_tween()
	tween.tween_interval(.5)
	
	if _health.current <= 0:
		if _sprite_switcher.has_sprite('dead'):
			tween.tween_callback(_sprite_switcher, 'change', ['dead'])
		else:
			tween.tween_property(get_parent(), 'modulate:a', 0.0, 1.0)\
					.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		return
	
	tween.tween_callback(_sprite_switcher, 'change', ['idle'])
	
