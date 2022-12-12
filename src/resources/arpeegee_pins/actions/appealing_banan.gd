extends Node2D

signal text_triggered(narration_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/appealing_banan.tres')

var _used := false
func is_blocked() -> bool:
	return _used

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	_used = true
	
	var animation := create_tween()
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['appealing'])
	
	var sounds := NodE.get_child(actioner, SoundsComponent)
	animation.tween_callback(sounds, 'play', ['Appealing'])
	
	var peel := sprite_switcher.sprite('appealing').get_child(0) as Node2D
	for t in targets:
		var target_position := ActionUtils.get_closest_adjecent_position(actioner, t) + actioner.global_position
		for i in 2:
			animation.tween_property(peel, 'global_position', target_position, 0.3)\
					.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
			animation.tween_property(peel, 'global_position', peel.global_position, 0.3)\
					.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	
	SlipEffect.add_slip_effect(animation, targets)
	
	var sparkles := get_tree().get_nodes_in_group('shiny_ground_particles')
	if not sparkles.empty():
		animation.tween_callback(sparkles[0], 'set', ['emitting', true])
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_APPEALING_USE')
	
	animation.tween_interval(0.4)
	
	animation.tween_callback(object, callback)


