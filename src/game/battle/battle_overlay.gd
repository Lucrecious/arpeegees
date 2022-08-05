extends Control

const ActionMenuScene := preload('res://src/game/battle/action_menu.tscn')

onready var _target_selector := $'%TargetSelector' as TargetSelector
onready var _turn_manager := $TurnManager as TurnManager

func _ready() -> void:
	_turn_manager.connect('player_turn_started', self, '_on_player_turn_started')

func _on_player_turn_started() -> void:
	var pin := _turn_manager.get_turn_pin()
	_show_action_menu(pin)

func _show_action_menu(pin: ArpeegeePinNode) -> void:
	var actions_node := NodE.get_child(pin, PinActions) as PinActions
	var action_nodes := actions_node.get_pin_action_nodes()
	
	var action_menu := ActionMenuScene.instance() as PinActionMenu
	add_child(action_menu)
	var menu_corner := ActionUtils.get_top_right_corner_screen(pin)
	action_menu.rect_position = menu_corner
	
	_turn_manager.connect('action_started', self, '_on_action_started', [action_menu], CONNECT_ONESHOT)
	_turn_manager.connect('action_ended', self, '_on_action_ended', [], CONNECT_ONESHOT)
	
	for node in action_nodes:
		var action := node.pin_action() as PinAction
		var button := action_menu.add_pin_action(action)
		
		if action.target_type == PinAction.TargetType.Single:
			button.connect('pressed', self, '_on_single_target_action_pressed', [pin, node.name])
		elif action.target_type == PinAction.TargetType.Self:
			button.connect('pressed', _turn_manager, 'run_action', [pin, node.name])
		else:
			assert(false)

func _on_single_target_action_pressed(pin: ArpeegeePinNode, action_name: String) -> void:
	_pick_target(pin, action_name)

func _pick_target(pin: ArpeegeePinNode, action_name: String) -> void:
	_target_selector.connect('target_found', self, '_on_target_found',
			[pin, action_name], CONNECT_ONESHOT)
	_target_selector.start(pin, _turn_manager.get_npcs())

func _on_action_started(menu: PinActionMenu) -> void:
	menu.queue_free()

func _on_action_ended() -> void:
	_turn_manager.call_deferred('next_turn')

func _on_target_found(target: ArpeegeePinNode, caster: ArpeegeePinNode, action_name: String) -> void:
	_turn_manager.run_action_with_target(caster, action_name, target)

func _on_action_pressed(menu: PinActionMenu, pin: ArpeegeePinNode, action_node: Node,
	object: Object, callback: String) -> void:
	menu.queue_free()
	
	if pin.resource.type == ArpeegeePin.Type.Player:
		action_node.run_action_with_target()
