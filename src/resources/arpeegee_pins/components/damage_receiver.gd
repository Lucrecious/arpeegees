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
	hurt()

var _current_hurt_tween: SceneTreeTween
func hurt() -> void:
	var sounds := create_tween()
	sounds.tween_callback(Sounds, 'play', ['Woosh'])
	sounds.tween_interval(0.08)
	sounds.tween_callback(Sounds, 'play', ['PhysicalHit'])
	
	_sprite_switcher.change(sprite_name)
	if _current_hurt_tween and _current_hurt_tween.is_running():
		_current_hurt_tween.kill()
	
	_current_hurt_tween = create_tween()
	
	var flash_sec := 0.15
	_current_hurt_tween.tween_method(self, '_set_fill_color', 0.0, 1.0, flash_sec / 2.0)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	_current_hurt_tween.tween_method(self, '_set_fill_color', 1.0, 0.0, flash_sec / 2.0)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	_current_hurt_tween.parallel().tween_interval(.8)
	
	if _health.current <= 0:
		if _sprite_switcher.has_sprite('dead'):
			_current_hurt_tween.tween_callback(_sprite_switcher, 'change', ['dead'])
		else:
			_current_hurt_tween.tween_property(get_parent(), 'modulate:a', 0.0, 1.0)\
					.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
		return
	
	_current_hurt_tween.tween_callback(_sprite_switcher, 'change', ['idle'])

func _set_fill_color(ratio: float) -> void:
	_root_sprite_shader.set_shader_param('color_mix', ratio)
