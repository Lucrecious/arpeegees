extends Node2D

signal text_triggered(narration_key)

enum Type {
	Candle,
	GetBrighter,
}

export(Type) var type := Type.Candle

func pin_action() -> PinAction:
	if type == Type.Candle:
		return preload('res://src/resources/actions/candle_candle.tres')
	elif type == Type.GetBrighter:
		return preload('res://src/resources/actions/get_brighter_candle.tres')
	else:
		assert(false)
		return preload('res://src/resources/actions/candle_candle.tres')

func run(actioner: Node2D, object: Object, callback: String) -> void:
	var animation := create_tween()
	animation.tween_interval(1.0)
	
	animation.tween_callback(object, callback)
