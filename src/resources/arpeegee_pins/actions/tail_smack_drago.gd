extends Node2D

signal text_triggered(translation)

onready var _impact_hint := $ImpactHint as Position2D

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/tail_smack_drago.tres')

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	var sounds := NodE.get_child(actioner, SoundsComponent) as SoundsComponent
	
	var position := actioner.global_position
	var relative := Vector2.ZERO
	for t in targets:
		var r := ActionUtils.get_closest_adjecent_position(actioner, t)
		relative += r
	
	relative /= targets.size()
	
	var target_position := position + relative
	
	var side := -int(sign(relative.x))
	
	var tween := get_tree().create_tween()
	
	position = ActionUtils.add_walk(tween, actioner, position, position + relative, 15.0, 5)
	
	tween.tween_interval(.3)

	tween.tween_callback(Sounds, 'play', ['GenericWindUp1'])
	position = ActionUtils.add_wind_up(tween, actioner, position, side)

	position = ActionUtils.add_stab(tween, actioner, target_position)

	tween.tween_callback(Sounds, 'play', ['GenericHit1'])
	
	ActionUtils.add_text_trigger(tween, self, 'NARRATOR_TAIL_SMACK_USE')

	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	tween.tween_callback(sprite_switcher, 'change', ['TailWhip'])

	tween.tween_callback(VFX, 'physical_impact', [actioner, _impact_hint])

	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	for t in targets:
		var attack_amount := ActionUtils.damage_with_factor(modified_stats.attack, 0.5)
		ActionUtils.add_attack(tween, actioner, t, attack_amount)

	ActionUtils.add_shake(tween, actioner, position, Vector2(1, 0), 5.0, .35)
	tween.tween_interval(.4)
	tween.tween_callback(sprite_switcher, 'change', ['idle'])

	ActionUtils.add_walk(tween, actioner,
			actioner.global_position + relative, actioner.global_position, 15.0, 5)
	
	tween.tween_callback(object, callback)
