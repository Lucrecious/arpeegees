class_name BananSlippable
extends Node

# Basically, any action that is able to slip from Banan's slipping attack has this node under it.
#   If is_slipping is set to true, then the character can randomly start slipping from using this
#   action

const SLIP_PERCENT := 0.5
const DAMAGE_PERCENT := 0.3

export(bool) var is_slipping := false

func _ready() -> void:
	assert(get_parent().has_signal('text_triggered'), 'must have this to have slippable')

func is_activated() -> bool:
	if not is_slipping:
		return false
	
	var has_slipped := randf() < SLIP_PERCENT
	return has_slipped

func run_action_with_targets(actioner: Node2D, targets: Array) -> SceneTreeTween:
	var animation := create_tween()
	
	animation.tween_interval(0.3)
	
	if not targets.empty():
		var first := targets[0] as Node2D
		var relative := first.global_position - actioner.global_position
		relative /= 2
		
		ActionUtils.add_walk(animation, actioner,
				actioner.global_position, actioner.global_position + relative,
				15.0, 3)
	
	animation.tween_property(actioner, 'rotation_degrees', 90.0, 0.1)
	
	var health := NodE.get_child(actioner, Health) as Health
	ActionUtils.add_real_damage(animation, actioner, ceil(health.current * DAMAGE_PERCENT))
	
	animation.tween_interval(0.5)
	
	ActionUtils.add_text_trigger(animation, get_parent(), 'NARRATOR_APPEALING_SLIP')
	
	animation.tween_property(actioner, 'global_position', actioner.global_position, 0.15)
	animation.tween_property(actioner, 'rotation_degrees', 0.0, 0.35)
	
	return animation
