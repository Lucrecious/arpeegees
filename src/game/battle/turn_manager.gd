class_name TurnManager
extends Node

signal pins_changed()
signal player_turn_started()
signal npc_turn_started()
signal turn_finished()
signal battle_ended(end_condition)
signal initialized()

enum EndCondition {
	None,
	PlayersDead,
	NPCsDead,
	EveryoneDead,
}

var _ordered_pins := []
var _players := []
var _npcs := []

var _is_running_action := false
var _turn_started := false

var _current_turn := 0

var _transform_queue := []

onready var _start_turn_effect_runner := $StartTurnEffectRunner as StartTurnEffectRunner

func initialize_turns(pins: Array) -> void:
	
	_ordered_pins = pins.duplicate()
	_players = _get_type(ArpeegeePin.Type.Player)
	_npcs = _get_type(ArpeegeePin.Type.NPC)
	
	_ordered_pins.sort_custom(self, '_by_playable_by_topdown')
	
	if _ordered_pins.empty():
		assert(false)
		return
	
	for p in _ordered_pins:
		var transformer := NodE.get_child(p, Transformer, false) as Transformer
		if not transformer:
			continue
		
		transformer.connect('transform_requested', self, '_on_pin_transform_requested', [p, transformer], CONNECT_ONESHOT)
	
	Logger.info('initialized and pins_changed emitted')
	emit_signal('pins_changed')
	emit_signal('initialized')

func turn_count() -> int:
	return _current_turn

func use_item(item: PinItemPowerUp) -> void:
	item.apply_power(_ordered_pins)

func step_turn() -> void:
	Logger.info('step to turn %d' % [_current_turn])
	_do_turn(_current_turn)

func get_npcs() -> Array:
	return _npcs.duplicate()

func get_players() -> Array:
	return _players.duplicate()

func get_pins() -> Array:
	return _ordered_pins.duplicate()

func get_pin_count() -> int:
	return _ordered_pins.size()

func finish_turn() -> void:
	if _is_running_action:
		assert(false)
		return
	
	var pin := get_turn_pin()
	if not _is_all_dead([pin]):
		_run_end_turn_effects(pin)
	
	var end_condition := _is_game_finished()
	if end_condition != EndCondition.None:
		Logger.info('turn_finished and battle_ended emitted')
		emit_signal('turn_finished')
		emit_signal('battle_ended', end_condition)
		return
	
	Logger.info('turn_finished emitted')
	emit_signal('turn_finished')
	
	while true:
		_current_turn += 1
		pin = get_turn_pin()
		if not _is_all_dead([pin]):
			break
	_turn_started = false

func get_turn_pin() -> ArpeegeePinNode:
	return _ordered_pins[_current_turn % _ordered_pins.size()] as ArpeegeePinNode

func run_action_with_targets(pin: ArpeegeePinNode, action_node: String, targets: Array) -> void:
	_run_action_with_targets(pin, action_node, targets, true)

func run_action_with_target(pin: ArpeegeePinNode, action_name: String, target: ArpeegeePinNode) -> void:
	_run_action_with_targets(pin, action_name, [target], false)

func run_action(pin: ArpeegeePinNode, action_name: String) -> void:
	_run_action_with_targets(pin, action_name, [], false)

func _run_action_with_targets(pin: ArpeegeePinNode, action_name: String, targets: Array, multiple: bool) -> void:
	var actions_node := NodE.get_child(pin, PinActions) as PinActions
	actions_node.connect('action_started', self, '_on_action_started', [],
			CONNECT_ONESHOT | CONNECT_DEFERRED | CONNECT_REFERENCE_COUNTED)
	actions_node.connect('action_ended', self, '_on_action_ended', [],
			CONNECT_ONESHOT | CONNECT_DEFERRED | CONNECT_REFERENCE_COUNTED)
	
	if targets.empty():
		actions_node.run_action(action_name)
	elif targets.size() == 1 and not multiple:
		actions_node.run_action_with_targets(action_name, targets, false)
	else:
		actions_node.run_action_with_targets(action_name, targets, true)

func is_running_action() -> bool:
	return _is_running_action

func balance_battle() -> int:
	var disadvantaged_nodes := _get_disadvantaged_nodes(_ordered_pins)
	
	if disadvantaged_nodes.empty():
		return -1
	
	var type := disadvantaged_nodes[0].resource.type as int
	_add_attack_boost(disadvantaged_nodes, type)
	return type

func _get_disadvantaged_nodes(nodes: Array) -> Array:
	var players := _get_nodes_of_type(nodes, ArpeegeePin.Type.Player)
	var npcs := _get_nodes_of_type(nodes, ArpeegeePin.Type.NPC)
	
	if players.size() > npcs.size():
		return npcs
	
	if npcs.size() > players.size():
		return players
	
	return []

func _get_nodes_of_type(nodes: Array, type: int) -> Array:
	var of_type := []
	
	for n in nodes:
		var resource := n.resource as ArpeegeePin
		if resource.type != type:
			continue
		
		of_type.push_back(n)
	
	return of_type

