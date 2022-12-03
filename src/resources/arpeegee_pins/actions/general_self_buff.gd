class_name GenericSelfBuffSpell
extends Node2D

signal text_triggered(narration_key)

export(Resource) var pin_action: Resource = null
export(String) var use_frame := ''
export(String) var use_vfx_call := ''
export(String) var effect_call := ''
export(String) var narration_key := ''
export(String) var sfx := ''


func pin_action() -> PinAction:
	return pin_action as PinAction

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	
	animation.tween_interval(0.5)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	if not use_frame.empty():
		animation.tween_callback(sprite_switcher, 'change', [use_frame])
	
	if not use_vfx_call.empty():
		animation.tween_callback(VFX, use_vfx_call, [actioner])
	
	if not sfx.empty():
		var sounds := NodE.get_child(actioner, SoundsComponent)
		animation.tween_callback(sounds, 'play', [sfx])
	
	if not effect_call.empty():
		animation.tween_callback(EffectFunctions, effect_call, [actioner])
	
	if not narration_key.empty():
		ActionUtils.add_text_trigger(animation, self, narration_key)
	
	animation.tween_interval(0.75)
	
	if not use_frame.empty():
		animation.tween_callback(sprite_switcher, 'change', ['idle'])
	
	animation.tween_callback(object, callback)
