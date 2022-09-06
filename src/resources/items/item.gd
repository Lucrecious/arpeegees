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
			print('applied attack')
		Type.Flee:
			_apply_flee(pins)
			print('applied evasion')
		Type.HP:
			_apply_hp(pins)
			print('applied health')
		Type.MP:
			_apply_mp(pins)
			print('applied magic attack')

func _apply_attack(pins: Array) -> void:
	for p in pins:
		_add_status_effect(p, StatModifier.Type.Attack, 1.5)

func _apply_flee(pins: Array) -> void:
	for p in pins:
		_add_status_effect(p, StatModifier.Type.Evasion, 1.5)

func _apply_hp(pins: Array) -> void:
	for p in pins:
		var modifier := _add_status_effect(p, StatModifier.Type.MaxHealth, 1.5)
		var health := NodE.get_child(p, Health) as Health
		health.current = modifier.apply(health.current)

func _apply_mp(pins: Array) -> void:
	for p in pins:
		_add_status_effect(p, StatModifier.Type.MagicAttack, 1.5)

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
	
