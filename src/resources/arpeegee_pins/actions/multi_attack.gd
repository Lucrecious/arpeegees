class_name GenericHitAllEnemiesAttack
extends Node2D

signal text_triggered(translation)

export(Resource) var pin_action: Resource = null
export(String) var attack_frame := 'attack'
export(String) var impact_hint_name := 'ImpactHint'
export(float) var attack_factor := 0.5
export(String) var narration_key_single := ''
export(String) var narration_key_multi := ''

onready var _impact_hint := get_node_or_null(impact_hint_name) as Position2D

func pin_action() -> PinAction:
	return pin_action as PinAction

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

	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	if not attack_frame.empty():
		tween.tween_callback(sprite_switcher, 'change', [attack_frame])
	
	if _impact_hint:
		tween.tween_callback(VFX, 'physical_impact', [actioner, _impact_hint])

	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	for t in targets:
		var attack_amount := ActionUtils.damage_with_factor(modified_stats.attack, attack_factor)
		ActionUtils.add_attack(tween, actioner, t, attack_amount)

	ActionUtils.add_shake(tween, actioner, position, Vector2(1, 0), 5.0, .35)
	tween.tween_interval(.4)
	
	if targets.size() == 1:
		if not narration_key_single.empty():
			ActionUtils.add_text_trigger(tween, self, narration_key_single)
	elif targets.size() > 1:
		if not narration_key_multi.empty():
			ActionUtils.add_text_trigger(tween, self, narration_key_multi)
		elif not narration_key_single.empty():
			ActionUtils.add_text_trigger(tween, self, narration_key_single)
	
	if not attack_frame.empty():
		tween.tween_callback(sprite_switcher, 'change', ['idle'])

	ActionUtils.add_walk(tween, actioner,
			actioner.global_position + relative, actioner.global_position, 15.0, 5)
	
	tween.tween_callback(object, callback)
