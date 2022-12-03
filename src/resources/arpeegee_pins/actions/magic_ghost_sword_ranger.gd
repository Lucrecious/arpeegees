extends Node2D

signal text_triggered(translation_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/magic_ghost_sword_ranger.tres')

func run(actioner: Node2D,object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.35)
	
	animation.tween_callback(self, '_add_magic_ghost_sword')
	
	var sword := get_child(0) as Node2D
	sword.visible = true
	sword.modulate.a = 0.0
	
	animation.tween_property(sword, 'modulate:a', 1.0, 1.0)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_MAGIC_GHOST_SWORD_USE')
	
	animation.tween_callback(object, callback)

func _add_magic_ghost_sword() -> void:
	for action in get_parent().get_children():
		if not action.has_method('boost'):
			continue
		
		action.boost()
