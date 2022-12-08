class_name EffectFunctions
extends Node

static func create_fear_status_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.tag = StatusEffectTag.Fear
	status_effect.is_ailment = false
	status_effect.stack_count = 1
	
	return status_effect

static func add_fear_narration_and_effect(arpeegee: ArpeegeePinNode, narrator: NarratorUI, animation: SceneTreeTween) -> void:
	animation.tween_interval(0.5)
	
	var sprite_switcher := NodE.get_child(arpeegee, SpriteSwitcher) as SpriteSwitcher
	
	var fear_sprites := PoolStringArray([])
	for name in sprite_switcher.get_all_sprite_names():
		if not name.begins_with('fear'):
			continue
		fear_sprites.push_back(name)
	
	var fear_sprite_name := fear_sprites[randi() % fear_sprites.size()]
	
	animation.tween_callback(sprite_switcher, 'swap_map', ['idle', fear_sprite_name])
	
	var narration_key := 'NARRATOR_SHAKES_WITH_FEAR_%d' % [randi() % 3 + 1]
	var narration_text := arpeegee.tr('NARRATOR_SHAKES_WITH_FEAR_1')
	narration_text = narration_text % [arpeegee.nice_name]
	
	animation.tween_callback(narrator, 'speak', [narration_text, true])
	

static func create_burn_status_effect(attack_based: int) -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.is_ailment = true
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.Burning
	
	var burn := BurnEffect.new()
	burn.attack_based = attack_based
	status_effect.add_child(burn)
	
	NodE.add_children(status_effect, Aura.create_burn_aura())
	
	return status_effect

class Sleep extends Node:
	signal start_turn_effect_finished()
	signal text_triggered(narration_key)
	
	func run_start_turn_effect() -> void:
		var animation := create_tween()
		
		var target := NodE.get_ancestor(self, ArpeegeePinNode)
		
		var remove := false
		if randf() < 0.5:
			remove = true
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_SLEEPY_SPORES_WOKE_UP')
		else:
			var actions := NodE.get_child(target, PinActions) as PinActions
			actions.set_moveless(true)
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_SLEEPY_SPORES_STILL_ASLEEP')
		
		animation.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
		
		if not remove:
			return
		
		animation.tween_callback(StatusEffect, 'queue_free_leave_particles_until_dead', [get_parent()])
	
	func run_end_turn_effect() -> void:
		var target := NodE.get_ancestor(self, ArpeegeePinNode)
		var actions := NodE.get_child(target, PinActions) as PinActions
		actions.set_moveless(false)

class Poison extends Node:
	signal start_turn_effect_finished()
	
	func run_start_turn_effect() -> void:
		var animation := create_tween()
		
		var target := NodE.get_ancestor(self, ArpeegeePinNode)
		
		var health := NodE.get_child(target, Health) as Health
		var damage_receiver := NodE.get_child(target, DamageReceiver) as DamageReceiver
		var damage := ceil(health.max_points * 0.1)
		var material := Components.root_sprite(target).material as ShaderMaterial
		
		animation.tween_callback(material, 'set_shader_param', ['fill_color', Color.purple])
		ActionUtils.add_shader_param_interpolation(animation,
				material, 'color_mix', 0.0, 0.8, 0.5)
		
		animation.tween_callback(damage_receiver, 'real_damage', [damage])
		
		animation.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
		


class BurnEffect extends Node:
	signal start_turn_effect_finished()
	
	var attack_based := 1
	
	func run_start_turn_effect() -> void:
		var animation := create_tween()
		
		var pin := NodE.get_ancestor(self, ArpeegeePinNode) as ArpeegeePinNode
		var root_sprite := Components.root_sprite(pin)
		
		var material := root_sprite.material as ShaderMaterial
		material.set_shader_param('fill_color', Color.firebrick)
		
		ActionUtils.add_shader_param_interpolation(animation, material, 'color_mix',
				0.0, 0.6, 0.5)
		
		animation.tween_callback(material, 'set_shader_param', ['fill_color', Color.white])
		
		var damage_receiver := NodE.get_child(pin, DamageReceiver) as DamageReceiver
		var burn_amount := ActionUtils.damage_with_factor(attack_based, 0.3)
		animation.tween_callback(damage_receiver, 'damage',
				[burn_amount, PinAction.AttackType.Normal, false, null])
		
		animation.tween_callback(self, 'call_deferred',
				['emit_signal', 'start_turn_effect_finished'])

static func bright_sparkles(pin: ArpeegeePinNode) -> void:
	var status_effect := StatusEffect.new()
	status_effect.is_ailment = false
	status_effect.stack_count = 3
	status_effect.tag = StatusEffectTag.BrightSparkles
	
	var modifier := StatModifier.new()
	modifier.type = StatModifier.Type.Critical
	modifier.multiplier = 1.5
	
	status_effect.add_child(modifier)
	var auras := Aura.create_bright_sparkles_aura()
	NodE.add_children(status_effect, auras)
	
	var status_effects_list := NodE.get_child(pin, StatusEffectsList) as StatusEffectsList
	status_effects_list.add_instance(status_effect)
