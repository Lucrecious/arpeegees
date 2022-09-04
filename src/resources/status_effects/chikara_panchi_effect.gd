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
	
	var sounds := NodE.get_child_by_name(actioner, 'Sounds')
	
	_pin_actions = NodE.get_child(actioner, PinActions) as PinActions
	_pin_actions.set_moveless(true)
	
	_ran = true
	
	var position := actioner.global_position
	var relative := ActionUtils.get_closest_adjecent_position(actioner, target)
	var target_position := position + relative
	
	var side := int(sign(relative.x))
	
	var tween := get_tree().create_tween()
	tween.tween_callback(sounds, 'play', ['Dash'])
	
	position += relative
	tween.tween_property(actioner, 'global_position', position, 0.3)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	tween.tween_interval(.3)
	position = ActionUtils.add_wind_up(tween, actioner, position, side)
	position = ActionUtils.add_stab(tween, actioner, target_position)
	tween.tween_callback(sounds, 'play', ['Impact'])

	ActionUtils.add_text_trigger(tween, self, 'NARRATOR_CHIKARA_PANCHI_USE_ATTACK')
	
	tween.tween_callback(sprite_switcher, 'change', ['idle'])
	
	
	tween.tween_callback(VFX, 'physical_impact', [actioner, hint_position])
	
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	if modified_stats:
		ActionUtils.add_damage(tween, target, modified_stats.attack * 2.5, PinAction.AttackType.Normal)
	else:
		assert(false)
	
	ActionUtils.add_shake(tween, actioner, position, Vector2(1, 0), 5.0, .35)
	tween.tween_interval(.4)
	
	# switching it back after punch
	tween.tween_callback(sprite_switcher, 'swap_map', ['powerup', 'idle'])
	
	ActionUtils.add_walk(tween, actioner,
			actioner.global_position + relative, actioner.global_position, 15.0, 7)
	
	tween.tween_callback(self, 'emit_signal', ['start_turn_effect_finished'])

func run_end_turn_effect() -> void:
	if not _ran:
		return
	_pin_actions.set_moveless(false)
	get_parent().queue_free()
	
