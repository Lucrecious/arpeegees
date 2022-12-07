class_name IsThisFood

static func too_sad_to_attack() -> bool:
	var chance := randf()
	return chance < 1.0#0.33

static func add_is_this_food(animation: SceneTreeTween, action: Node2D, object: Object, callback: String) -> void:
	ActionUtils.add_text_trigger(animation, action, 'NARRATOR_IS_THIS_FOOD_USE_CAUSE_MISS')
	
	animation.tween_callback(object, callback)
