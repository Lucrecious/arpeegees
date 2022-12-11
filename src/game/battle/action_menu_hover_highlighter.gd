extends Node


onready var _turn_manager := $'%TurnManager' as TurnManager
onready var _action_menu := $'%ActionMenu' as PinActionMenu
onready var _target_pointers_node := $'%TargetPointers' as Node2D

var _is_showing := false
var _target_pointers := []

func _ready() -> void:
	_action_menu.connect('shown', self, '_on_action_menu_shown')
	_action_menu.connect('hidden', self, '_on_action_menu_hidden')
	
	_turn_manager.connect('initialized', self, '_on_initialized')

func _on_initialized() -> void:
	var template := _target_pointers_node.get_child(0)
	_target_pointers.push_back(template)
	for __ in _turn_manager.get_pin_count() - 1:
		var another := template.duplicate()
		_target_pointers.push_back(another)
		_target_pointers_node.add_child(another)
	
	_show_target_pins([])

func _on_action_menu_shown() -> void:
	if _is_showing:
		return
	
	_is_showing = true
	_action_menu.connect('action_hovered', self, '_on_action_menu_action_hovered')
	_action_menu.connect('target_hovered', self, '_on_action_menu_target_hovered')

func _on_action_menu_hidden() -> void:
	if not _is_showing:
		return
	
	for p in _target_pointers:
		p.visible = false
	
	_is_showing = false
	_action_menu.disconnect('action_hovered', self, '_on_action_menu_action_hovered')
	_action_menu.disconnect('target_hovered', self, '_on_action_menu_target_hovered')
	for p in _turn_manager.get_pins():
		p.modulate = Color.white

func _on_action_menu_target_hovered(target) -> void:
	_darken_pins(_turn_manager.get_pins())
	if target is Array:
		_whiten_pins(target)
		_show_target_pins(target)
	elif target is ArpeegeePinNode:
		_whiten_pins([target])
		_show_target_pins([target])

func _on_action_menu_action_hovered(action_node: Node) -> void:
	if not action_node:
		_whiten_pins(_turn_manager.get_pins())
		_show_target_pins([])
		return
	
	var action := action_node.pin_action() as PinAction
	if action.target_type == PinAction.TargetType.Self:
		_darken_pins(_turn_manager.get_pins())
		_whiten_pins([_turn_manager.get_turn_pin()])
		_show_target_pins([_turn_manager.get_turn_pin()])
	elif action.target_type == PinAction.TargetType.AllEnemies\
			or action.target_type == PinAction.TargetType.Single:
		
		var turn_pin := _turn_manager.get_turn_pin()
		var highlights := []
		
		if turn_pin.resource.type == ArpeegeePin.Type.NPC:
			highlights = _turn_manager.get_players()
		elif turn_pin.resource.type == ArpeegeePin.Type.Player:
			highlights = _turn_manager.get_npcs()
		else:
			assert(false)
		
		_darken_pins(_turn_manager.get_pins())
		_whiten_pins(highlights)
		var faded := bool(action.target_type == PinAction.TargetType.Single)
		_show_target_pins(highlights, faded)
	elif action.target_type == PinAction.TargetType.AllAllies:
		var turn_pin := _turn_manager.get_turn_pin()
		var highlights := []
		
		if turn_pin.resource.type == ArpeegeePin.Type.NPC:
			highlights = _turn_manager.get_npcs()
		elif turn_pin.resource.type == ArpeegeePin.Type.Player:
			highlights = _turn_manager.get_players()
		else:
			assert(false)
		
		_darken_pins(_turn_manager.get_pins())
		_whiten_pins(highlights)
		_show_target_pins(highlights, false)
	elif action.target_type == PinAction.TargetType.Heal3:
		_darken_pins(_turn_manager.get_pins())
		
		var fishguy := _turn_manager.get_pin_by_filename('fishguy.tscn')
		var highlights := _turn_manager.get_players() + [fishguy]
		_whiten_pins(highlights)
		_show_target_pins(highlights, true)

func _show_target_pins(pins: Array, faded := false) -> void:
	for p in _target_pointers:
		p.visible = false
	
	for i in pins.size():
		var pin := pins[i] as ArpeegeePinNode
		var health := NodE.get_child(pin, Health) as Health
		if health.current <= 0:
			continue
		
		var pointer := _target_pointers[i] as Node2D
		pointer.visible = true
		if faded:
			pointer.modulate.a = 0.5
		else:
			pointer.modulate.a = 1.0
		
		var bounding_box := NodE.get_child(pin, REferenceRect) as REferenceRect
		var rect := bounding_box.global_rect()
		var pointer_location := rect.get_center() + Vector2.UP * (rect.size.y / 2.0 + 16.0)
		pointer.global_position = pointer_location

func _darken_pins(pins: Array) -> void:
	for p in pins:
		p.modulate = Color(0.5, 0.5, 0.5)

func _whiten_pins(pins: Array) -> void:
	for p in pins:
		p.modulate = Color.white
