class_name ChikaraPanchiEffect
extends Node


signal start_turn_effect_finished()
signal text_triggered(translation_key)

var actioner: ArpeegeePinNode = null
var target: ArpeegeePinNode = null
var hint_position: Node2D =null
var sprite_switcher: SpriteSwitcher = null

var _ran := false
var _pin_actions: PinActions

func run_start_turn_effect() -> void:
	assert(actioner and sprite_switcher and target and hint_position)
	
	var tween := get_tree().create_tween()
	
	var health := NodE.get_child(actioner, Health) as Health
	if health.current <= 0:
		tween.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
		return
	
	if not target or not is_instance_valid(target):
		ActionUtils.add_text_trigger(tween, self, 'NARRATOR_CHAKIRA_PANCHI_FAILED')
		tween.tween_interval(0.35)
		tween.tween_callback(sprite_switcher, 'swap_map', ['powerup', 'idle'])
		tween.tween_callback(sprite_switcher, 'change', ['idle'])
		
		tween.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])
		return
	
	var sounds := NodE.get_child_by_name(actioner, 'Sounds')
	
	_pin_actions = NodE.get_child(actioner, PinActions) as PinActions
	_pin_actions.set_moveless(true)
	
	_ran = true
	
	var position := actioner.global_position
	var relative := ActionUtils.get_closest_adjecent_position(actioner, target)
	var target_position := position + relative
	
	var side := -int(sign(relative.x))
	
	tween.tween_callback(Sounds, 'play', ['Dash1'])
	
	position += relative
	tween.tween_property(actioner, 'global_position', position, 0.3)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	tween.tween_interval(.3)
	
	tween.tween_callback(sounds, 'play', ['ChikaraPanchiWindUp'])
	position = ActionUtils.add_wind_up(tween, actioner, position, side)
	
	position = ActionUtils.add_stab(tween, actioner, target_position)
	tween.tween_callback(sounds, 'play', ['ChikaraPanchiHit'])
	
	tween.tween_callback(sprite_switcher, 'change', ['punch'])
	
	tween.tween_callback(VFX, 'physical_impact', [actioner, hint_position])
	
	var blobbo_absorbed := false
	if target.filename.get_file() == 'blobbo.tscn':
		blobbo_absorbed = true
		
		var blobbo_sprite_switcher := NodE.get_child(target, SpriteSwitcher) as SpriteSwitcher
		tween.tween_callback(blobbo_sprite_switcher, 'change', ['hit'])
		tween.tween_interval(0.4)
		tween.tween_callback(blobbo_sprite_switcher, 'change', ['idle'])
		
		var absorbed_punch_effect := StatusEffect.new()
		absorbed_punch_effect.is_ailment = false
		absorbed_punch_effect.stack_count = 1
		absorbed_punch_effect.tag = StatusEffectTag.BlobboAbsorbedPunch
		
		var attack := StatModifier.new()
		attack.multiplier = 2.0
		attack.type = StatModifier.Type.Attack
		absorbed_punch_effect.add_child(attack)
		
		var blobbo_effects_list := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
		tween.tween_callback(blobbo_effects_list, 'add_instance', [absorbed_punch_effect])

	else:
		var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
		if modified_stats:
			var attack_amount := ActionUtils.damage_with_factor(modified_stats.attack, 2.5)
			ActionUtils.add_attack(tween, actioner, target, attack_amount)
		else:
			assert(false)
	
	ActionUtils.add_shake(tween, actioner, position, Vector2(1, 0), 5.0, .35)
	tween.tween_interval(.4)
	
	if blobbo_absorbed:
		ActionUtils.add_text_trigger(tween, self, 'NARRATOR_BLOBBO_ABSORBS_CHAKIRA_PANCHI')
	else:
		ActionUtils.add_text_trigger_limited(tween, self, 'NARRATOR_CHIKARA_PANCHI_USE_ATTACK')
	
	# switching it back after punch
	tween.tween_callback(sprite_switcher, 'swap_map', ['powerup', 'idle'])
	tween.tween_callback(sprite_switcher, 'change', ['idle'])
	
	ActionUtils.add_walk(tween, actioner,
			actioner.global_position + relative, actioner.global_position, 15.0, 7)
	
	tween.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])

func run_end_turn_effect() -> void:
	if not _ran:
		return
	_pin_actions.set_moveless(false)
	get_parent().queue_free()
	
