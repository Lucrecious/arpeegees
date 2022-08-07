class_name DamageReceiver
extends Node2D

export(String) var sprite_name := ''

onready var _health := NodE.get_sibling(self, Health) as Health
onready var _sprite_switcher := NodE.get_sibling(self, SpriteSwitcher) as SpriteSwitcher
onready var _root_sprite := Components.root_sprite(get_parent())
onready var _root_sprite_shader := _root_sprite.material as ShaderMaterial

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
	
	var flash_sec := 0.15
	tween.tween_method(self, '_set_fill_color', 0.0, 1.0, flash_sec / 2.0)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_method(self, '_set_fill_color', 1.0, 0.0, flash_sec / 2.0)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_interval(.8)
	
	if _health.current <= 0:
		if _sprite_switcher.has_sprite('dead'):
			tween.tween_callback(_sprite_switcher, 'change', ['dead'])
		else:
			tween.tween_property(get_parent(), 'modulate:a', 0.0, 1.0)\
					.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		return
	
	tween.tween_callback(_sprite_switcher, 'change', ['idle'])

func _set_fill_color(ratio: float) -> void:
	_root_sprite_shader.set_shader_param('color_mix', ratio)
