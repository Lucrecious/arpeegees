extends Node2D

signal text_triggered(translation_key)

onready var _arrow := $Arrow as Node2D

var _boosted := false
func boost() -> void:
	_boosted = true

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/rain_from_above_ranger.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_callback(Music, 'pause_fade_out')
	
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	animation.tween_callback(sounds, 'play', ['RainFromAbove'])
	
	animation.tween_interval(0.35)
	
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['attackair2'])
	animation.tween_callback(_arrow, 'set', ['visible', true])
	animation.tween_interval(0.5)
	
	animation.tween_property(_arrow, 'position', Vector2.LEFT.rotated(_arrow.get_child(0).rotation) * 1000.0, 0.2).as_relative()
	animation.tween_callback(_arrow, 'set', ['visible', false])
	animation.tween_callback(_arrow, 'set', ['position', _arrow.position])
	
	animation.tween_interval(1.0)
	
	var rain_arrow_group := get_tree().get_nodes_in_group('rain_arrows')
	if not rain_arrow_group.empty():
		var rain_arrows := rain_arrow_group[0] as CPUParticles2D
		
		var viewport_rect := rain_arrows.get_viewport_rect()
		var particles_position := viewport_rect.position.y + viewport_rect.size.y - 1500.0
		rain_arrows.global_position.y = particles_position
		
		animation.tween_callback(rain_arrows, 'set', ['emitting', true])
		animation.tween_interval(3.0)
		
		var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
		var attack_amount := ActionUtils.damage_with_factor(modified_stats.attack, 0.5)
		
		
		for t in targets:
			ActionUtils.add_attack(animation, actioner, t, attack_amount)
		
		animation.tween_callback(sounds, 'play', ['RainFromAboveHit'])
		
		
		animation.tween_callback(rain_arrows, 'set', ['emitting', false])
	else:
		print_debug('not in battle scene')
	
	if _boosted:
			var sword := get_parent().get_node('MagicGhostSword/GhostSword')
			sword.add_attack(animation, actioner, targets, 1)
	
	ActionUtils.add_text_trigger_ordered(animation, self, 'NARRATOR_RAIN_FROM_ABOVE_USE_', 4, 1)
	
	animation.tween_callback(Music, 'unpause_fade_in')
	animation.tween_interval(0.5)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)
