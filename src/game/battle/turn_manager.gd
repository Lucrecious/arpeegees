class_name TurnManager
extends Node

signal pins_changed()
signal turn_started_before_actions()
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

var _redo_turn_queued := false

onready var _start_turn_effect_runner := $StartTurnEffectRunner as StartTurnEffectRunner

func _ready() -> void:
	connect('pins_changed', self, '_on_pins_changed')

func initialize_turns(pins: Array) -> void:
	
	_ordered_pins = pins.duplicate()
	_players = _get_type(ArpeegeePin.Type.Player)
	_npcs = _get_type(ArpeegeePin.Type.NPC)
	
	_ordered_pins.sort_custom(self, '_by_playable_by_topdown')
	
	if _ordered_pins.empty():
		assert(false)
		return
	
	for p in _ordered_pins:
		var transformers := NodE.get_children(p, Transformer)
		for transformer in transformers:
			Logger.info('connected transform from %s' % [p.name])
			transformer.connect('transform_requested', self, '_on_pin_transform_requested', [p, transformer], CONNECT_ONESHOT)
	
	Logger.info('initialized and pins_changed emitted')
	emit_signal('pins_changed')
	emit_signal('initialized')

func _on_pins_changed() -> void:
	pass

func turn_count() -> int:
	return _current_turn

func queue_redo_turn() -> void:
	_redo_turn_queued = true

func use_item(item: PinItemPowerUp) -> void:
	item.apply_power(_ordered_pins)

func step_turn() -> void:
	Logger.info('step to turn %d' % [_current_turn])
	_do_turn(_current_turn)

func get_npcs() -> Array:
	return _npcs.duplicate()

func get_players() -> Array:
	return _players.duplicate()

static func is_alive(pins: Array) -> Array:
	var alive_pins := []
	for p in pins:
		var health := NodE.get_child(p, Health) as Health
		if health.current <= 0:
			continue
		
		alive_pins.push_back(p)
	
	return alive_pins

func get_pins() -> Array:
	return _ordered_pins.duplicate()

func get_turn_index(pin: ArpeegeePinNode) -> int:
	return _ordered_pins.find(pin)

func get_pin_on_turn(turn: int) -> ArpeegeePinNode:
	if turn < 0 or turn >= _ordered_pins.size():
		return null
	return _ordered_pins[turn]

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
	
	if _redo_turn_queued:
		_redo_turn_queued = false
	else:
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

func balance_battle(animation: SceneTreeTween) -> int:
	var disadvantaged_nodes := _get_disadvantaged_nodes(_ordered_pins)
	
	if disadvantaged_nodes.empty():
		return -1
	
	var type := disadvantaged_nodes[0].resource.type as int
	animation.tween_callback(self, '_add_attack_boost', [disadvantaged_nodes, type])
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
		effect.is_ailment = false
		
		var attack := StatModifier.new()
		attack.type = StatModifier.Type.Attack
		attack.add_amount = 3
		
		var magic_attack := StatModifier.new()
		magic_attack.type = StatModifier.Type.MagicAttack
		attack.add_amount = 3
		
		var defence := StatModifier.new()
		defence.type = StatModifier.Type.Defence
		defence.add_amount = 1
		
		var magic_defence := StatModifier.new()
		magic_defence.type = StatModifier.Type.MagicDefence
		magic_defence.add_amount = 1
		
		var max_health := StatModifier.new()
		max_health.type = StatModifier.Type.MaxHealth
		max_health.multiplier = 2.0
		
		NodE.add_children(effect, [attack, magic_attack, defence, magic_defence, max_health])
		
		match type:
			ArpeegeePin.Type.NPC:
				NodE.add_children(effect, Aura.create_enraged_auras())
			ArpeegeePin.Type.Player:
				print_debug('balance battle from player not implemented')
		
		status_effects.add_instance(effect)
		
		var health := NodE.get_child(n, Health) as Health
		health.current_set(health.current * 2.0)

static func remove_by_file(pins: Array, file: String) -> Array:
	var new_pins := []
	for p in pins:
		if p.filename.get_file() == file:
			continue
		new_pins.push_back(p)
	return new_pins

func _on_action_started() -> void:
	_is_running_action = true

func _on_action_ended() -> void:
	_do_queued_transforms()
	
	_is_running_action = false
	finish_turn()

