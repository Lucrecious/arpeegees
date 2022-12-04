extends Node2D

signal text_triggered(narration_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/banan_bazooka_fishguy_banan.tres')

func run(actioner: ArpeegeePinNode, target: ArpeegeePinNode, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	get_parent().set_moveless(true)
	
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher)
	animation.tween_callback(sprite_switcher, 'swap_map', ['idle', 'bazookacharge'])
	
	var status_effects_list := NodE.get_child(actioner, StatusEffectsList)
	animation.tween_callback(status_effects_list, 'add_instance', [_create_charge_status_effect(target)])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_BANAN_BAZOOKA_USE')
	
	animation.tween_interval(1.0)
	
	animation.tween_callback(object, callback)

func _create_charge_status_effect(target: ArpeegeePinNode) -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
	status_effect.is_ailment = false
	status_effect.tag = StatusEffectTag.FishguyBananBazookaCharge
	
	var shoot_effect := BananShootEffect.new()
	shoot_effect.target = target
	status_effect.add_child(shoot_effect)
	
	return status_effect

class BananShootEffect extends StartTurnEffectRunner:
	signal start_turn_effect_finished()
	signal text_triggered(translation_key)
	
	var target: ArpeegeePinNode
	
	var _ran := false
	
	func run_start_turn_effect() -> void:
		_ran = true
		
		var pin := NodE.get_ancestor(self, ArpeegeePinNode)
		
		var animation := create_tween()
		animation.tween_interval(0.35)
		
		if target and is_instance_valid(target):
			var sprite_switcher := NodE.get_child(pin, SpriteSwitcher)
			animation.tween_callback(sprite_switcher, 'swap_map', ['idle', 'bazookacharge'])
			animation.tween_callback(sprite_switcher, 'change', ['bazookashoot'])
			
			var pin_actions := NodE.get_child(pin, PinActions) as PinActions
			var banan_sprite := pin_actions.get_node('BananBazooka/Banan') as Node2D
			animation.tween_callback(banan_sprite, 'set', ['visible', true])
		
			animation.tween_property(banan_sprite, 'global_position', target.global_position, 0.4)\
					.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			animation.tween_callback(banan_sprite, 'set', ['visible', false])
			
			var stats := NodE.get_child(pin, ModifiedPinStats) as ModifiedPinStats
			ActionUtils.add_attack_no_evade(animation, pin, target, stats.attack * 2.5)
			animation.tween_callback(VFX, 'physical_impactv', [target, target.global_position])
			
			animation.tween_callback(banan_sprite, 'set', ['position', banan_sprite.position])
			
			animation.tween_interval(0.5)
			animation.tween_callback(sprite_switcher, 'change', ['idle'])
			
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_BANAN_BAZOOKA_SHOOT')
			
		else:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_BANAN_BAZOOKA_FAILED')
		
		
		animation.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
	
	func run_end_turn_effect() -> void:
		if not _ran:
			return
		
		var pin := NodE.get_ancestor(self, ArpeegeePinNode)
		var actions := NodE.get_child(pin, PinActions) as PinActions
		actions.set_moveless(false)
		
		get_parent().queue_free()
