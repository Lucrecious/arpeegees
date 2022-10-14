extends Node2D

signal text_triggered(narration_key)

enum Type {
	Regular,
	OnFire,
}

export(Type) var type := Type.Regular

onready var _arrow := $Arrow as Node2D

func pin_action() -> PinAction:
	if type == Type.Regular:
		return preload('res://src/resources/actions/arrow_zip_ranger.tres')
	elif type == Type.OnFire:
		return preload('res://src/resources/actions/arrows_en_fuego_ranger.tres')
	assert(false)
	return null

func run(actioner: Node2D, target: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.4)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	animation.tween_callback(sprite_switcher, 'change', ['attack'])
	animation.tween_callback(_arrow, 'set', ['visible', true])
	animation.tween_interval(0.75)
	if type == Type.OnFire:
		animation.tween_interval(0.5)
	
	var target_box := NodE.get_child(target, REferenceRect) as REferenceRect
	var target_position := target_box.global_rect().get_center()
	animation.tween_property(_arrow, 'global_position', target_position, 0.1)
	
	var modified_stats := NodE.get_child(actioner, ModifiedPinStats) as ModifiedPinStats
	var hit_type := ActionUtils.add_attack(animation, actioner, target, modified_stats.attack)
	animation.tween_callback(VFX, 'physical_impactv', [actioner, target_position])
	
	if type == Type.OnFire and hit_type != ActionUtils.HitType.Miss:
		var burn_status_effect := EffectFunctions.create_burn_status_effect(modified_stats.attack)
		var list := NodE.get_child(target, StatusEffectsList) as StatusEffectsList
		animation.tween_callback(list, 'add_instance', [burn_status_effect])
	
	animation.tween_callback(_arrow, 'set', ['visible', false])
	animation.tween_callback(_arrow, 'set', ['global_position', _arrow.global_position])
	
	if type == Type.Regular:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_ARROW_ZIP_USE')
	elif type == Type.OnFire:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_ARROWS_EN_FUEGO_USE')
		if hit_type != ActionUtils.HitType.Miss:
			ActionUtils.add_text_trigger(animation, self, 'NARRATOR_ARROWS_EN_FUEGO_HIT_ENEMY')
	
	animation.tween_interval(0.75)
	animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)
