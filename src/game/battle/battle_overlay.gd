extends Control

onready var _battle_layer := $'%BattleLayer' as Node2D
onready var _stats_panel := $StatsPanel as StatPopup
onready var _turn_manager := $TurnManager as TurnManager
onready var _narrator := NodE.get_sibling(self, NarratorUI) as NarratorUI
onready var _situational_dialog := $SituationalDialog as SituationalDialog
onready var _ai := $AI as NPCAI
onready var _action_menu := $'%ActionMenu' as PinActionMenu
onready var _character_pointer := $'%CharacterPointer' as Node2D

var play_as_npcs := false

func _ready() -> void:
	_turn_manager.connect('initialized', self, 'set', ['mouse_filter', mouse_filter])
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_action_menu.hidden()
	
	connect('mouse_exited', self, '_on_mouse_exited')
	
	_turn_manager.connect('player_turn_started', self, '_on_player_turn_started')
	if Debug.play_as_npcs:
		_turn_manager.connect('npc_turn_started', self, '_on_player_turn_started')
	
	_turn_manager.connect('turn_finished', self, '_on_turn_finished')
	
	_turn_manager.connect('pins_changed', self, '_on_pins_changed')
	_on_pins_changed()
	
	_turn_manager.connect('initialized', self, '_update_character_pointer', [], CONNECT_ONESHOT)
	get_viewport().connect('size_changed', self, '_update_character_pointer')

func _update_character_pointer() -> void:
	var pin := _turn_manager.get_turn_pin()
	
	var bounding_box := NodE.get_child(pin, REferenceRect) as REferenceRect
	var rect := bounding_box.global_rect()
	
	var selector_location := rect.get_center() + Vector2.DOWN * ((rect.size.y / 2.0) + 16.0)
	_character_pointer.global_position = selector_location

var _pins_cache := []
func _on_pins_changed() -> void:
	_previous_pin_turn = null
	if _turn_manager.get_pin_count() > 0:
		_previous_pin_turn = _turn_manager.get_turn_pin()
	
	for pin in _pins_cache:
		var health := NodE.get_child(pin, Health) as Health
		health.disconnect('increased', self, '_on_pin_health_changed')
		health.disconnect('damaged', self, '_on_pin_health_changed')
		
		var damage_receiver := NodE.get_child(pin, DamageReceiver) as DamageReceiver
		damage_receiver.disconnect('critical_hit', self, '_on_pin_critical_hit_or_evaded')
		damage_receiver.disconnect('evaded', self, '_on_pin_critical_hit_or_evaded')
		
		var modified_stats := NodE.get_child(pin, ModifiedPinStats) as ModifiedPinStats
		modified_stats.disconnect('changed_relatives', self, '_on_pin_changed_relatives')
	
	_pins_cache = _turn_manager.get_pins()
	for pin in _pins_cache:
		var health := NodE.get_child(pin, Health) as Health
		health.connect('increased', self, '_on_pin_health_changed', [pin, false])
		health.connect('damaged', self, '_on_pin_health_changed', [pin, true])
		
		var damage_receiver := NodE.get_child(pin, DamageReceiver) as DamageReceiver
		damage_receiver.connect('critical_hit', self, '_on_pin_critical_hit_or_evaded', [pin, true])
		damage_receiver.connect('evaded', self, '_on_pin_critical_hit_or_evaded', [pin, false])
		
		var modified_stats := NodE.get_child(pin, ModifiedPinStats) as ModifiedPinStats
		modified_stats.connect('changed_relatives', self, '_on_pin_changed_relatives', [pin])

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
			_do_turn_section_start(ArpeegeePin.Type.NPC)
		elif _previous_pin_turn.resource.type == ArpeegeePin.Type.NPC\
				and current.resource.type == ArpeegeePin.Type.Player:
			_do_turn_section_start(ArpeegeePin.Type.Player)
	
	_previous_pin_turn = current
	var tween := create_tween()
	tween.tween_interval(0.1)
	TweenExtension.pause_until_signal_if_condition(tween, _narrator, 'speaking_ended',
			_narrator, 'is_speaking')
	
	tween.tween_interval(0.01)
	return tween

func _do_turn_section_start(type: int) -> void:
	var keys := _situational_dialog.get_overall_turn_started_dialog(type)
	if keys.empty():
		return
	
	if keys.size() == 1:
		var chain := false
		_narrator.speak_tr(keys[0], chain)
	else:
		print_debug(keys)
		assert(false, 'multiple keys is not implemented yet')

