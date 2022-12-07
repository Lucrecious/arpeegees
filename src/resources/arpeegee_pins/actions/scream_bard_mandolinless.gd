extends Node2D

const BrokenNotes := preload('res://src/vfx/broken_notes.tscn')

signal text_triggered(narration_key)

var boosted := false
var is_this_food := false

onready var _position_hint := $Hint as Node2D

func pin_action() -> PinAction:
	return preload('res://src/resources/actions/scream_bard_mandolinless.tres') as PinAction

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	if is_this_food and IsThisFood.too_sad_to_attack():
		IsThisFood.add_is_this_food(animation, self, object, callback)
		return
	
	var root_sprite := Components.root_sprite(actioner)
	var material := root_sprite.material as ShaderMaterial
	TweenJuice.skew(animation, material, 0.0, 0.5, 1.0)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	animation.tween_interval(0.35)
	
	TweenJuice.skew(animation, material, 0.5, 0.0, 0.1)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['scream'])
	
	var thing := BrokenNotes.instance() as Node2D
	thing.z_index = 1
	thing.visible = false
	actioner.add_child(thing)
	
	animation.tween_callback(thing, 'set', ['global_position', _position_hint.global_position])
	animation.tween_callback(thing, 'set', ['visible', true])
	
	var target_position := NodE.get_child(target, REferenceRect).global_rect().get_center() as Vector2
	animation.tween_property(thing, 'global_position', target_position, 0.35)
	
	var stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var factor := 1.0
	if boosted:
		factor = 2.0
	
	var damage := ActionUtils.damage_with_factor(stats.attack, factor)
	ActionUtils.add_attack(animation, actioner, target, damage)
	animation.tween_callback(VFX, 'physical_impactv', [target, target_position])
	
	animation.tween_callback(thing, 'queue_free')
	
	ActionUtils.add_text_trigger(animation, self, 'NARRATOR_SCREAM_USE')
	
	animation.tween_interval(1.0)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)

func _shoot_projectile() -> void:
	var thing := BrokenNotes.instance()
	
