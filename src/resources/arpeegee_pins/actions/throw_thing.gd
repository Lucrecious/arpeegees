extends Node2D

signal text_triggered(narration_text)

enum Type {
	HandThrowRock,
	MagicThrowBack,
}

export(Type) var type := Type.HandThrowRock
export(String) var throw_frame := ''
export(String) var narration_key := ''

onready var _thing := get_child(0) as Sprite

var _used := false

func is_used() -> bool:
	return _used

func _ready() -> void:
	assert(_thing)
	_thing.visible = false

func pin_action() -> PinAction:
	if type == Type.HandThrowRock:
		return preload('res://src/resources/actions/throw_rock_no_magic_geomancer.tres')
	elif type == Type.MagicThrowBack:
		return preload('res://src/resources/actions/throw_rock_magic_geomancer.tres')
	else:
		assert(false)
		return null

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	_used = true
	
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	var material := Components.root_sprite(actioner).material as ShaderMaterial
	TweenJuice.skew(animation, material, 0.0, 1.0, 0.35)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	animation.tween_interval(0.8)
	
	TweenJuice.skew(animation, material, 1.0, 0.0, 0.1)
	
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
	
	var stats := NodE.get_child(target, ModifiedPinStats) as ModifiedPinStats
	if type == Type.HandThrowRock:
		ActionUtils.add_attack(animation, actioner, target, stats.attack)
	elif type == Type.MagicThrowBack:
		ActionUtils.add_magic_attack(animation, actioner, target, stats.magic_attack)
	else:
		assert(false)
	
	if not narration_key.empty():
		ActionUtils.add_text_trigger(animation, self, narration_key)
	elif type == Type.MagicThrowBack:
		var throw_rock_hand := get_parent().get_child(0)
		assert(throw_rock_hand.name == 'ThrowRock')
		
		if throw_rock_hand.is_used() and not is_used():
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_THROW_A_ROCK_WITH_MAGIC_USE_ALT')
		else:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_THROW_A_ROCK_WITH_MAGIC_USE')
	
	animation.tween_callback(object, callback)
