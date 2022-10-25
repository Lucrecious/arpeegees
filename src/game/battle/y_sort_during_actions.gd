extends Node

export(NodePath) var _turn_manager_path := NodePath()

onready var _turn_manager := NodE.get_node(self, _turn_manager_path, TurnManager) as TurnManager

func _ready() -> void:
	set_process(false)
	
	_turn_manager.connect('pins_changed', self, '_on_pins_changed')
	_update_pin_connects()

func _on_pins_changed() -> void:
	_update_pin_connects()

var _tracking_pins := []
func _update_pin_connects() -> void:
	for p in _tracking_pins:
		var actions := NodE.get_child(p, PinActions) as PinActions
		actions.disconnect('action_started', self, '_on_action_started')
		actions.disconnect('action_ended', self, '_on_action_ended')
	
	_tracking_pins.clear()
	
	_tracking_pins = _turn_manager.get_pins()
	
	for p in _tracking_pins:
		var actions := NodE.get_child(p, PinActions) as PinActions
		actions.connect('action_started', self, '_on_action_started')
		actions.connect('action_ended', self, '_on_action_ended')
		

func _on_action_started() -> void:
	set_process(true)

func _on_action_ended() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if Engine.get_idle_frames() % 5 != 0:
		return
	
	if _tracking_pins.empty():
		return
	
	_tracking_pins.sort_custom(self, '_sort_based_on_y')
	var control_sibling_count := _tracking_pins[0].get_parent().get_parent().get_child_count() as int
	var pins_count := _tracking_pins.size()
	for i in _tracking_pins.size():
		var pin := _tracking_pins[i] as ArpeegeePinNode
		var control := pin.get_parent() as Control
		assert(control)
		if not control:
			continue
		
		control.get_parent().move_child(control, control_sibling_count - (pins_count - i))

func _sort_based_on_y(pin: ArpeegeePinNode, other: ArpeegeePinNode) -> bool:
	return pin.global_position.y < other.global_position.y
