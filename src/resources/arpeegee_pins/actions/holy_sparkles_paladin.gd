extends Node2D

signal text_triggered(narration_key)

export(String) var frame := ''

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/holy_sparkles_paladin.tres') as PinAction

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', [frame])
	
	for t in targets:
		var box := NodE.get_child(t, REferenceRect) as REferenceRect
		var hearts := VFX.heart_explosion()
		animation.tween_callback(NodE, 'add_children', [t, hearts])
		
	animation.tween_callback(self, '_heal_targets', [targets])
	
	animation.tween_interval(0.75)
	
	animation.tween_callback(sprite_switcher, 'change', ['Idle'])
	
	if targets.size() == 1:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_HOLY_SPARKLES_USE_NO_ALLY')
	elif targets.size() > 1:
		var any_dead := false
		for t in targets:
			var health := NodE.get_child(t, Health) as Health
			if health.current > 0:
				continue
			any_dead = true
			break
		
		if not any_dead:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_HOLY_SPARKLES_USE_WITH_ALLY')
		else:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_HOLY_SPARKLES_USE_DEAD_ALLY')
	
	animation.tween_callback(object, callback)

func _heal_targets(targets: Array) -> void:
	for t in targets:
		var health := NodE.get_child(t, Health) as Health
		var new_points := health.current + (health.max_points * 0.2)
		health.current_set(min(new_points, health.max_points))
