class_name DamageReceiver
extends Node2D

signal critical_hit
signal evaded
signal hit(damager)

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

func damage(amount: int, type: int, is_critical: bool, damager: Node) -> void:
	if not _enabled:
		return
	
	if amount == 0:
		hurt()
		return
	
	if is_critical:
		amount = ModifiedPinStats.attack_with_critical(amount)
	
	var actual_damage := 0
	if type == PinAction.AttackType.Normal:
		actual_damage = ceil(amount * (amount / float(amount + _modified_stats.defence)))
	elif type == PinAction.AttackType.Magic:
		actual_damage = ceil(amount * (amount / float(amount + _modified_stats.magic_defence)))
	else:
		assert(false)
	
	actual_damage = max(actual_damage, 1)
	_health.damage(actual_damage)
	emit_signal('hit', damager)
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
			_current_hurt_tween.tween_callback(Sounds, 'play', ['FallDeath'])
			_current_hurt_tween.tween_callback(_sprite_switcher, 'change', ['dead'])
		else:
			var death_smoke := VFX.death_explosion()
			_current_hurt_tween.tween_callback(Sounds, 'play', ['PoofDeath'])
			_current_hurt_tween.tween_callback(NodE, 'add_children', [get_parent().get_parent(), death_smoke])
			
			_current_hurt_tween.tween_property(get_parent(), 'modulate:a', 0.0, 0.5)\
					.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			_current_hurt_tween.tween_callback(get_parent(), 'set', ['visible', false])
		return
	
	_current_hurt_tween.tween_callback(_sprite_switcher, 'change', ['idle'])

func revive() -> void:
	if not get_parent().visible:
		get_parent().visible = true
	
	_health.current_set(ceil(_modified_stats.max_health * 0.3))
	_sprite_switcher.change('idle')

func _set_fill_color(ratio: float) -> void:
	_root_sprite_shader.set_shader_param('color_mix', ratio)
