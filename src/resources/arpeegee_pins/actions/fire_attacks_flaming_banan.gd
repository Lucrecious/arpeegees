extends Node2D

signal text_triggered(narration_key)

enum Type {
	Flamethrower,
	FlameBreath,
}

export(Type) var type := Type.Flamethrower

onready var _flame_particles := get_parent().get_node('FlameParticles') as CPUParticles2D

var _is_blocked := false
func is_blocked() -> bool:
	return _is_blocked

func pin_action() -> PinAction:
	if type == Type.Flamethrower:
		return preload('res://src/resources/actions/flamethrower_flaming_banan.tres')
	elif type == Type.FlameBreath:
		return preload('res://src/resources/actions/flame_breath_flaming_banan.tres')
	else:
		assert(false)
		return preload('res://src/resources/actions/flamethrower_flaming_banan.tres')
		

func run(actioner: ArpeegeePinNode, target: ArpeegeePinNode, object: Object, callback: String) -> void:
	if type == Type.FlameBreath:
		_is_blocked = true
	
	var animation := create_tween()
	
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	
	var frame := 'flamethrower'
	if type == Type.FlameBreath:
		frame = 'caramelize'
	
	animation.tween_callback(sprite_switcher, 'change', [frame])
	
	_flame_particles.spread = 20.0
	_flame_particles.amount = 24
	animation.tween_callback(_flame_particles, 'set', ['emitting', true])
	
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	
	if type == Type.Flamethrower:
		animation.tween_callback(sounds, 'play', ['Thrower'])
	elif type == Type.FlameBreath:
		animation.tween_callback(sounds, 'play', ['Breath'])
	
	animation.tween_interval(2.0)
	
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var hit_type := ActionUtils.HitType.Miss as int
	var burn_attack := 0
	if type == Type.Flamethrower:
		var damage := ActionUtils.damage_with_factor(modified_stats.attack, 0.5)
		hit_type = ActionUtils.add_attack(animation, actioner, target, damage)
		burn_attack = modified_stats.attack
	elif type == Type.FlameBreath:
		var damage := ActionUtils.damage_with_factor(modified_stats.magic_attack, 2.0)
		hit_type = ActionUtils.add_magic_attack(animation, actioner, target, damage)
		burn_attack = modified_stats.magic_attack
	
	animation.tween_callback(Sounds, 'play', ['DamageBurn'])
	
	if hit_type != ActionUtils.HitType.Miss and burn_attack > 0:
		var burning_status_effect := EffectFunctions.create_burn_status_effect(burn_attack)
		var status_effects_list := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
		animation.tween_callback(status_effects_list, 'add_instance', [burning_status_effect])
	
	if type == Type.FlameBreath:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_FLAME_BREATH_USE')
	elif type == Type.Flamethrower:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_FLAMETHROWER_USE')
	
	animation.tween_callback(_flame_particles, 'set', ['emitting', false])
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)
