extends Node2D

signal text_triggered(narration_key)

enum Type {
	Candle,
	GetBrighter,
	FallOver,
}

export(Type) var type := Type.Candle

var _is_blocked := false
func is_blocked() -> bool:
	return _is_blocked

func pin_action() -> PinAction:
	if type == Type.Candle:
		return preload('res://src/resources/actions/candle_candle.tres')
	elif type == Type.GetBrighter:
		return preload('res://src/resources/actions/get_brighter_candle.tres')
	elif type == Type.FallOver:
		return preload('res://src/resources/actions/fallover_candle.tres')
	else:
		assert(false)
		return preload('res://src/resources/actions/candle_candle.tres')

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	animation.tween_interval(0.35)
	
	var sprite_switcher := NodE.get_child(actioner, SpriteSwitcher) as SpriteSwitcher
	var frame := 'idle'
	if type == Type.GetBrighter:
		frame = 'brighter'
		_is_blocked = true
	elif type == Type.FallOver:
		frame = 'fallover'
		get_parent().get_node('GetBrighter')._is_blocked = true
		_is_blocked = true
	
	animation.tween_callback(sprite_switcher, 'swap_map', ['idle', frame])
	
	if type == Type.FallOver:
		animation.tween_callback(Sounds, 'play', ['DamageSlip'])
	elif type == Type.GetBrighter:
		animation.tween_callback(Sounds, 'play', ['DamageBurn'])
	
	if type == Type.Candle:
		ActionUtils.add_text_trigger_ordered(animation, self, 'NARRATOR_CANDLE_USE_', 12, 1)
	elif type == Type.GetBrighter:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_GET_BRIGHTER_USE')
	elif type == Type.FallOver:
		ActionUtils.add_text_trigger(animation, self, 'NARRATOR_FALL_OVER_USE')
	
	animation.tween_interval(0.35)
	
	animation.tween_callback(object, callback)