func _add_attack_boost(nodes: Array, type: int) -> void:
	for n in nodes:
		var status_effects := NodE.get_child(n, StatusEffectsList) as StatusEffectsList
		var effect := StatusEffect.new()
		effect.tag = StatusEffectTag.Enraged
		
		var attack := StatModifier.new()
		attack.type = StatModifier.Type.Attack
		attack.multiplier = 1.5
		
		var magic_attack := StatModifier.new()
		magic_attack.type = StatModifier.Type.MagicAttack
		attack.multiplier = 1.5
		
		effect.add_child(attack)
		effect.add_child(magic_attack)
		
		match type:
			ArpeegeePin.Type.NPC:
				NodE.add_children(status_effects, Aura.create_enraged_auras())
			ArpeegeePin.Type.Player:
				print_debug('balance battle from player not implemented')
		
		status_effects.add_instance(effect)

#func _increase_evasion(nodes: Array) -> void:
#	for n in nodes:
#		var status_effects := NodE.get_child(n, StatusEffectsList) as StatusEffectsList
#
#		var effect := StatusEffect.new()
#		effect.stack_count = 1
#		effect.tag = StatusEffectTag.Enraged
#
#		var modifier := StatModifier.new()
#		modifier.type = StatModifier.Type.Evasion
#		modifier.multiplier = 1.5
#
#		effect.add_child(modifier)
#
#		status_effects.add_instance(effect)
#
#func _increase_health(nodes: Array) -> void:
#	for n in nodes:
#		var status_effects := NodE.get_child(n, StatusEffectsList) as StatusEffectsList
#		var effect := StatusEffect.new()
#		var modifier := StatModifier.new()
#		modifier.type = StatModifier.Type.MaxHealth
#		modifier.multiplier = 2.0
#
#		var health := NodE.get_child(n, Health) as Health
#		health.current = modifier.apply(health.current)
#
#		effect.add_child(modifier)
#		status_effects.add_instance(effect)

func _on_action_started() -> void:
	_is_running_action = true

func _on_action_ended() -> void:
	_do_queued_transforms()
	
	_is_running_action = false
	finish_turn()

func _do_queued_transforms() -> void:
	var changed := false
	while not _transform_queue.empty():
		var stuff := _transform_queue.pop_front() as Dictionary
		var pin := stuff.pin as ArpeegeePinNode
		
		var old_pin_index := _ordered_pins.find(pin)
		
		if old_pin_index < 0:
			continue
		
		changed = true
		
		var transformer := stuff.transformer as Transformer
		
		var new_pin := transformer.transform_scene.instance() as ArpeegeePinNode
		
		pin.get_parent().add_child(new_pin)
		new_pin.position = pin.position
		
		_ordered_pins[old_pin_index] = new_pin
		_npcs = _get_type(ArpeegeePin.Type.NPC)
		_players = _get_type(ArpeegeePin.Type.Player)
		
		pin.get_parent().remove_child(pin)
		pin.queue_free()
	
	if not changed:
		return
	
	Logger.info('pins_changed emitted')
	emit_signal('pins_changed')

func _get_type(type: int) -> Array:
	var pins_of_type := []
	for p in _ordered_pins:
		var arpeegee := p.resource as ArpeegeePin
		if arpeegee.type != type:
			continue
		pins_of_type.push_back(p)
	
	return pins_of_type

func _do_turn(turn: int) -> void:
	if _turn_started:
		return
	
	var pin := get_turn_pin()
	
	_start_turn_effect_runner.run(pin)
	var tween := create_tween()
	TweenExtension.pause_until_signal_if_condition(tween, _start_turn_effect_runner, 'finished',
			_start_turn_effect_runner, 'is_running')
	
	_turn_started = true
	var is_player := bool(pin.resource.type == ArpeegeePin.Type.Player)
	if is_player:
		tween.tween_callback(Logger, 'info', ['player_turn_started emitted'])
		tween.tween_callback(self, 'emit_signal', ['player_turn_started'])
	else:
		tween.tween_callback(Logger, 'info', ['npc_turn_started emitted'])
		tween.tween_callback(self, 'emit_signal', ['npc_turn_started'])

func _is_game_finished() -> int:
	var all_players_dead := _is_all_dead(_players)
	var all_npcs_dead := _is_all_dead(_npcs)
	
	if all_players_dead and all_npcs_dead:
		return EndCondition.EveryoneDead
	
	if all_npcs_dead:
		return EndCondition.NPCsDead
	
	if all_players_dead:
		return EndCondition.PlayersDead
	
	return EndCondition.None

func _is_all_dead(pins: Array) -> bool:
	for p in pins:
		var health := NodE.get_child(p, Health) as Health
		if not health:
			continue
		
		if health.current > 0:
			return false
	
	return true

func _by_playable_by_topdown(node1: ArpeegeePinNode, node2: ArpeegeePinNode) -> bool:
	var resource1 := node1.resource
	var resource2 := node2.resource
	if resource1.type == resource2.type:
		return node1.global_position.y < node2.global_position.y
	
	return resource1.type == ArpeegeePin.Type.Player

func _on_pin_transform_requested(pin: ArpeegeePinNode, transformer: Transformer) -> void:
	_transform_queue.push_back({ pin = pin, transformer = transformer })

func _run_end_turn_effects(pin: ArpeegeePinNode) -> void:
	var status_effects := NodE.get_child(pin, StatusEffectsList) as StatusEffectsList
	var effects := status_effects.get_all()
	
	for effect in effects:
		var end_turn_effects := effect.get_end_turn_effects() as Array
		for e in end_turn_effects:
			e.run_end_turn_effect()
