extends Node2D

signal text_triggered(translation)

export(String) var impact_hint_name := 'ImpactHint'
export(String) var attack_sprite_name := 'attack'
export(Resource) var pin_action: Resource = null
export(bool) var walk := true

export(String) var hit_sfx_name := ''
export(String) var windup_sfx_name := ''

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

	var is_mandolin := false
	match pin_action().resource_path.get_file():
		'bard_mandolin_swing.tres':
			is_mandolin = true
			if _times_used < 4:
				ActionUtils.add_text_trigger(tween, self, 'NARRATOR_MANDOLIN_BASH_USE_%d' % [_times_used])
				if _times_used == 3:
					var transformer := NodE.get_child(actioner, Transformer) as Transformer
					assert(transformer)
					tween.tween_callback(transformer, 'request_transform')
		'panchi_monk.tres':
			ActionUtils.add_text_trigger(tween, self, 'NARRATOR_PANCHI_USE_1')
		'wing_attack_harpy.tres':
			ActionUtils.add_text_trigger(tween, self, 'NARRATOR_WING_ATTACK_USE')

	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	if not attack_sprite_name.empty():
		tween.tween_callback(sprite_switcher, 'change', [attack_sprite_name])

	if _impact_hint_node:
		tween.tween_callback(VFX, 'physical_impact', [actioner, _impact_hint_node])

	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	if modified_stats:
		ActionUtils.add_attack(tween, actioner, target, modified_stats.attack)
	else:
		assert(false)

	ActionUtils.add_shake(tween, actioner, position, Vector2(1, 0), 5.0, .35)
	tween.tween_interval(.4)
	tween.tween_callback(sprite_switcher, 'change', ['idle'])

	ActionUtils.add_walk(tween, actioner,
			actioner.global_position + relative, actioner.global_position, 15.0, 5)
	
	tween.tween_callback(object, callback)
