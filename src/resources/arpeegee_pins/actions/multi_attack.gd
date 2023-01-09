class_name GenericHitAllEnemiesAttack
extends Node2D

signal text_triggered(translation)

export(Resource) var pin_action: Resource = null
export(String) var attack_frame := 'attack'
export(String) var impact_hint_name := 'ImpactHint'
export(float) var attack_factor := 0.5
export(String) var narration_key_single := ''

export(int) var narration_multi_variations := 0
export(String) var narration_key_multi := ''
export(bool) var use_global_sfx := false
export(String) var hit_sfx := ''

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

	tween.tween_callback(Sounds, 'play', ['WindUpAttack'])
	position = ActionUtils.add_wind_up(tween, actioner, position, side)

	position = ActionUtils.add_stab(tween, actioner, target_position)

	if hit_sfx.empty():
		tween.tween_callback(Sounds, 'play', ['Damage'])
	else:
		if use_global_sfx:
			tween.tween_callback(Sounds, 'play', ['DamageHeavy'])
		else:
			tween.tween_callback(sounds, 'play', [hit_sfx])

	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	if not attack_frame.empty():
		tween.tween_callback(sprite_switcher, 'change', [attack_frame])
	
	if _impact_hint:
		tween.tween_callback(VFX, 'physical_impact', [actioner, _impact_hint])

	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	
	var hits := {}
	for t in targets:
		var attack_amount := ActionUtils.damage_with_factor(modified_stats.attack, attack_factor)
		var hit_type := ActionUtils.add_attack(tween, actioner, t, attack_amount)
		hits[t] = hit_type

	ActionUtils.add_shake(tween, actioner, position, Vector2(1, 0), 5.0, .35)
	tween.tween_interval(.4)
	
	if targets.size() == 1:
		if not narration_key_single.empty():
			ActionUtils.add_text_trigger_limited(tween, self, narration_key_single)
	elif targets.size() > 1:
		if not narration_key_multi.empty():
			if narration_multi_variations > 0:
				ActionUtils.add_text_trigger_ordered(tween, self, narration_key_multi, narration_multi_variations, 1)
			else:
				ActionUtils.add_text_trigger_limited(tween, self, narration_key_multi)
		elif not narration_key_single.empty():
			ActionUtils.add_text_trigger(tween, self, narration_key_single)
	
	var actioner_file := actioner.filename.get_file()
	if actioner_file == 'paladin.tscn' or actioner_file == 'paladin_no_sword.tscn' or actioner_file == 'holy_paladin.tscn':
		assert(pin_action().resource_path.get_file() == 'tremendous_slash_paladin.tres'\
				or pin_action().resource_path.get_file() == 'tremendous_punch_paladin.tres')
		for t in targets:
			var wont_attack_paladin := NodE.get_child(t, WontAttackPaladin, false) as WontAttackPaladin
			if wont_attack_paladin:
				wont_attack_paladin.add_post_hit(tween, self)
			
			if t.filename.get_file() == 'banan.tscn':
				if hits[t] != ActionUtils.HitType.Miss:
					var chopped_transformer := t.get_node('ChoppedTransformer') as Transformer
					tween.tween_callback(chopped_transformer, 'request_transform')
					
					var banan_sprite_switcher := NodE.get_child(t, SpriteSwitcher) as SpriteSwitcher
					tween.tween_callback(banan_sprite_switcher, 'swap_map', ['idle', 'choppedidle'])
					
					ActionUtils.add_text_trigger(tween, self, 'NARRATOR_PALADIN_SLICES_BANAN_INTO_CHOPPED_BANAN')
			
		var enamored := get_tree().get_nodes_in_group('harpy_enamored')
		for e in enamored:
			if not e.is_enamored():
				continue
			tween.tween_callback(e, 'ruin_enamore')
			ActionUtils.add_text_trigger(tween, self, 'NARRATOR_HARPY_LOSES_TRUST_IN_SPARKLES')
	
	if not attack_frame.empty():
		tween.tween_callback(sprite_switcher, 'change', ['idle'])

	ActionUtils.add_walk(tween, actioner,
			actioner.global_position + relative, actioner.global_position, 15.0, 5)
	
	tween.tween_callback(object, callback)
