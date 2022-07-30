class_name BattleScreen
extends Control

const LayoutTwoOne := preload('res://src/game/battle/layout_two_one.tscn')

export(int) var pin_count := 3

var _layout: BattleLayout = null

onready var _battle_viewport := $ViewportContainer/Viewport as Viewport
onready var _battle_layer := $ViewportContainer/Viewport/YSort as YSort
onready var _turn_manager := $TurnManager as TurnManager

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
	var player_nodes := _drop_pins(players, right_positions, max_wait_sec, bounce_sec)
	var npc_nodes := _drop_pins(npcs, left_positions, max_wait_sec, bounce_sec)
	var nodes := player_nodes + npc_nodes
	
	var tween_to_turning := get_tree().create_tween()
	tween_to_turning.tween_interval(max_wait_sec + bounce_sec + .7)
	tween_to_turning.tween_callback(_turn_manager, 'initialize_turns', [nodes])

func _drop_pins(pins: Array, positions: PoolVector2Array, wait_sec: float, bounce_sec: float) -> Array:
	var nodes := []
	for i in positions.size():
		var pin := pins[i] as ArpeegeePin
		
		var pin_node := load(pin.scene_path).instance() as ArpeegeePinNode
		pin_node.resource = pin
		
		nodes.push_back(pin_node)
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
	
	return nodes

func _create_battle_layout(layout_scene: PackedScene, pins: Dictionary) -> BattleLayout:
	var mirrored := (pins.npcs.size() == 1) as bool
	var layout := _create_layout(layout_scene)
	_battle_layer.add_child(layout)
	if mirrored:
		layout.mirror()
	
	return layout

func _create_layout(layout_scene: PackedScene) -> BattleLayout:
	var instance := layout_scene.instance() as BattleLayout
	assert(instance, 'must be battle layout')
	
	return instance

func _is_two_one_layout(amount1: int, amount2: int) -> bool:
	return (amount1 == 1 and amount2 == 2) or (amount1 == 2 and amount2 == 1)
