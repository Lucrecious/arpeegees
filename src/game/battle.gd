class_name BattleScreen
extends Control

const LayoutTwoOne := preload('res://src/game/battle/layout_two_one.tscn')

export(int) var pin_count := 3

var _layout: BattleLayout = null

onready var _battle_layer := $ViewportContainer/Viewport as Viewport

func _ready() -> void:
	_configure_viewport()
	
	var pins := ArpeegeePins.pick_random(pin_count)
	if _is_two_one_layout(pins.npcs.size(), pins.players.size()):
		_layout = _create_battle_layout(LayoutTwoOne, pins)
		_drop_character_pins(pins)
	else:
		assert(false, 'scenario not defined yet')

func _configure_viewport() -> void:
	var max_superscaling := 2560
	
	var scale :=  max_superscaling / _battle_layer.size.x
	
	_battle_layer.size *= scale
	
	_battle_layer.canvas_transform = get_tree().root.canvas_transform
	
	_battle_layer.get_texture().flags = Texture.FLAG_FILTER
	_battle_layer.canvas_transform = _battle_layer.canvas_transform.scaled(Vector2.ONE * scale)

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
	
	_drop_pins(players, right_positions)
	_drop_pins(npcs, left_positions)

func _drop_pins(pins: Array, positions: PoolVector2Array) -> void:
	for i in positions.size():
		var pin := pins[i] as ArpeegeePin
		
		var pin_node := load(pin.scene_path).instance() as ArpeegeePinNode
		
		_battle_layer.add_child(pin_node)
		var position := positions[i]
		
		pin_node.global_position = position + Vector2.UP * 1000.0
		
		pin_node.emit_stars()
		
		var drop_tween := get_tree().create_tween()
		drop_tween.tween_interval(rand_range(0.2, 0.7))
		drop_tween.tween_property(pin_node, 'global_position:y', position.y, 1.5)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_BOUNCE)
		drop_tween.tween_callback(pin_node, 'stop_star_emission')

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
