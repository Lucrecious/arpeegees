class_name GenericTargetAttack
extends Node2D

signal text_triggered(translation)

export(String) var impact_hint_name := 'ImpactHint'
export(String) var attack_sprite_name := 'attack'
export(Resource) var pin_action: Resource = null
export(bool) var walk := true
export(bool) var physical := true
export(String) var narration_key := ''

export(String) var hit_sfx_name := ''
export(String) var windup_sfx_name := ''

export(float) var attack_factor := 1.0

onready var _impact_hint_node := NodE.get_child_by_name(self, impact_hint_name) as Node2D

var _times_used := 0

func pin_action() -> PinAction:
	assert(pin_action is PinAction)
	return pin_action as PinAction

func times_used() -> int:
	return _times_used

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	
	_times_used += 1
	
	var position := actioner.global_position
	var relative := ActionUtils.get_closest_adjecent_position(actioner, target)
	var target_position := position + relative
	
	var side := -int(sign(relative.x))
	
	var tween := get_tree().create_tween()
	
	if walk:
		position = ActionUtils.add_walk(tween, actioner, position, position + relative, 15.0, 5)
	else:
		tween.tween_callback(Sounds, 'play', ['Dash1'])
		position += relative
		tween.tween_property(actioner, 'global_position', position, 0.3)\
				.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	tween.tween_interval(.3)

	if not windup_sfx_name.empty():
		tween.tween_callback(sounds, 'play', [windup_sfx_name])
	else:
		tween.tween_callback(Sounds, 'play', ['GenericWindUp1'])
	position = ActionUtils.add_wind_up(tween, actioner, position, side)

	position = ActionUtils.add_stab(tween, actioner, target_position)

	if not hit_sfx_name.empty():
		tween.tween_callback(sounds, 'play', [hit_sfx_name])
	else:
		tween.tween_callback(Sounds, 'play', ['GenericHit1'])

	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	if not attack_sprite_name.empty():
		tween.tween_callback(sprite_switcher, 'change', [attack_sprite_name])

	if _impact_hint_node:
		tween.tween_callback(VFX, 'physical_impact', [actioner, _impact_hint_node])
	
	var white_mage_instakill := false
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	if physical:
		var attack_amount := ActionUtils.damage_with_factor(modified_stats.attack, attack_factor)
		if pin_action().resource_path.get_file() == 'desperate_staff_whack_white_mage.tres':
			if randf() < 0.08:
				attack_amount = 100_000
				white_mage_instakill = true
		
		elif pin_action().resource_path.get_file() == 'desperate_headbutt_hatless_mushboy.tres':
			if randf() < 0.1:
				attack_amount = ActionUtils.damage_with_factor(attack_amount, 8.0)
		
		var hit_type := ActionUtils.add_attack(tween, actioner, target, attack_amount)
		
		if pin_action().resource_path.get_file() == 'desperate_kick_hatless_mushboy.tres':
			if hit_type != ActionUtils.HitType.Miss and randf() < 0.1:
				var status_effects_list := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
				tween.tween_callback(status_effects_list, 'add_instance', [_create_desperate_kick_effect()])
	else:
		var attack_amount := ActionUtils.damage_with_factor(modified_stats.magic_attack, attack_factor)
		ActionUtils.add_magic_attack(tween, actioner, target, attack_amount)


	ActionUtils.add_shake(tween, actioner, position, Vector2(1, 0), 5.0, .35)
	tween.tween_interval(.4)
	tween.tween_callback(sprite_switcher, 'change', ['idle'])

	if pin_action().resource_path.get_file() == 'bard_mandolin_swing.tres':
			if _times_used < 4:
				ActionUtils.add_text_trigger(tween, self, 'NARRATOR_MANDOLIN_BASH_USE_%d' % [_times_used])
				if _times_used == 3:
					var transformer := NodE.get_child(actioner, Transformer) as Transformer
					assert(transformer)
					tween.tween_callback(transformer, 'request_transform')
	else:
		if not narration_key.empty():
			ActionUtils.add_text_trigger(tween, self, narration_key)

	if white_mage_instakill:
		ActionUtils.add_text_trigger(tween, self, 'NARRATOR_DESPERATE_STAFF_WHACK_KILL')

	ActionUtils.add_walk(tween, actioner,
			actioner.global_position + relative, actioner.global_position, 15.0, 5)
	
	tween.tween_callback(object, callback)

func _create_desperate_kick_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 1
	status_effect.is_ailment = true
	status_effect.tag = StatusEffectTag.DesperateKick
	
	var defence_modifier := StatModifier.new()
	defence_modifier.type = StatModifier.Type.Defence
	defence_modifier.add_amount = -3
	
	status_effect.add_child(defence_modifier)
	
	return status_effect
