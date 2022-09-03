extends Control

const ActionMenuScene := preload('res://src/game/battle/action_menu.tscn')

var _action_menu: PinActionMenu

onready var _target_selector := $'%TargetSelector' as TargetSelector
onready var _battle_layer := $'%BattleLayer' as Node2D
onready var _stats_panel := $StatsPanel as StatPopup
onready var _turn_manager := $TurnManager as TurnManager
onready var _narrator := NodE.get_sibling(self, NarratorUI) as NarratorUI
onready var _situational_dialog := $SituationalDialog as SituationalDialog
onready var _ai := $AI as NPCAI

func _ready() -> void:
	_action_menu = ActionMenuScene.instance() as PinActionMenu
	
	_turn_manager.connect('initialized', self, 'set', ['mouse_filter', mouse_filter])
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	add_child(_action_menu)
	move_child(_action_menu, 0)
	
	_action_menu.visible = false
	
	connect('mouse_exited', self, '_on_mouse_exited')
	
	_turn_manager.connect('player_turn_started', self, '_on_player_turn_started')
	
	_turn_manager.connect('turn_finished', self, '_on_turn_finished')
	
	_turn_manager.connect('pins_changed', self, '_on_pins_changed')
	_on_pins_changed()

var _pins_cache := []
func _on_pins_changed() -> void:
	_previous_pin_turn = null
	if _turn_manager.get_pin_count() > 0:
		_previous_pin_turn = _turn_manager.get_turn_pin()
	
	for pin in _pins_cache:
		var health := NodE.get_child(pin, Health) as Health
		health.disconnect('increased', self, '_on_pin_health_changed')
		health.disconnect('damaged', self, '_on_pin_health_changed')
	
	_pins_cache = _turn_manager.get_pins()
	for pin in _pins_cache:
		var health := NodE.get_child(pin, Health) as Health
		health.connect('increased', self, '_on_pin_health_changed', [pin, false])
		health.connect('damaged', self, '_on_pin_health_changed', [pin, true])

func _on_player_turn_started() -> void:
	var pin := _turn_manager.get_turn_pin()
	var pin_actions := NodE.get_child(pin, PinActions) as PinActions
	if not pin_actions.get_pin_action_nodes().empty():
		_show_action_menu(pin, pin_actions)
	else:
		_turn_manager.finish_turn()

var _previous_pin_turn: ArpeegeePinNode
func _on_turn_started_preview() -> SceneTreeTween:
	var current := _turn_manager.get_turn_pin()
	if _previous_pin_turn and not _turn_manager._is_all_dead([current]):
		if _previous_pin_turn.resource.type == ArpeegeePin.Type.Player\
				and current.resource.type == ArpeegeePin.Type.NPC:
			_do_npc_turn_section_start()
	
	_previous_pin_turn = current
	var tween := create_tween()
	if _narrator.is_speaking():
		tween.tween_interval(0.1)
		TweenExtension.pause_until_signal(tween, _narrator, 'speaking_ended')
	
	tween.tween_interval(0.01)
	return tween

func _do_npc_turn_section_start() -> void:
	var keys := _situational_dialog.npc_overall_turn_started_dialog()
	if keys.empty():
		return
	
	if keys.size() == 1:
		var chain := false
		_narrator.speak_tr(keys[0], chain)
	else:
		assert(false, 'multiple keys is not implemented yet')

func _show_action_menu(pin: ArpeegeePinNode, pin_actions: PinActions) -> void:
	var action_nodes := pin_actions.get_pin_action_nodes()
	
	var menu_corner := ActionUtils.get_top_right_corner_screen(pin)
	_action_menu.visible = true
	_action_menu.rect_position = menu_corner
	
	for node in action_nodes:
		var action := node.pin_action() as PinAction
		var button := _action_menu.add_pin_action(action)
		button.connect('pressed', self, '_on_action_started', [_action_menu], CONNECT_ONESHOT)
		
		if action.target_type == PinAction.TargetType.Single:
			button.connect('pressed', self, '_on_single_target_action_pressed', [pin, node.name])
		elif action.target_type == PinAction.TargetType.Self:
			button.connect('pressed', _turn_manager, 'run_action', [pin, node.name])
		elif action.target_type == PinAction.TargetType.AllEnemies:
			button.connect('pressed', _turn_manager, 'run_action_with_targets', [pin, node.name, _turn_manager.get_npcs()])
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

func _on_turn_finished() -> void:
	var tween := create_tween()
	
	if _narrator.is_speaking():
		TweenExtension.pause_until_signal(tween, _narrator, 'speaking_ended')
	
	tween.tween_callback(self, '_next_turn')

func _next_turn() -> void:
	var tween := _on_turn_started_preview()
	tween.tween_callback(_turn_manager, 'step_turn')
	

func _on_target_found(target: ArpeegeePinNode, caster: ArpeegeePinNode, action_name: String) -> void:
	_turn_manager.run_action_with_target(caster, action_name, target)

var _current_pin: ArpeegeePinNode
func _gui_input(event: InputEvent) -> void:
	return
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
	return
	_current_pin = null
	_stats_panel.visible = false
	_stats_panel.set_as_toplevel(false)

func _input(event):
	return
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
	return
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

func _on_pin_health_changed(amount: int, pin: ArpeegeePinNode, damaged: bool) -> void:
	_spawn_health_changed_floaty_number(pin, amount, damaged)

func _spawn_health_changed_floaty_number(pin: ArpeegeePinNode, amount: int, damaged: bool) -> void:	
	amount = amount if not damaged else -amount
	VFX.floating_number(pin, amount, self)
