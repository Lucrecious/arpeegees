extends Control

const ActionMenuScene := preload('res://src/game/battle/action_menu.tscn')

var _action_menu: PinActionMenu

onready var _target_selector := $'%TargetSelector' as TargetSelector
onready var _battle_layer := $'%BattleLayer' as Node2D
onready var _stats_panel := $StatsPanel as StatPopup
onready var _turn_manager := $TurnManager as TurnManager

func _ready() -> void:
	_action_menu = ActionMenuScene.instance() as PinActionMenu
	
	var original_mouse_filter := mouse_filter
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_turn_manager.connect('initialized', self, 'set', ['mouse_filter', original_mouse_filter])
	
	add_child(_action_menu)
	move_child(_action_menu, 0)
	
	_action_menu.visible = false
	
	_turn_manager.connect('player_turn_started', self, '_on_player_turn_started')
	
	connect('mouse_exited', self, '_on_mouse_exited')

func _on_player_turn_started() -> void:
	var pin := _turn_manager.get_turn_pin()
	_show_action_menu(pin)

func _show_action_menu(pin: ArpeegeePinNode) -> void:
	var actions_node := NodE.get_child(pin, PinActions) as PinActions
	var action_nodes := actions_node.get_pin_action_nodes()
	
	var menu_corner := ActionUtils.get_top_right_corner_screen(pin)
	_action_menu.visible = true
	_action_menu.rect_position = menu_corner
	
	_turn_manager.connect('action_started', self, '_on_action_started', [_action_menu], CONNECT_ONESHOT)
	_turn_manager.connect('action_ended', self, '_on_action_ended', [], CONNECT_ONESHOT)
	
	for node in action_nodes:
		var action := node.pin_action() as PinAction
		var button := _action_menu.add_pin_action(action)
		
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
	menu.clear()
	menu.visible = false

func _on_action_ended() -> void:
	_turn_manager.call_deferred('next_turn')

func _on_target_found(target: ArpeegeePinNode, caster: ArpeegeePinNode, action_name: String) -> void:
	_turn_manager.run_action_with_target(caster, action_name, target)

var _current_pin: ArpeegeePinNode
func _gui_input(event: InputEvent) -> void:
	if _turn_manager.is_running_action():
		return
	
	if _current_pin:
		return
	
	if not event is InputEventMouseMotion:
		return
	
	var pin := _get_hovering_pin()
	if pin == _current_pin:
		return
	
	_current_pin = pin
	
	if _current_pin:
		_stats_panel.visible = true
		_stats_panel.set_as_toplevel(true)
		_show_stats(_current_pin)

func _on_mouse_exited() -> void:
	_current_pin = null
	_stats_panel.visible = false
	_stats_panel.set_as_toplevel(false)

func _input(event):
	if not _current_pin:
		return
	
	if not event is InputEventMouseMotion:
		return
	
	var pin := _get_hovering_pin()
	if pin:
		return
	
	_current_pin = null
	_stats_panel.visible = false
	_stats_panel.set_as_toplevel(false)

func _show_stats(pin: ArpeegeePinNode) -> void:
	_stats_panel.apply_pin(pin)
	var position := ActionUtils.get_top_right_corner_screen(pin)
	_stats_panel.rect_position = position
	_stats_panel.visible = true
	_stats_panel.set_as_toplevel(true)

func _get_hovering_pin() -> ArpeegeePinNode:
	var pins := NodE.get_children(_battle_layer, ArpeegeePinNode)
	for p in pins:
		var bounding_box := NodE.get_child(p, REferenceRect) as REferenceRect
		var rect := bounding_box.global_rect()
		var mouse_point := get_global_mouse_position()
		if not rect.has_point(mouse_point):
			continue
		
		return p
	
	return null
