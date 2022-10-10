extends Node2D

signal text_triggered(translation)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/throw_fishguy.tres')

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	var target_health := NodE.get_child(target, Health) as Health
	var damage := floor(target_health.current / 2.0)
	
	ActionUtils.add_attack(animation, actioner, target, damage)
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_THROW_USE')
	animation.tween_callback(object, callback)
