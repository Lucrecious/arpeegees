extends Node2D


signal text_triggered(translation)

var _is_blocked := false
func is_blocked() -> bool:
	return _is_blocked

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/stalk_hunter.tres') as PinAction

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	_is_blocked = true
	
	for t in targets:
		var damage_receiver := NodE.get_child(t, DamageReceiver) as DamageReceiver
		damage_receiver.connect('hit', self, '_on_target_hit', [actioner])
	
	var status_effects_list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	status_effects_list.add_instance(_create_status_effect_to_remove_stalk_frame(actioner))
	
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'swap_map', ['idle', 'stalk'])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_STALK_USE')
	
	animation.tween_callback(object, callback)

func _on_target_hit(damager: Node, actioner: Node) -> void:
	if damager != actioner:
		return
	
	var health := NodE.get_child(actioner, Health) as Health
	var heal_amount := ceil(health.max_points * 0.1)
	health.current_set(min(health.current + heal_amount, health.max_points))

func _create_status_effect_to_remove_stalk_frame(actioner: Node) -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.is_ailment = false # because it can't be removed
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.Stalk
	
	var remove_stalk_effect := RemoveStalkEffect.new()
	remove_stalk_effect.actioner = actioner
	
	status_effect.add_child(remove_stalk_effect)
	
	return status_effect

class RemoveStalkEffect extends Node:
	signal start_turn_effect_finished()
	signal text_triggered(translation_key)
	
	var actioner: ArpeegeePinNode = null

	func run_start_turn_effect() -> void:
		var animation := create_tween()
		
		assert(actioner)
		var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
		animation.tween_callback(sprite_switcher, 'swap_map', ['stalk', 'idle'])
		
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_STALK_FIRST_TURN_AFTER_USE')
		
		animation.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
		animation.tween_callback(get_parent(), 'queue_free')
