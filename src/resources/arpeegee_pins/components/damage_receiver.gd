class_name DamageReceiver
extends Node2D

signal critical_hit
signal evaded

export(String) var sprite_name := ''

onready var _health := NodE.get_sibling(self, Health) as Health
onready var _modified_stats := NodE.get_sibling(self, ModifiedPinStats) as ModifiedPinStats
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

func real_damage(amount: int) -> void:
	_health.damage(amount)
	if amount > 0:
		hurt()

func damage(amount: int, type: int, is_critical: bool) -> void:
	if not _enabled:
		return
	
	var actual_damage := 0
	if type == PinAction.AttackType.Normal:
		actual_damage = ceil(amount * (amount / float(amount + _modified_stats.defence)))
	elif type == PinAction.AttackType.Magic:
		actual_damage = ceil(amount * (amount / float(amount + _modified_stats.magic_defence)))
	else:
		assert(false)
	
	actual_damage = max(actual_damage, 1)
	_health.damage(actual_damage)
	hurt()
	if is_critical:
		emit_signal('critical_hit')

func evade() -> void:
	emit_signal('evaded')

var _current_hurt_tween: SceneTreeTween
func hurt() -> void:
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