func _show_action_menu(pin: ArpeegeePinNode, pin_actions: PinActions) -> void:
	var action_nodes := pin_actions.get_pin_action_nodes()
	
	_action_menu.initialize(pin)
	_action_menu.connect('action_picked', self, '_on_action_picked', [pin, _action_menu], CONNECT_ONESHOT)
	
	if pin.resource.type == ArpeegeePin.Type.Player:
		for node in action_nodes:
			var action := node.pin_action() as PinAction
			
			if action.target_type == PinAction.TargetType.Single:
				_action_menu.add_pin_action(node, _turn_manager.get_npcs())
			elif action.target_type == PinAction.TargetType.Self:
				_action_menu	.add_pin_action(node, [])
			elif action.target_type == PinAction.TargetType.AllEnemies:
				_action_menu.add_pin_action(node, [])
			elif action.target_type == PinAction.TargetType.AllAllies:
				_action_menu.add_pin_action(node, [])
			else:
				assert(false)
	elif pin.resource.type == ArpeegeePin.Type.NPC:
		for node in action_nodes:
			var action := node.pin_action() as PinAction
			
			if action.target_type == PinAction.TargetType.Single:
				_action_menu.add_pin_action(node, _turn_manager.get_players())
			elif action.target_type == PinAction.TargetType.Self:
				_action_menu	.add_pin_action(node, [])
			elif action.target_type == PinAction.TargetType.AllEnemies:
				_action_menu.add_pin_action(node, [])
			elif action.target_type == PinAction.TargetType.AllAllies:
				_action_menu.add_pin_action(node, [])
			else:
				assert(false)
	else:
		assert(false)

func _on_action_picked(action_node: Node, targets: Array, pin: ArpeegeePinNode, menu: PinActionMenu) -> void:
	menu.clear()
	
	if pin.resource.type == ArpeegeePin.Type.Player:
		var action := action_node.pin_action() as PinAction
		if action.target_type == PinAction.TargetType.Single:
			assert(targets.size() == 1)
			_turn_manager.run_action_with_target(pin, action_node.name, targets[0])
		elif action.target_type == PinAction.TargetType.Self:
			assert(targets.size() == 0)
			_turn_manager.run_action(pin, action_node.name)
		elif action.target_type == PinAction.TargetType.AllEnemies:
			assert(targets.size() == 0)
			_turn_manager.run_action_with_targets(pin, action_node.name, _turn_manager.get_npcs())
		elif action.target_type == PinAction.TargetType.AllAllies:
			assert(targets.size() == 0)
			_turn_manager.run_action_with_targets(pin, action_node.name, _turn_manager.get_players())
		else:
			assert(false)
	elif pin.resource.type == ArpeegeePin.Type.NPC:
		var action := action_node.pin_action() as PinAction
		if action.target_type == PinAction.TargetType.Single:
			assert(targets.size() == 1)
			_turn_manager.run_action_with_target(pin, action_node.name, targets[0])
		elif action.target_type == PinAction.TargetType.Self:
			assert(targets.size() == 0)
			_turn_manager.run_action(pin, action_node.name)
		elif action.target_type == PinAction.TargetType.AllEnemies:
			assert(targets.size() == 0)
			_turn_manager.run_action_with_targets(pin, action_node.name, _turn_manager.get_players())
		elif action.target_type == PinAction.TargetType.AllAllies:
			assert(targets.size() == 0)
			_turn_manager.run_action_with_targets(pin, action_node.name, _turn_manager.get_npcs())
		else:
			assert(false)

func _on_turn_finished() -> void:
	_transition_to_next_turn()

func _transition_to_next_turn() -> void:
	var tween := create_tween()
	
	TweenExtension.pause_until_signal_if_condition(tween, _narrator, 'speaking_ended',
			_narrator, 'is_speaking')
	
	tween.tween_callback(self, '_next_turn')

func _next_turn() -> void:
	_update_character_pointer()
	var pin := _turn_manager.get_turn_pin()
	Logger.info('turn started for pin "%s" at turn %d' % [pin.name, _turn_manager.turn_count()])
	
	var tween := _on_turn_started_preview()
	
	tween.tween_callback(_turn_manager, 'step_turn')

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

func _on_pin_critical_hit_or_evaded(pin: ArpeegeePinNode, is_critical: bool) -> void:
	if is_critical:
		VFX.floating_text(pin, 'CRITICAL!!', pin.get_parent())
	else:
		VFX.floating_text(pin, 'MISS', pin.get_parent())

func _on_pin_changed_relatives(relatives: Dictionary, pin: ArpeegeePinNode) -> void:
	var texts := []
	
	for type in relatives:
		if type == StatModifier.Type.MaxHealth:
			continue
		
		var relative := relatives[type] as int
		if relative == 0:
			continue
		
		var type_as_string := StatModifier.type_to_string(type)
		var sign_ := '+' if relative > 0 else '-'
		var text := '%s %s %d' % [type_as_string, sign_, abs(relative)]
		texts.push_back(text)
	
	if texts.empty():
		return
	
	var animation := create_tween()
	for t in texts:
		animation.tween_callback(VFX, 'floating_text', [pin, t, pin.get_parent()])
		animation.tween_interval(1.5)

func _spawn_health_changed_floaty_number(pin: ArpeegeePinNode, amount: int, damaged: bool) -> void:	
	amount = amount if not damaged else -amount
	VFX.floating_number(pin, amount, pin.get_parent())
