extends Node2D

signal text_triggered(narration_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/life2_white_mage.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	var available_targets := targets.duplicate()
	available_targets.erase(actioner)
	
	if available_targets.empty() or not _is_dead(available_targets[0]):
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_LIFE2_USE_NO_DEAD_ALLY')
		var turn_manager_group := get_tree().get_nodes_in_group('turn_manager')
		if not turn_manager_group.empty():
			var turn_manager := turn_manager_group[0] as TurnManager
			animation.tween_callback(turn_manager, 'queue_redo_turn')
	else:
		animation.tween_interval(0.35)
		
		var target := available_targets[0] as Node2D
		
		var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
		animation.tween_callback(sprite_switcher, 'change', ['magic'])
		
		var sparkles := VFX.sparkle_explosions()
		animation.tween_callback(NodE, 'add_children', [target, sparkles])
		
		var damage_receiver := NodE.get_child(target, DamageReceiver) as DamageReceiver
		animation.tween_callback(damage_receiver, 'revive')
		
		animation.tween_interval(0.5)
		
		animation.tween_callback(sprite_switcher, 'change', ['idle'])
		
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_LIFE2_USE')
	
	animation.tween_callback(object, callback)

func _is_dead(target: Node) -> bool:
	var health := NodE.get_child(target, Health) as Health
	return health.current <= 0
