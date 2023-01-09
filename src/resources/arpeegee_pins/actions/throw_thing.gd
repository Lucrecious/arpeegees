extends Node2D

signal text_triggered(narration_text)

enum Type {
	HandThrowRock,
	MagicThrowRock,
	ThrowSpear,
}

export(Type) var type := Type.HandThrowRock
export(String) var throw_frame := ''
export(int) var narration_variations := 0
export(String) var narration_key := ''

onready var _thing := get_child(0) as Node2D

var _rocks_on_fire := false
func light_rock_on_fire() -> void:
	_rocks_on_fire = true
	get_child(0).get_child(0).visible = true

func unlight_rocks_on_fire() -> void:
	_rocks_on_fire = false
	get_child(0).get_child(0).visible = false

var _uses := 0

func is_blocked() -> bool:
	return type == Type.HandThrowRock and _uses >= 7

func is_used() -> bool:
	return _uses > 0

func _ready() -> void:
	assert(_thing)
	_thing.visible = false

func pin_action() -> PinAction:
	if type == Type.HandThrowRock:
		return preload('res://src/resources/actions/throw_rock_no_magic_geomancer.tres')
	elif type == Type.MagicThrowRock:
		return preload('res://src/resources/actions/throw_rock_magic_geomancer.tres')
	elif type == Type.ThrowSpear:
		return preload('res://src/resources/actions/throw_spear_shifty_fishguy.tres')
	else:
		assert(false)
		return null

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	var side := -sign(target.global_position.x - actioner.global_position.x)
	
	if type == Type.MagicThrowRock:
		animation.tween_callback(Sounds, 'play', ['WindUpMagic'])
	else:
		animation.tween_callback(Sounds, 'play', ['WindUpAttack'])
	
	var material := Components.root_sprite(actioner).material as ShaderMaterial
	TweenJuice.skew(animation, material, 0.0, side * 1.0, 0.35)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	animation.tween_interval(0.8)
	
	TweenJuice.skew(animation, material, side * 1.0, 0.0, 0.1)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', [throw_frame])
	
	var raise_drop_rocks := NodE.get_child(actioner, RaiseDropRocks) as RaiseDropRocks
	animation.tween_callback(raise_drop_rocks, 'drop_rocks')
	
	animation.tween_callback(_thing, 'set', ['visible', true])
	
	var target_box := NodE.get_child(target, REferenceRect) as REferenceRect
	animation.tween_property(_thing, 'global_position', target_box.global_rect().get_center(), 0.3)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	animation.tween_callback(VFX, 'physical_impact', [actioner, _thing])
	
	animation.tween_callback(_thing, 'set', ['visible', false])
	animation.tween_callback(_thing, 'set', ['global_position', _thing.global_position])
	
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var sounds := NodE.get_child(actioner, SoundsComponent)
	var hit_type := ActionUtils.HitType.Miss as int
	if type == Type.HandThrowRock:
		hit_type = ActionUtils.add_attack(animation, actioner, target, stats.attack)
		animation.tween_callback(sounds, 'play', ['RockHit'])
	elif type == Type.MagicThrowRock:
		hit_type = ActionUtils.add_magic_attack(animation, actioner, target, stats.magic_attack)
		animation.tween_callback(sounds, 'play', ['MagicRockHit'])
	elif type == Type.ThrowSpear:
		var attack_amount := ActionUtils.damage_with_factor(stats.attack, 0.75)
		hit_type = ActionUtils.add_attack(animation, actioner, target, attack_amount, 5)
		animation.tween_callback(Sounds, 'play', ['Slash'])
	else:
		assert(false)
	
	if not narration_key.empty():
		if narration_variations > 0:
			ActionUtils.add_text_trigger_ordered(animation, self, narration_key, narration_variations, 1)
		else:
			ActionUtils.add_text_trigger_limited(animation, self, narration_key)
		
		if hit_type == ActionUtils.HitType.CriticalHit and type == Type.ThrowSpear:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_THROW_SPEAR_USE_WITH_CRIT')
	elif type == Type.MagicThrowRock:
		var throw_rock_hand := get_parent().get_child(0)
		assert(throw_rock_hand.name == 'ThrowRock')
		
		if throw_rock_hand.is_used() and not is_used():
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_THROW_A_ROCK_WITH_MAGIC_USE_ALT')
		else:
			ActionUtils.add_text_trigger_ordered(animation, self, 'NARRATOR_THROW_A_ROCK_WITH_MAGIC_USE_', 5, 1)
		
	if hit_type != ActionUtils.HitType.Miss:
		var bruiser := NodE.get_child(target, Bruiser, false) as Bruiser
		if bruiser:
			animation.tween_callback(bruiser, 'bruise')
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_BANAN_BRUISED_BY_ROCKS')
		
		var mesmerizeds := get_tree().get_nodes_in_group('mushboy_mesmerized')
		for m in mesmerizeds:
			if not m.is_mesmerized():
				continue
			animation.tween_callback(m, 'remove_mesmerize')
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_MUSHBOY_ATTACKED_BY_GEOMANCER_MESMERIZED')
		
		if _rocks_on_fire:
			if target.filename.get_file() == 'banan.tscn':
				var transformer := target.get_node('FlameTransformer') as Transformer
				animation.tween_callback(transformer, 'request_transform')
				ActionUtils.add_text_trigger(animation, self, 'NARRATOR_BANAN_TURNS_INTO_BANAN_FOSTER_FROM_FIRE')
			else:
				var burn_probability := randf()
				if burn_probability < 1.0:
					var target_effects_list := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
					
					var burn_attack_base := stats.attack if type == Type.HandThrowRock else stats.magic_attack
					var burn_status_effect := EffectFunctions.create_burn_status_effect(burn_attack_base)
					animation.tween_callback(target_effects_list, 'add_instance', [burn_status_effect])
	
	_uses += 1
	
	animation.tween_callback(object, callback)
