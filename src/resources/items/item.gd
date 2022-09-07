class_name PinItemPowerUp
extends Node2D

enum Type {
	HP,
	MP,
	Attack,
	Flee,
}

var type := -1

var _sprite: Sprite

func as_type(type_: int) -> void:
	if _sprite:
		assert(false)
		return
	
	type = type_
	_sprite = Sprite.new()
	add_child(_sprite)
	_sprite.scale = Vector2.ONE * 0.5
	
	match type:
		Type.Attack: _sprite.texture = load('res://assets/items/attack.png')
		Type.Flee: _sprite.texture = load('res://assets/items/flee.png')
		Type.HP: _sprite.texture = load('res://assets/items/hp.png')
		Type.MP: _sprite.texture = load('res://assets/items/mp.png')

func apply_power(pins: Array) -> void:
	match type:
		Type.Attack:
			_apply_attack(pins)
		Type.Flee:
			_apply_flee(pins)
		Type.HP:
			_apply_hp(pins)
		Type.MP:
			_apply_mp(pins)

func _trail_and_explosion(from_local: Vector2, to_global: Vector2) -> void:
	var trail := CPUParticles2D.new()
	trail.texture = load('res://assets/sprites/effects/sparkle5.png')
	trail.scale_amount = 0.1
	trail.amount = 10
	trail.local_coords = false
	trail.lifetime = 0.5
	add_child(trail)
	trail.emitting = true
	
	var explosions := VFX.sparkle_explosions() as Array
	
	trail.position = from_local
	var animation := create_tween()
	
	var relative := to_global - trail.global_position
	
	animation.tween_property(trail, 'global_position', trail.global_position + (relative / 2.0) + Vector2.UP * 30.0, 0.5)
	animation.tween_property(trail, 'global_position', to_global, 0.5)
	animation.tween_callback(trail, 'set', ['emitting', false])
	animation.tween_callback(NodE, 'add_children', [trail, explosions])
	animation.tween_interval(trail.lifetime + 0.1)
	animation.tween_callback(trail, 'queue_free')

func _trail_and_explosion_per_pin(pins: Array) -> void:
	for p in pins:
		var bounding_box := NodE.get_child(p, REferenceRect) as REferenceRect
		_trail_and_explosion(Vector2.ZERO, bounding_box.global_rect().get_center())

func _fade_out_and_die() -> void:
	var animation := create_tween()
	animation.tween_property(self, 'modulate:a', 0.0, 1.0)
	animation.tween_interval(10.0)
	animation.tween_callback(self, 'queue_free')

func _apply_attack(pins: Array) -> void:
	_trail_and_explosion_per_pin(pins)
	
	yield(get_tree().create_timer(1.0), 'timeout')
	
	for p in pins:
		_add_status_effect(p, StatModifier.Type.Attack, 1.5)
	
	_fade_out_and_die()

func _apply_flee(pins: Array) -> void:
	_trail_and_explosion_per_pin(pins)
	
	yield(get_tree().create_timer(1.0), 'timeout')
	
	for p in pins:
		_add_status_effect(p, StatModifier.Type.Evasion, 1.5)
	
	_fade_out_and_die()

func _apply_hp(pins: Array) -> void:
	_trail_and_explosion_per_pin(pins)
	
	yield(get_tree().create_timer(1.0), 'timeout')
	
	for p in pins:
		var modifier := _add_status_effect(p, StatModifier.Type.MaxHealth, 1.5)
		var health := NodE.get_child(p, Health) as Health
		health.current = modifier.apply(health.current)
	
	_fade_out_and_die()

func _apply_mp(pins: Array) -> void:
	_trail_and_explosion_per_pin(pins)
	
	yield(get_tree().create_timer(1.0), 'timeout')
	
	for p in pins:
		_add_status_effect(p, StatModifier.Type.MagicAttack, 1.5)
	
	_fade_out_and_die()

func _add_status_effect(pin: ArpeegeePinNode, type: int, multiplier: float) -> StatModifier:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.ItemPowerUp
	
	var stat_modifier := StatModifier.new()
	stat_modifier.type = type
	stat_modifier.multiplier = multiplier
	status_effect.add_child(stat_modifier)
	
	var list := NodE.get_child(pin, StatusEffectsList) as StatusEffectsList
	list.add_instance(status_effect)
	return stat_modifier
	
