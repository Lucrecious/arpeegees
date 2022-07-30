class_name TurnManager
extends Control

var _ordered_pins := []

func initialize_turns(pins: Array) -> void:
	_ordered_pins = pins.duplicate()
	_ordered_pins.sort_custom(self, '_by_playable_by_topdown')
	
	for p in _ordered_pins:
		var pin_actions := NodE.get_child(p, PinActions, false) as PinActions
		
		if not pin_actions:
			continue
		else:
			pin_actions.run_action_with_target('BardAttack', _ordered_pins[-1])
			return

func _by_playable_by_topdown(node1: ArpeegeePinNode, node2: ArpeegeePinNode) -> bool:
	var resource1 := node1.resource
	var resource2 := node2.resource
	if resource1.type == resource2.type:
		return node1.global_position.y < node2.global_position.y
	
	return resource1.type == ArpeegeePin.Type.Player
