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

func run(actioner: Node2D, target: ArpeegeePinNode, object: Object, callback: String) -> void:
	if target.filename.get_file() == 'blobbo.tscn' and pin_action().resource_path.get_file() == 'heavenly_slash_paladin.tres':
		if randf() < 0.5:
			_run_blobbo_steals_sword(actioner, target, object, callback)
			return
	
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
	var deflated_mushboy_struggle_extra_damage := false
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	
	var attacked_physically := false
	var hatless_mushboy_hits_critical := false
	
	if physical:
		var attack_amount := ActionUtils.damage_with_factor(modified_stats.attack, attack_factor)
		if pin_action().resource_path.get_file() == 'desperate_staff_whack_white_mage.tres':
			if randf() < 0.08:
				attack_amount = 100_000
				white_mage_instakill = true
		
		elif pin_action().resource_path.get_file() == 'desperate_headbutt_hatless_mushboy.tres':
			if randf() < 0.1:
				attack_amount = ActionUtils.damage_with_factor(attack_amount, 8.0)
				hatless_mushboy_hits_critical = true
				
		elif pin_action().resource_path.get_file() == 'struggle_mushboy_deflated.tres':
			var chance := randf()
			Logger.info('Mushboy used struggle and rolled %.2f' % [chance])
			if chance < 0.2:
				attack_amount = ActionUtils.damage_with_factor(attack_amount, 10.0)
				deflated_mushboy_struggle_extra_damage = true
		
		var hit_type := ActionUtils.HitType.Miss as int
		if not white_mage_instakill:
			hit_type = ActionUtils.add_attack(tween, actioner, target, attack_amount)
		else:
			ActionUtils.add_attack_no_evade(tween, actioner, target, attack_amount)
			hit_type = ActionUtils.HitType.Hit
		
		attacked_physically = hit_type != ActionUtils.HitType.Miss
		
		if pin_action().resource_path.get_file() == 'desperate_kick_hatless_mushboy.tres':
			if hit_type != ActionUtils.HitType.Miss and randf() < 0.1:
				var status_effects_list := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
				tween.tween_callback(status_effects_list, 'add_instance', [_create_desperate_kick_effect()])
			
			if hit_type == ActionUtils.HitType.CriticalHit:
				hatless_mushboy_hits_critical = true
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
	elif attacked_physically and deflated_mushboy_struggle_extra_damage:
		ActionUtils.add_text_trigger(tween, self, 'NARRATOR_STRUGGLE_USE_DAMAGE')
	
	if attacked_physically and hatless_mushboy_hits_critical:
		if pin_action().resource_path.get_file() == 'desperate_headbutt_hatless_mushboy.tres':
			ActionUtils.add_text_trigger(tween, self, 'NARRATOR_DESPERATE_HEADBUTT_USE_CRITICAL')
		elif pin_action().resource_path.get_file() == 'desperate_kick_hatless_mushboy.tres':
			ActionUtils.add_text_trigger(tween, self, 'NARRATOR_DESPERATE_KICK_USE_CRITICAL')
	
	ActionUtils.add_walk(tween, actioner,
			actioner.global_position + relative, actioner.global_position, 15.0, 5)
	
	if pin_action().resource_path.get_file() == 'wing_attack_harpy.tres':
		if attacked_physically and randf() < 0.25:
			var status_effects_list := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
			tween.tween_callback(status_effects_list, 'add_instance', [_create_wing_attack_effect()])
	
	tween.tween_callback(object, callback)

func _create_wing_attack_effect() -> StatusEffect:
	var status_effect := StatusEffect.new()
	status_effect.stack_count = 3
	status_effect.is_ailment = true
	status_effect.tag = StatusEffectTag.WingAttack
	
	var effect := StatModifier.new()
	effect.type = StatModifier.Type.Defence
	effect.add_amount = -1
	status_effect.add_child(effect)
	
	return status_effect

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

func _run_blobbo_steals_sword(actioner: ArpeegeePinNode, target: ArpeegeePinNode, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.3)
	
	var position := actioner.global_position
	var relative := ActionUtils.get_closest_adjecent_position(actioner, target)
	var target_position := position + relative
	
	var side := -int(sign(relative.x))
	
	ActionUtils.add_walk(animation, actioner, actioner.global_position, target_position, 15, 5)
	
	animation.tween_interval(.3)
	
	ActionUtils.add_wind_up(animation, actioner, target_position, side)
	
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	if not windup_sfx_name.empty():
		animation.tween_callback(sounds, 'play', [windup_sfx_name])
	else:
		animation.tween_callback(Sounds, 'play', ['GenericWindUp1'])
	
	ActionUtils.add_stab(animation, actioner, target_position)
	
	var blobbo_sprite_switcher := NodE.get_child(target, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(blobbo_sprite_switcher, 'change', ['swordstuckpaladin'])
	
	var paladin_root_sprite := Components.root_sprite(actioner)
	animation.tween_callback(paladin_root_sprite, 'set', ['visible', false])
	
	var blobbo_transformer := NodE.get_child(target, Transformer) as Transformer
	var paladin_transformer := NodE.get_child(actioner, Transformer) as Transformer
	
	animation.tween_callback(blobbo_transformer, 'request_transform')
	blobbo_transformer.transform_scene = load('res://src/resources/arpeegee_pins/blobbo_sword.tscn')
	
	animation.tween_callback(paladin_transformer, 'request_transform')
	paladin_transformer.transform_scene = load('res://src/resources/arpeegee_pins/paladin_no_sword.tscn')
	
	animation.tween_interval(0.5)
	
	var paladin_sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(paladin_sprite_switcher, 'change', ['idlenosword'])
	animation.tween_callback(paladin_root_sprite, 'set', ['visible', true])
	
	animation.tween_callback(blobbo_sprite_switcher, 'change', ['swordstuck'])
	
	ActionUtils.add_walk(animation, actioner, target_position, actioner.global_position, 15, 5)
	
	animation.tween_callback(object, callback)
