extends Node2D

const ATTACK_INCREASE := 0.1
const MAX_ATTACK_FACTOR := 3.5

var attack_factor := 1.0

onready var _particles := $Particles as CPUParticles2D

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/splish_shifty_fishguy.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['throw'])
	
	animation.tween_callback(_particles, 'set', ['emitting', true])
	
	animation.tween_interval(1.0)
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var attack_amount := ActionUtils.damage_with_factor(
			modified_stats.magic_attack, attack_factor)
	for t in targets:
		ActionUtils.add_attack(animation, actioner, t, attack_amount)
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	var next_attack_factor := min(attack_factor + ATTACK_INCREASE, MAX_ATTACK_FACTOR)
	animation.tween_callback(self, 'set', ['attack_factor', next_attack_factor])
	animation.tween_callback(object, callback)
