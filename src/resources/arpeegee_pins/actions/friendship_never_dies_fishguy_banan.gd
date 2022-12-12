extends Node2D

signal text_triggered(narration_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/friendship_never_dies_fishguy_banan.tres')

func run(actioner: ArpeegeePinNode, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_callback(Music, 'pause_fade_out')
	
	animation.tween_interval(0.35)
	
	var factor_damage := rand_range(1.0, 4.0)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher)
	animation.tween_callback(sprite_switcher, 'change', ['friendshipneverdies'])
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	animation.tween_callback(sounds, 'play', ['FriendshipNeverDies'])
	
	animation.tween_interval(1.0)
	
	var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var damage := ActionUtils.damage_with_factor(stats.magic_attack, factor_damage)
	
	for t in targets:
		ActionUtils.add_magic_attack(animation, actioner, t, damage)
	
	animation.tween_callback(Music, 'unpause_fade_in')
	animation.tween_interval(0.5)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_FRIENDSHIP_NEVER_DIES_USE')
	
	animation.tween_callback(object, callback)
