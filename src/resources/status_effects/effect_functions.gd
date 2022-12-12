class_name EffectFunctions
extends Node

static func create_fear_status_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.tag = StatusEffectTag.Fear
	status_effect.is_ailment = false
	status_effect.stack_count = 1
	
	return status_effect

static func add_banan_in_love_narration_and_effect(banan: ArpeegeePinNode, white_mage: ArpeegeePinNode, narrator: NarratorUI, animation: SceneTreeTween) -> void:
	animation.tween_interval(0.5)
	
	var sprite_switcher := NodE.get_child(banan, SpriteSwitcher) as SpriteSwitcher
	
	animation.tween_callback(sprite_switcher, 'swap_map', ['idle_bruised', 'love_bruised'])
	animation.tween_callback(sprite_switcher, 'swap_map', ['idle_fully_bruised', 'love_fully_bruised'])
	animation.tween_callback(sprite_switcher, 'swap_map', ['idle', 'love'])
	
	animation.tween_callback(narrator, 'speak_tr', ['NARRATOR_BANAN_LOVES_STAFF', true])

static func add_dance_frame_and_narration(target: ArpeegeePinNode, action_node: Node, animation: SceneTreeTween) -> void:
	if target.get_meta('dancing_frame_from_bard', false):
		return
	
	var file := target.filename.get_file() as String
	if file == 'fishguy.tscn' or file == 'harpy.tscn':
		target.set_meta('dancing_frame_from_bard', true)
		
		var target_sprite_switcher := NodE.get_child(target, SpriteSwitcher) as SpriteSwitcher
		animation.tween_callback(target_sprite_switcher, 'swap_map', ['idle', 'dance'])
		
		if file == 'fishguy.tscn':
			ActionUtils.add_text_trigger(animation, action_node, 'NARRATOR_FISHGUY_DANCES_TO_BARD_MUSIC')
		elif file == 'harpy.tscn':
			ActionUtils.add_text_trigger(animation, action_node, 'NARRATOR_HARPY_DANCES_TO_BARD_MUSIC')
	
	elif file == 'banan.tscn':
		target.set_meta('dancing_frame_from_bard', true)
		
		var banan_sprite_switcher := NodE.get_child(target, SpriteSwitcher) as SpriteSwitcher
		animation.tween_callback(banan_sprite_switcher, 'swap_map', ['idle', 'dance'])
		animation.tween_callback(banan_sprite_switcher, 'swap_map', ['idle_bruised', 'dance_bruised'])
		animation.tween_callback(banan_sprite_switcher, 'swap_map', ['idle_fully_bruised', 'dance_fully_bruised'])
		
		ActionUtils.add_text_trigger(animation, action_node, 'NARRATOR_BANAN_DANCES_TO_BARD_MUSIC')

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
		var stats := NodE.get_child(target, ModifiedPinStats) as ModifiedPinStats
		var damage := ceil(stats.max_health * 0.1)
		var material := Components.root_sprite(target).material as ShaderMaterial
		
		animation.tween_callback(material, 'set_shader_param', ['fill_color', Color.purple])
		ActionUtils.add_shader_param_interpolation(animation,
				material, 'color_mix', 0.0, 0.8, 0.5)
		
		animation.tween_callback(Sounds, 'play', ['Damage'])
		animation.tween_callback(damage_receiver, 'real_damage', [damage])
		
		animation.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])

static func create_break_rocks_routine_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.is_ailment = false
	status_effect.stack_count = 1
	status_effect.tag = StatusEffectTag.MonkRockBreakingRoutine
	
	var break_rocks := BreakRocksRoutineEffect.new()
	status_effect.add_child(break_rocks)
	
	return status_effect

class BreakRocksRoutineEffect extends Node:
	signal start_turn_effect_finished()
	signal text_triggered(narration_key)
	
	func _create_break_rocks_effect() -> StatusEffect:
		var status_effect := StatusEffect.new()
		status_effect.is_ailment = false
		status_effect.stack_count = 4
		status_effect.tag = StatusEffectTag.MonkBreaksRocks
		
		var attack := StatModifier.new()
		attack.type = StatModifier.Type.Attack
		attack.add_amount = 1
		
		status_effect.add_child(attack)
		
		return status_effect
	
	func run_start_turn_effect() -> void:
		var animation := create_tween()
		
		animation.tween_interval(0.35)
		
		var pin := NodE.get_ancestor(self, ArpeegeePinNode) as ArpeegeePinNode
		var switcher := NodE.get_child(pin, SpriteSwitcher) as SpriteSwitcher
		
		animation.tween_callback(switcher, 'change', ['punch'])
		
		animation.tween_interval(0.5)
		
		animation.tween_callback(switcher, 'change', ['idle'])
		
		var list := NodE.get_child(pin, StatusEffectsList) as StatusEffectsList
		animation.tween_callback(list, 'add_instance', [_create_break_rocks_effect()])
		
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_MONK_BREAKING_GEOMANCER_ROCKS')
		
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
		animation.tween_callback(Sounds, 'play', ['DamageBurn'])
		
		animation.tween_callback(self, 'call_deferred',
				['emit_signal', 'start_turn_effect_finished'])

static func bright_sparkles(pin: ArpeegeePinNode, boosted: bool) -> void:
	var status_effect := StatusEffect.new()
	status_effect.is_ailment = false
	status_effect.stack_count = 3
	status_effect.tag = StatusEffectTag.BrightSparkles
	
	var modifier := StatModifier.new()
	modifier.type = StatModifier.Type.Critical
	modifier.multiplier = 1.5 * (Constants.HAIR_COMB_SPARKLES_BOOST_MULTIPLIER if boosted else 1.0)
	
	status_effect.add_child(modifier)
	var auras := Aura.create_bright_sparkles_aura()
	NodE.add_children(status_effect, auras)
	
	var status_effects_list := NodE.get_child(pin, StatusEffectsList) as StatusEffectsList
	status_effects_list.add_instance(status_effect)
