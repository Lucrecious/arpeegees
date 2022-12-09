extends Node2D

signal text_triggered(narration_text)

enum Type {
	HandThrowRock,
	MagicThrowRock,
	ThrowSpear,
}

export(Type) var type := Type.HandThrowRock
export(String) var throw_frame := ''
export(String) var narration_key := ''

onready var _thing := get_child(0) as Node2D

var _used := false

func is_used() -> bool:
	return _used

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
	
	animation.tween_callback(Sounds, 'play', ['GenericWindUp1'])
	
	var material := Components.root_sprite(actioner).material as ShaderMaterial
	TweenJuice.skew(animation, material, 0.0, side * 1.0, 0.35)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	animation.tween_interval(0.8)
	
	TweenJuice.skew(animation, material, side * 1.0, 0.0, 0.1)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', [throw_frame])
	
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
	else:
		assert(false)
	
	if not narration_key.empty():
		ActionUtils.add_text_trigger(animation, self, narration_key)
		if hit_type == ActionUtils.HitType.CriticalHit and type == Type.ThrowSpear:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_THROW_SPEAR_USE_WITH_CRIT')
	elif type == Type.MagicThrowRock:
		var throw_rock_hand := get_parent().get_child(0)
		assert(throw_rock_hand.name == 'ThrowRock')
		
		if throw_rock_hand.is_used() and not is_used():
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_THROW_A_ROCK_WITH_MAGIC_USE_ALT')
		else:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_THROW_A_ROCK_WITH_MAGIC_USE')
	
		
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
	
	_used = true
	
	animation.tween_callback(object, callback)