func _do_queued_transforms() -> void:
	# old transforms do not need to be disconnected because they get deleted
	
	var changed := false
	while not _transform_queue.empty():
		var stuff := _transform_queue.pop_front() as Dictionary
		var pin := stuff.pin as ArpeegeePinNode
		var old_pin_health := NodE.get_child(pin, Health) as Health
		
		if old_pin_health.current <= 0:
			continue
		
		var old_pin_index := _ordered_pins.find(pin)
		
		if old_pin_index < 0:
			continue
		
		changed = true
		
		var transformer := stuff.transformer as Transformer
		
		var new_pin := transformer.transform_scene.instance() as ArpeegeePinNode
		
		var new_pin_transformers := NodE.get_children(new_pin, Transformer)
		for new_pin_transformer in new_pin_transformers:
			Logger.info('new pin transform connected from %s' % new_pin.name)
			new_pin_transformer.connect('transform_requested', self, '_on_pin_transform_requested', [new_pin, new_pin_transformer])
		
		var new_pin_resource := new_pin._resource_set.duplicate() as ArpeegeePin
		new_pin._resource_set = new_pin_resource
		var new_pin_root_sprite := NodE.get_child(new_pin, RootSprite) as RootSprite
		new_pin_root_sprite.material = new_pin_root_sprite.material.duplicate() as ShaderMaterial
		
		# flip the pin if it's a different type
		if new_pin_resource.type != pin.resource.type:
			var actions := NodE.get_child(new_pin, PinActions) as PinActions
			actions.scale.x = -1
			new_pin_root_sprite.scale.x = -1
			new_pin_resource.type = pin.resource.type
		
		pin.get_parent().add_child(new_pin)
		
		var new_pin_health := NodE.get_child(new_pin, Health) as Health
		
		new_pin.position = pin.position
		
		_transfer_status_effects(pin, new_pin)
		
		var stats := NodE.get_child(new_pin, ModifiedPinStats) as ModifiedPinStats
		new_pin_health.current = min(old_pin_health.current, stats.max_health)
		
		_ordered_pins[old_pin_index] = new_pin
		_npcs = _get_type(ArpeegeePin.Type.NPC)
		_players = _get_type(ArpeegeePin.Type.Player)
		
		pin.get_parent().remove_child(pin)
		pin.queue_free()
	
	if not changed:
		return
	
	Logger.info('pins_changed emitted')
	emit_signal('pins_changed')

func banan_fishguy_combine() -> void:
	var fishguy := get_pin_by_filename('fishguy.tscn')
	var banan := get_pin_by_filename('banan.tscn')
	assert(banan and fishguy)
	
	_ordered_pins.erase(fishguy)
	fishguy.queue_free()
	banan.queue_free()
	
	var banan_index := _ordered_pins.find(banan)
	var fishguy_banan := load('res://src/resources/arpeegee_pins/fishguy_banan.tscn').instance() as ArpeegeePinNode
	banan.get_parent().add_child(fishguy_banan)
	fishguy_banan.position = banan.position
	
	_ordered_pins[banan_index] = fishguy_banan
	_npcs = _get_type(ArpeegeePin.Type.NPC)
	_players = _get_type(ArpeegeePin.Type.Player)
	
	Logger.info('pins_changed emitted')
	emit_signal('pins_changed')

func get_pin_by_filename(filename: String) -> ArpeegeePinNode:
	for pin in get_pins():
		if pin.filename.get_file() == filename:
			return pin
		
	return null

func _transfer_status_effects(old_pin: ArpeegeePinNode, new_pin: ArpeegeePinNode) -> void:
	var old_effects_list := NodE.get_child(old_pin, StatusEffectsList) as StatusEffectsList
	var new_effects_list := NodE.get_child(new_pin, StatusEffectsList) as StatusEffectsList
	
	old_effects_list.set_block_signals(true)
	
	var old_effects := old_effects_list.get_all()
	for child in old_effects:
		old_effects_list.remove_child(child)
		new_effects_list.add_instance(child)

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
	
	
	emit_signal('turn_started_before_actions')
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
	Logger.info('transform requested from %s to resource %s' % [pin.name, transformer.transform_scene.resource_path.get_file()])
	_transform_queue.push_back({ pin = pin, transformer = transformer })

func _run_end_turn_effects(pin: ArpeegeePinNode) -> void:
	var status_effects := NodE.get_child(pin, StatusEffectsList) as StatusEffectsList
	var effects := status_effects.get_all()
	
	for effect in effects:
		var end_turn_effects := effect.get_end_turn_effects() as Array
		for e in end_turn_effects:
			e.run_end_turn_effect()
