extends Node2D

signal text_triggered(translation)

onready var _animation_player := $Animation as AnimationPlayer

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/throw_fishguy.tres')

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	var original_position := actioner.global_position
	var relative := ActionUtils.get_closest_adjecent_position(actioner, target)
	var target_position := original_position + relative
	
	ActionUtils.add_walk(animation, actioner,
			original_position, target_position, 15.0, 5)
	
	animation.tween_callback(_animation_player, 'play', ['throw'])
	
	# hard coded from the throw animation
	animation.tween_interval(0.9)
	
	# the throw
	var lift_height := 400.0
	animation.tween_property(target, 'position', Vector2.UP * lift_height, 0.2)\
			.as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	animation.parallel().tween_property(target, 'rotation_degrees', 90.0, 0.05)
	
	animation.tween_interval(0.3)
	
	animation.tween_property(target, 'position', Vector2.DOWN * lift_height, 0.2)\
			.as_relative().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	var target_health := NodE.get_child(target, Health) as Health
	var damage := floor(target_health.current / 2.0)
	ActionUtils.add_attack(animation, actioner, target, damage)
	
	var vfx_position := NodE.get_child(target, REferenceRect).global_rect().get_center() as Vector2
	animation.tween_callback(VFX, 'physical_impactv', [target, vfx_position])
	
	animation.tween_interval(0.3)
	animation.tween_property(target, 'rotation_degrees', 0.0, 0.5)
	
	ActionUtils.add_walk(animation, actioner, target_position, original_position, 15.0, 5)
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_THROW_USE')
	animation.tween_callback(object, callback)
