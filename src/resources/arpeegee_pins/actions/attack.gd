class_name GenericTargetAttack
extends Node2D

signal text_triggered(translation)

export(String) var impact_hint_name := 'ImpactHint'
export(String) var attack_sprite_name := 'attack'
export(Resource) var pin_action: Resource = null
export(bool) var walk := true
export(bool) var physical := true
export(String) var narration_key := ''

export(bool) var use_global_sounds := false
export(String) var hit_sfx_name := ''
export(String) var windup_sfx_name := ''

export(float) var attack_factor := 1.0

onready var _impact_hint_node := NodE.get_child_by_name(self, impact_hint_name) as Node2D

var _times_used := 0

func pin_action() -> PinAction:
	assert(pin_action is PinAction)
	return pin_action as PinAction

func pin_action_is_filename(filename: String) -> bool:
	return pin_action().resource_path.get_file() == filename

func times_used() -> int:
	return _times_used

func run(actioner: Node2D, target: ArpeegeePinNode, object: Object, callback: String) -> void:
	if target.filename.get_file() == 'blobbo.tscn' and pin_action().resource_path.get_file() == 'heavenly_slash_paladin.tres':
		print_debug('should be 0.1')
		if randf() < 1.0:
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
		if use_global_sounds:
			tween.tween_callback(Sounds, 'play', [windup_sfx_name])
		else:
			tween.tween_callback(sounds, 'play', [windup_sfx_name])
	else:
		tween.tween_callback(Sounds, 'play', ['WindUpAttack'])
	
	position = ActionUtils.add_wind_up(tween, actioner, position, side)

	position = ActionUtils.add_stab(tween, actioner, target_position)

	if not hit_sfx_name.empty():
		if use_global_sounds:
			tween.tween_callback(Sounds, 'play', [hit_sfx_name])
		else:
			tween.tween_callback(sounds, 'play', [hit_sfx_name])
	else:
		tween.tween_callback(Sounds, 'play', ['Damage'])

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
	
	var target_file := target.filename.get_file()
	var actioner_file := actioner.filename.get_file()
	
	var add_banan_in_love_text := false
	if (pin_action_is_filename('desperate_staff_whack_white_mage.tres') or pin_action_is_filename('useless_staff_whack_white_mage.tres'))\
			and target_file == 'banan.tscn':
		add_banan_in_love_text = true
	
	var banan_chopped := false
	var hunter_gooed_up := false
	var mushboy_popped := false

	if physical:
		var attack_amount := ActionUtils.damage_with_factor(modified_stats.attack, attack_factor)
		if pin_action_is_filename('desperate_staff_whack_white_mage.tres'):
			if randf() < 0.08:
				attack_amount = 100_000
				white_mage_instakill = true
		
		elif pin_action_is_filename('desperate_headbutt_hatless_mushboy.tres'):
			if randf() < 0.1:
				attack_amount = ActionUtils.damage_with_factor(attack_amount, 8.0)
				hatless_mushboy_hits_critical = true
				
		elif pin_action_is_filename('struggle_mushboy_deflated.tres'):
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
		
		if actioner_file == 'monk.tscn' and target_file == 'mushboy.tscn' and _is_focused_kied(actioner):
			mushboy_popped = true
			assert(pin_action_is_filename('panchi_monk.tres'))
			
			var cap_popper := NodE.get_child(target, CapPopper) as CapPopper
			cap_popper.pop(tween)
		
		if actioner_file == 'hunter.tscn' and target_file == 'blobbo.tscn':
			assert(pin_action_is_filename('pounce_owo_hunter.tres'))
			var gooer := NodE.get_child(actioner, HunterGooedUp) as HunterGooedUp
			
			if not gooer.is_gooed():
				hunter_gooed_up = true
				gooer.enable_goo(tween)
		
		if hit_type != ActionUtils.HitType.Miss and pin_action_is_filename('heavenly_slash_paladin.tres') and target_file == 'banan.tscn':
			banan_chopped = true
			var chopped_transformer := target.get_node('ChoppedTransformer') as Transformer
			tween.tween_callback(chopped_transformer, 'request_transform')
			
			var banan_sprite_switcher := NodE.get_child(target, SpriteSwitcher) as SpriteSwitcher
			tween.tween_callback(banan_sprite_switcher, 'swap_map', ['idle', 'choppedidle'])
		
		attacked_physically = hit_type != ActionUtils.HitType.Miss
		
		if pin_action_is_filename('desperate_kick_hatless_mushboy.tres'):
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
	
	var koboldio_steals_mandolin := false
	if pin_action_is_filename('bard_mandolin_swing.tres'):
			if _times_used < 4:
				if target_file == 'koboldio.tscn':
					koboldio_steals_mandolin = true
					
					var koboldio_transformer := NodE.get_child(target, Transformer) as Transformer
					var bard_transformer := NodE.get_child(actioner, Transformer) as Transformer
					
					tween.tween_callback(koboldio_transformer, 'request_transform')
					tween.tween_callback(bard_transformer, 'request_transform')
					
					var bard_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
					var koboldio_switcher := NodE.get_child(target, SpriteSwitcher) as SpriteSwitcher
					
					tween.tween_callback(bard_switcher, 'swap_map', ['idle', 'idlenomandolin'])
					tween.tween_callback(koboldio_switcher, 'swap_map', ['idle', 'idlewithmandolin'])
					
					ActionUtils.add_text_trigger(tween, self, 'NARRATOR_KOBOLDIO_STEALS_MANDOLIN')
				else:
					ActionUtils.add_text_trigger(tween, self, 'NARRATOR_MANDOLIN_BASH_USE_%d' % [_times_used])
					if _times_used == 3:
						var transformer := NodE.get_child(actioner, Transformer) as Transformer
						assert(transformer)
						tween.tween_callback(transformer, 'request_transform')
	elif mushboy_popped:
		ActionUtils.add_text_trigger(tween, self, 'NARRATOR_MUSHBOY_CAP_EXPLODES_ALL_POISONED')
	else:
		if not narration_key.empty():
			ActionUtils.add_text_trigger(tween, self, narration_key)
	
	if hunter_gooed_up:
		ActionUtils.add_text_trigger(tween, self, 'NARRATOR_HUNTER_GOOED_UP_FROM_BLOBBO')
	
	if not get_meta('banan_love_text_done', false) and attacked_physically and add_banan_in_love_text:
		set_meta('banan_love_text_done', true)
		ActionUtils.add_text_trigger(tween, self, 'NARRATOR_BANAN_GETS_HIT_BY_STAFF')
	
	if banan_chopped:
		ActionUtils.add_text_trigger(tween, self, 'NARRATOR_PALADIN_SLICES_BANAN_INTO_CHOPPED_BANAN')
	
	if actioner_file == 'paladin.tscn' or actioner_file == 'paladin_no_sword.tscn':
		var wont_attack_paladin := NodE.get_child(target, WontAttackPaladin, false) as WontAttackPaladin
		if wont_attack_paladin:
			wont_attack_paladin.add_post_hit(tween, self)
		
		var enamored := get_tree().get_nodes_in_group('harpy_enamored')
		for e in enamored:
			if not e.is_enamored():
				continue
			tween.tween_callback(e, 'ruin_enamore')
			ActionUtils.add_text_trigger(tween, self, 'NARRATOR_HARPY_LOSES_TRUST_IN_SPARKLES')
	
	if white_mage_instakill:
		ActionUtils.add_text_trigger(tween, self, 'NARRATOR_DESPERATE_STAFF_WHACK_KILL')
	elif attacked_physically and deflated_mushboy_struggle_extra_damage:
		ActionUtils.add_text_trigger(tween, self, 'NARRATOR_STRUGGLE_USE_DAMAGE')
	
	if attacked_physically and hatless_mushboy_hits_critical:
		if pin_action_is_filename('desperate_headbutt_hatless_mushboy.tres'):
			ActionUtils.add_text_trigger(tween, self, 'NARRATOR_DESPERATE_HEADBUTT_USE_CRITICAL')
		elif pin_action_is_filename('desperate_kick_hatless_mushboy.tres'):
			ActionUtils.add_text_trigger(tween, self, 'NARRATOR_DESPERATE_KICK_USE_CRITICAL')
	
	ActionUtils.add_walk(tween, actioner,
			actioner.global_position + relative, actioner.global_position, 15.0, 5)
	
	if pin_action_is_filename('wing_attack_harpy.tres'):
		if attacked_physically and randf() < 0.25:
			var status_effects_list := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
			tween.tween_callback(status_effects_list, 'add_instance', [_create_wing_attack_effect()])
			tween.tween_callback(Sounds, 'play', ['Debuff'])
	
	tween.tween_callback(object, callback)

func _is_focused_kied(monk: Node2D) -> bool:
	var effects_list := NodE.get_child(monk, StatusEffectsList) as StatusEffectsList
	return effects_list.count_tags(StatusEffectTag.FocusKi) > 0

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
		if use_global_sounds:
			animation.tween_callback(Sounds, 'play', [windup_sfx_name])
		else:
			animation.tween_callback(sounds, 'play', [windup_sfx_name])
	else:
		animation.tween_callback(Sounds, 'play', ['WindUpAttack'])
	
	ActionUtils.add_stab(animation, actioner, target_position)
	
	var blobbo_sprite_switcher := NodE.get_child(target, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(blobbo_sprite_switcher, 'change', ['swordstuckpaladin'])
	
	animation.tween_callback(sounds, 'play', ['SwordStuck'])
	
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
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_PALADIN_GIVES_BLOBBO_SWORD')
	
	animation.tween_callback(object, callback)
