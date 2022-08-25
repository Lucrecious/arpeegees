class_name StartTurnEffectRunner
extends Node

signal finished()

var _is_busy := false

func run(pin: ArpeegeePinNode) -> bool:
	if _is_busy:
		print_stack()
		printerr('error, tried to run start effects while they were playing...')
		return false
	
	var status_effects := NodE.get_child(pin, StatusEffectsList) as StatusEffectsList
	var effects := status_effects.get_all()
	
	var start_turn_effects := []
	for effect in effects:
		start_turn_effects += (effect.get_start_turn_effects() as Array)
	
	if start_turn_effects.empty():
		return false
	
	_is_busy = true
	_run(start_turn_effects, 0)
	return true

func _finished() -> void:
	_is_busy = false
	emit_signal('finished')

func _run(start_turn_effects: Array, index: int) -> void:
	if index >= start_turn_effects.size():
		call_deferred('_finished')
		return
	
	var effect = start_turn_effects[index]
	
	index += 1
	
	if not effect.has_signal('start_turn_effect_finished'):
		printerr('warning start node effect at %s does not start_turn_effect_finished signal' % [effect.get_path()])
		_run(start_turn_effects, index)
		return
	
	effect.connect('start_turn_effect_finished', self, '_run', [start_turn_effects, index], CONNECT_ONESHOT)
	effect.run_start_turn_effect()
