extends Node2D

signal text_triggered(narration_key)

onready var _flame_particles := get_parent().get_node('FlameParticles') as CPUParticles2D

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/caramelize_flaming_banan.tres')

func run(actioner: ArpeegeePinNode, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['caramelize'])
	
	_flame_particles.spread = 180.0
	_flame_particles.amount = 56
	animation.tween_callback(_flame_particles, 'set', ['emitting', true])
	
	animation.tween_interval(2.0)
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_CARAMELIZE_USE')
	
	animation.tween_callback(_flame_particles, 'set', ['emitting', false])
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	for t in targets:
		ActionUtils.add_magic_attack(animation, actioner, t, stats.magic_attack)
	
	animation.tween_callback(object, callback)
