extends Node2D

signal text_triggered(narration_key)

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/bounce_mushboy.tres')

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	animation.tween_interval(0.4)
	
	var material := Components.root_sprite(actioner).material as ShaderMaterial
	TweenJuice.squish(animation, material, 1.0, 0.5, 0.5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	TweenJuice.squish(animation, material, 0.5, 1.0, 0.1)
	
	animation.tween_property(actioner, 'global_position', Vector2.UP * 1000.0, 0.15)\
			.as_relative()
	
	animation.tween_callback(actioner, 'set', ['visible', false])
	
	var list := NodE.get_child(actioner, StatusEffectsList) as StatusEffectsList
	animation.tween_callback(list, 'add_instance',
			[_bounce_effect(actioner.global_position, actioner, target)])
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_BOUNCE_USE_FIRST_TURN')
	
	animation.tween_callback(object, callback)

func _bounce_effect(original_position: Vector2, actioner: Node2D, target: Node2D) -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
	status_effect.is_ailment = false
	status_effect.tag = StatusEffectTag.Bounce
	
	var bounce_start_turn_effect := BounceStartTurnEffect.new(original_position, actioner, target)
	status_effect.add_child(bounce_start_turn_effect)
	
	return status_effect

class BounceStartTurnEffect extends Node:
	signal start_turn_effect_finished()
	signal text_triggered(translation_key)
	
	var _used := false
	var _actioner: Node2D = null
	var _target: Node2D = null
	var _original_position := Vector2.ZERO
	
	func _init(original_position: Vector2, actioner: Node2D, target: Node2D) -> void:
		_actioner = actioner
		_target = target
		_original_position = original_position

	func run_start_turn_effect() -> void:
		_used = true
		
		var actions := NodE.get_child(_actioner, PinActions) as PinActions
		actions.set_moveless(true)
		
		var animation := create_tween()
		animation.tween_interval(0.35)
		
		var sprite_switcher := NodE.get_child(_actioner, SpriteSwitcher) as SpriteSwitcher
		animation.tween_callback(sprite_switcher, 'change', ['headbutt'])
		
		animation.tween_callback(_actioner, 'set', ['visible', true])
		
		if _target and is_instance_valid(_target):
			var target_box := NodE.get_child(_target, REferenceRect) as REferenceRect
			var target_position := target_box.global_rect().get_center()
			
			animation.tween_property(_actioner, 'global_position', target_position, 0.2)
			
			var stats := NodE.get_child(_actioner, ModifiedPinStats) as ModifiedPinStats
			var damage := ActionUtils.damage_with_factor(stats.attack, 2.0)
			ActionUtils.add_attack(animation, _actioner, _target, damage)
			
			animation.tween_interval(1.0)
		else:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_MUSHBOY_BOUNCE_FAILED')
		
		animation.tween_callback(sprite_switcher, 'change', ['idle'])
		
		animation.tween_property(_actioner, 'global_position', _original_position, 0.2)
		
		animation.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])

	func run_end_turn_effect() -> void:
		if not _used:
			return
		
		var actions := NodE.get_child(_actioner, PinActions) as PinActions
		actions.set_moveless(false)
		get_parent().queue_free()
