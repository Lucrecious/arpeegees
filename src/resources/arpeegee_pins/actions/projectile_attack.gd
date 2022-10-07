extends Node2D

signal text_triggered(translation)

export(Resource) var pin_action: Resource = null

func pin_action() -> PinAction:
	assert(pin_action is PinAction)
	return pin_action as PinAction

func run(actioner: Node2D, targets: Array, object: Object, callback: String) -> void:
	pass
