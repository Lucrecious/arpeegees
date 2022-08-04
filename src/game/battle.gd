class_name BattleScreen
extends Control

signal pins_dropped()

enum Advantage {
	HealthUp,
	AttackUp,
	EvasionUp,
}

const LayoutTwoOne := preload('res://src/game/battle/layout_two_one.tscn')

export(int) var pin_count := 3

var _layout: BattleLayout = null

onready var _battle_viewport := $ViewportContainer/Viewport as Viewport
onready var _battle_layer := $ViewportContainer/Viewport/YSort as YSort
onready var _turn_manager := $TurnManager as TurnManager
onready var _narrator := $'%Narrator' as NarratorUI

func _ready() -> void:
	_configure_viewport(_battle_viewport)
	
	var pins := ArpeegeePins.pick_random(pin_count)
	if _is_two_one_layout(pins.npcs.size(), pins.players.size()):
		_layout = _create_battle_layout(LayoutTwoOne, pins)
		_drop_character_pins(pins)
	else:
		assert(false, 'scenario not defined yet')

func _configure_viewport(viewport: Viewport) -> void:
	var max_superscaling := 2560
	
	var scale :=  max_superscaling / viewport.size.x
	
	viewport.size *= scale
	
	viewport.canvas_transform = get_tree().root.canvas_transform
	
	viewport.get_texture().flags = Texture.FLAG_FILTER
	viewport.canvas_transform = viewport.canvas_transform.scaled(Vector2.ONE * scale)

func _is_two_one_layout(amount1: int, amount2: int) -> bool:
	return (amount1 == 1 and amount2 == 2) or (amount1 == 2 and amount2 == 1)

func _create_battle_layout(layout_scene: PackedScene, pins: Dictionary) -> BattleLayout:
	var mirrored := (pins.npcs.size() == 1) as bool
	var layout := layout_scene.instance() as BattleLayout
	assert(layout, 'must be battle layout')
	_battle_layer.add_child(layout)
	if mirrored:
		layout.mirror()
	
	return layout

func _drop_character_pins(pins: Dictionary) -> void:
	var left_positions := _layout.get_left_positions()
	var right_positions := _layout.get_right_positions()
	var npcs := pins.npcs as Array
	var players := pins.players as Array
	if left_positions.size() != npcs.size():
		assert(false)
		return
	
	if right_positions.size() != players.size():
		assert(false)
		return
	
	var max_wait_sec := .5
	var bounce_sec := 1.5
	
	connect('pins_dropped', self, '_on_pins_dropped', [max_wait_sec + bounce_sec])
	_load_and_drop_pins(players + npcs, right_positions + left_positions, max_wait_sec, bounce_sec)

func _on_pins_dropped(wait_sec: float) -> void:
	_wait_for_drop_to_finish(wait_sec)

func _wait_for_drop_to_finish(wait_sec: float) -> void:
	var tween_to_intro_narration := get_tree().create_tween()
	tween_to_intro_narration.tween_interval(wait_sec)
	tween_to_intro_narration.tween_callback(self, '_do_intro_narration')

func _do_intro_narration() -> void:
	var speaking_tween := create_tween()
	speaking_tween.tween_callback(_narrator, 'speak_tr', ['NARRATOR_BATTLE_INTRODUCTION_GENERIC'])
	TweenExtension.pause_until_signal(speaking_tween.parallel(), _narrator, 'speaking_ended')
	speaking_tween.tween_callback(self, '_balance_battle')

func _balance_battle() -> void:
	_turn_manager.connect('battle_ended', self, '_on_battle_ended')
	var nodes := NodE.get_children(_battle_layer, ArpeegeePinNode)
	
	var disadvantaged_nodes := _get_disadvantaged_nodes(nodes)
	
	if not disadvantaged_nodes.empty():
		_add_random_advantage(disadvantaged_nodes)
	
	_start_battle(nodes)

func _on_battle_ended(end_condition: int) -> void:
	if end_condition == TurnManager.EndCondition.NPCsDead:
		_narrator.speak_tr('NARRATOR_BATTLE_FINISHED_HEROES_WIN_GENERIC')
	elif end_condition == TurnManager.EndCondition.PlayersDead:
		_narrator.speak_tr('NARRATOR_BATTLE_FINISHED_MONSTERS_WIN_GENERIC')
	elif end_condition == TurnManager.EndCondition.EveryoneDead:
		_narrator.speak_tr('NARRATOR_BATTLE_FINISHED_TIED_GENERIC')
	else:
		assert(false)

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

func _add_random_advantage(nodes: Array) -> void:
	var advantage := _get_random_advantage()
	
	match advantage:
		Advantage.AttackUp:
			_increase_attack(nodes)
		Advantage.EvasionUp:
			_increase_evasion(nodes)
		Advantage.HealthUp:
			_increase_health(nodes)

func _get_random_advantage() -> int:
	var values := Advantage.values()
	var advantage := values[randi() % values.size()] as int
	return advantage

func _increase_attack(nodes: Array) -> void:
	for n in nodes:
		var stats := NodE.get_child(n, PinStats) as PinStats
		if not stats:
			assert(false)
			continue
		
		stats.attack += (stats.attack / 2)

func _increase_evasion(nodes: Array) -> void:
	for n in nodes:
		var stats := NodE.get_child(n, PinStats) as PinStats
		if not stats:
			assert(false)
			continue
		
		stats.evasion += (stats.evasion / 2)

func _increase_health(nodes: Array) -> void:
	for n in nodes:
		var health := NodE.get_child(n, Health) as Health
		if not health:
			assert(false)
			continue
		
		health.max_points = health.max_points * 2
		health.current = health.max_points

func _start_battle(nodes: Array) -> void:
	_turn_manager.initialize_turns(nodes)
	_narrator.watch(nodes)

func _load_and_drop_pins(pins: Array, positions: PoolVector2Array, wait_sec: float, bounce_sec: float) -> void:
	var background_resource_loader := BackgroundResourceLoader.new()
	var tween := create_tween()
	TweenExtension.pause_until_signal(tween, background_resource_loader, 'finished')
	tween.tween_callback(self, '_drop_pins', [positions, pins, background_resource_loader, wait_sec, bounce_sec])
	
	var scene_paths := PoolStringArray([])
	
	for i in positions.size():
		var pin := pins[i] as ArpeegeePin
		scene_paths.push_back(pin.scene_path)
	
	background_resource_loader.load(scene_paths)
	
	
func _drop_pins(positions: PoolVector2Array, pins: Array, loader: BackgroundResourceLoader,
		wait_sec: float, bounce_sec: float) -> void:
	
	var pin_resources := loader.result as Array
	for i in positions.size():
		var pin := pins[i] as ArpeegeePin
		
		var pin_node_scene := pin_resources[i] as PackedScene
		var pin_node := pin_node_scene.instance() as ArpeegeePinNode
		pin_node.resource = pin
		
		_battle_layer.add_child(pin_node)
		var position := positions[i]
		
		pin_node.global_position = position + Vector2.UP * 1000.0
		
		pin_node.emit_stars()
		
		var drop_tween := get_tree().create_tween()
		drop_tween.tween_interval(rand_range(0.0, wait_sec))
		drop_tween.tween_property(pin_node, 'global_position:y', position.y, bounce_sec)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_BOUNCE)
		drop_tween.tween_callback(pin_node, 'stop_star_emission')
	
	emit_signal('pins_dropped')

